//
//  CalendarView.swift
//  smartList
//
//  Created by Steven Dito on 1/31/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit
import Foundation

/*
For buttons, the initial tag from 1 to 42 is to assist in setting the UI
 
After setting UI, tag will be changed to 0 if the button is for the previous month, 1 if it is the current month, and 2 for the next
month in the calendar
*/


protocol CalendarViewDelegate: class {
    func dateButtonSelected(month: Month, day: Int, year: Int, buttonTag: Int)
    func selectedDay(button: UIButton)
    func associatedToSelectedDay(button: UIButton)
}



class CalendarView: UIView {
    
    @IBOutlet var stackViews: [UIStackView]!
    @IBOutlet var day: [UIButton]!
    @IBOutlet var weekdayLabels: [UILabel]!
    @IBOutlet weak var monthYearLabel: UILabel!

    weak var delegate: CalendarViewDelegate!
    var monthsInFuture: Int?
    var monthYear: (Int, Int)?
    private var isCurrentMonth = false
    private var year: Int?
    private var date: Date?
    private let calendar = Calendar.current
    private var recipes: [MealPlanner.RecipeTransfer] = []
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .dayButtonSelectedFromCalendar, object: nil)
    }
    
    
    func setUI(monthsInFuture: Int, recipes: [String:Set<MealPlanner.RecipeTransfer>]) {
        NotificationCenter.default.addObserver(self, selector: #selector(dateButtonChangedSelector(_:)), name: .dayButtonSelectedFromCalendar, object: nil)
        let data = calendar.monthsInFutureData(monthsInFuture)
        monthYear = (calendar.component(.month, from: data.dateUsed), data.year)
        iPadUiIfNeeded()
        self.monthsInFuture = monthsInFuture
        self.recipes = Array(recipes.values.joined())//Array<MealPlanner.RecipeTransfer>(recipes["\(monthYear!.0).\(monthYear!.1)"] ?? Set<MealPlanner.RecipeTransfer>())
        
        if monthsInFuture == 0 {
            isCurrentMonth = true
        }
        
        monthYearLabel.text = "\(data.month) \(data.year)"
        
        date = data.dateUsed
        let numDays = data.nDays
        let weekday = calendar.weekDayFrom(date: date!)
        let dayNumber = calendar.dayComponentFrom(date: date!)
        year = data.year
        let firstWeekday = MealPlanner.getWeekdayForFirstDay(dayNumber: dayNumber, weekday: weekday)
        let daysInPreviousMonth = calendar.daysInMonth(date: date ?? Date(), monthsDifference: -1)
        
        for d in day {
            
            if !SharedValues.shared.isPhone {
                d.titleLabel?.font = UIFont(name: "futura", size: 25)
            }
            
            var dayButtonDate: String?
            var borderWidthDay: CGFloat {
                if SharedValues.shared.isPhone {
                    return 0.5
                } else {
                    return 1
                }
            }
            d.layer.borderWidth = borderWidthDay
            d.layer.borderColor = Colors.label.cgColor
            d.layer.cornerRadius = 5.0
            d.clipsToBounds = true
            
            d.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
            if d.tag < firstWeekday {
                // from the 'before' month, so new tag will be 0
                d.alpha = 0.4
                let dayNum = d.tag + daysInPreviousMonth - firstWeekday + 1
                d.setTitle("\(dayNum)", for: .normal)
                d.tag = 0
                dayButtonDate = "\(calendar.component(.month, from: data.dateUsed) - 1).\(dayNum).\(calendar.component(.year, from: data.dateUsed))"
            } else if d.tag < firstWeekday + numDays {
                // from the 'current' month
                let dayNum = d.tag - firstWeekday + 1
                d.setTitle("\(dayNum)", for: .normal)
                d.tag = 1
                
                if isCurrentMonth && dayNum == calendar.component(.day, from: date ?? Date()) {
                    d.setTitleColor(.systemGreen, for: .normal)
                    // tell the delegate what the current day is
                    delegate.dateButtonSelected(month: Month.monthFromInt(int: calendar.component(.month, from: date ?? Date())), day: Int(d.titleLabel!.text!)!, year: calendar.component(.year, from: date ?? Date()), buttonTag: d.tag)
                    
                    // set the ui as selected for the current day
                    d.backgroundColor = Colors.secondarySystemBackground
                    d.layer.borderColor = UIColor.clear.cgColor
                    delegate.selectedDay(button: d)
                    
                }
                dayButtonDate = "\(calendar.component(.month, from: data.dateUsed)).\(dayNum).\(calendar.component(.year, from: data.dateUsed))"
            } else {
                // from the 'next' month, so new tag will be 2
                d.alpha = 0.4
                let dayNum = d.tag - numDays - firstWeekday + 1
                d.setTitle("\(dayNum)", for: .normal)
                d.tag = 2
                dayButtonDate = "\(calendar.component(.month, from: data.dateUsed) + 1).\(dayNum).\(calendar.component(.year, from: data.dateUsed))"
            }
            
            setRecipeOnDayUI(b: d, shortDate: dayButtonDate)
            
        }
    }
    
    func updateUI(recipes: [String:Set<MealPlanner.RecipeTransfer>]) {
        self.recipes = Array(recipes.values.joined())
        
        if let date = date {
            for d in day {
                
                var dayButtonDate: String?
                let dayNum = Int(d.titleLabel!.text!)!
                if d.tag == 0 {
                    dayButtonDate = "\(calendar.component(.month, from: date) - 1).\(dayNum).\(calendar.component(.year, from: date))"
                } else if d.tag == 1 {
                    dayButtonDate = "\(calendar.component(.month, from: date)).\(dayNum).\(calendar.component(.year, from: date))"
                } else if d.tag == 2 {
                    dayButtonDate = "\(calendar.component(.month, from: date) + 1).\(dayNum).\(calendar.component(.year, from: date))"
                }
                setRecipeOnDayUI(b: d, shortDate: dayButtonDate)
                
            }
        }
    }
    
    func potentiallyUpdateUI(with date: Date, isPreviousMonth: Bool) {
        // Used to update what the current day is as displayed on the meal planner, if it needs to be updated (the 'green' day)
        print("Potentially updating the UI with: \(date.dbFormat()), is previous month: \(isPreviousMonth), view's month represented: \(self.monthYear!.0)")
        
        // 'Default' color is Colors.mail, current day color is .systemGreen
        
        switch isPreviousMonth {
        case true:
            // set the color back to the base for all of them
            for button in day {
                button.setTitleColor(Colors.main, for: .normal)
            }
        case false:
            // set the color to green for the current day, else it is basic
            let currentDayPart = String(date.dbFormat().split(separator: ".")[1])
            for button in day {
                // set all to Colors.main besides the current day
                let buttonDay = button.titleLabel?.text
                if buttonDay == currentDayPart && button.tag == 1 {
                    // needs to be green
                    button.setTitleColor(.systemGreen, for: .normal)
                } else {
                    button.setTitleColor(Colors.main, for: .normal)
                }
            }
        }
        
    }
    
    private func setRecipeOnDayUI(b: UIButton, shortDate: String?) {
        
        // For resetting the UI, to remove the previously added stack view so there is not a duplicate, the tag is previously set to 44
        b.subviews.filter({$0.tag == 44}).forEach({$0.removeFromSuperview()})
        
        if let shortDate = shortDate {
            var counter = 0
            for recipe in recipes {
                if recipe.date == shortDate {
                    counter += 1
                    if counter == 3 {
                        break
                    }
                }
            }
            
            if counter > 0 {
                counter = min(3, counter)
                b.translatesAutoresizingMaskIntoConstraints = false
                        
                let sv = UIStackView()
                sv.translatesAutoresizingMaskIntoConstraints = false
                sv.axis = .horizontal
                sv.distribution = .fill
                sv.spacing = 5.0
                
                var blockSize: CGFloat {
                    if SharedValues.shared.isPhone {
                        return 5
                    } else {
                        return 6.75
                    }
                }
                
                for _ in 1...counter {
                    let view = UIView()
                    sv.insertArrangedSubview(view, at: 0)
                    view.backgroundColor = Colors.label
                    view.heightAnchor.constraint(equalToConstant: blockSize).isActive = true
                    view.widthAnchor.constraint(equalToConstant: blockSize).isActive = true
                }
                
                b.addSubview(sv)
                            
                sv.bottomAnchor.constraint(equalTo: b.bottomAnchor, constant: -5).isActive = true
                sv.leadingAnchor.constraint(equalTo: b.leadingAnchor).isActive = true
                sv.trailingAnchor.constraint(equalTo: b.trailingAnchor).isActive = true
                
                let v1 = UIView(); let v2 = UIView()
                v1.backgroundColor = .clear
                v2.backgroundColor = .clear
                sv.insertArrangedSubview(v1, at: 0)
                sv.addArrangedSubview(v2)
                v1.widthAnchor.constraint(equalTo: v2.widthAnchor).isActive = true
                sv.tag = 44
            }
            
        }
    }
    
    func buttonPressedHelper(sender: UIButton) {
        UIView.animate(withDuration: 0.2) {
            sender.backgroundColor = Colors.secondarySystemBackground
            sender.layer.borderColor = UIColor.clear.cgColor//Colors.secondary.cgColor
        }
        
        
        var monthInt = calendar.component(.month, from: date ?? Date())
        var yearInt = calendar.component(.year, from: date ?? Date())
        
        if sender.tag == 0 {
            monthInt -= 1
            if monthInt == 0 {
                monthInt = 12
                yearInt -= 1
            }
        } else if sender.tag == 2 {
            monthInt += 1
            if monthInt == 13 {
                monthInt = 1
                yearInt += 1
            }
        }
        let month = Month.monthFromInt(int: monthInt)
        
        delegate.dateButtonSelected(month: month, day: Int(sender.titleLabel!.text!)!, year: yearInt, buttonTag: sender.tag)
        delegate.selectedDay(button: sender)
    }
    
    private func iPadUiIfNeeded() {
        if !SharedValues.shared.isPhone {
            monthYearLabel.font = UIFont(name: "futura", size: 19)
            weekdayLabels.forEach({$0.font = UIFont(name: "futura", size: 20)})
            stackViews.forEach({$0.spacing = 12.5})
        }
    }
        
    
    // MARK: @objc funcs
    @objc func buttonPressed(_ sender: UIButton) {
        buttonPressedHelper(sender: sender)
        
    }
    
    @objc func dateButtonChangedSelector(_ notification: Notification) {
        if let dict = notification.userInfo as? [String:Any] {
            if let shortDate = dict["shortDate"] as? String, let tagFromNoti = dict["tagFromNoti"] as? Int {
                let shortDateComponents = shortDate.split(separator: ".").map({Int($0)})
                // need to use this date to alter the UI for the correct day buttons
                // need to rememeber what buttons were changed, and then change them back when a new date is selected
                
                let availableTags = [0,1,2].filter({$0 != tagFromNoti})
                let monthComponent = shortDateComponents[0]!
                // need to use these tags to find what specific tag i should look for, by seeing if this view's months will match up
                for tag in availableTags {
                    if tag == 0 {
                        if (monthYear?.0 ?? -1) - 1 == monthComponent {
                            // check if the date matches up for previous month
                            for d in day {
                                if d.tag == 0 && d.titleLabel?.text == "\(shortDateComponents[1]!)" {
                                    delegate.associatedToSelectedDay(button: d)
                                }
                            }
                        }
                    } else if tag == 1 {
                        if monthYear?.0 == monthComponent {
                            // check if the data matches up for current month
                            for d in day {
                                if d.tag == 1 && d.titleLabel?.text == "\(shortDateComponents[1]!)" {
                                    delegate.associatedToSelectedDay(button: d)
                                }
                            }
                            
                        }
                    } else if tag == 2 {
                        if (monthYear?.0 ?? -1) + 1 == monthComponent {
                            // check if the data matches up for the next month
                            for d in day {
                                if d.tag == 2 && d.titleLabel?.text == "\(shortDateComponents[1]!)" {
                                    delegate.associatedToSelectedDay(button: d)
                                }
                            }
                            
                        }
                    }
                }
            }
        }
    }
    
}




