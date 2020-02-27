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
    func dateButtonSelected(month: Month, day: Int, year: Int)
    func selectedDay(button: UIButton)
}



class CalendarView: UIView {
    
    @IBOutlet var day: [UIButton]!
    @IBOutlet weak var monthYearLabel: UILabel!

    weak var delegate: CalendarViewDelegate!
    var monthsInFuture: Int?
    var recipes: [MPCookbookRecipe]?
    
    private var monthYear: (Int, Int)?
    private var isCurrentMonth = false
    private var year: Int?
    private var date: Date?
    private let calendar = Calendar.current
    
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .dayButtonSelectedFromCalendar, object: nil)
    }
    
    
    func setUI(monthsInFuture: Int, recipes: [MPCookbookRecipe]?) {
        NotificationCenter.default.addObserver(self, selector: #selector(dateButtonChangedSelector(_:)), name: .dayButtonSelectedFromCalendar, object: nil)
        self.monthsInFuture = monthsInFuture
        self.recipes = recipes
        
        if monthsInFuture == 0 {
            isCurrentMonth = true
        }
        let data = calendar.monthsInFutureData(monthsInFuture)
        monthYearLabel.text = "\(data.month) \(data.year)"
        monthYear = (calendar.component(.month, from: data.dateUsed), data.year)
        
        date = data.dateUsed
        let numDays = data.nDays
        let weekday = calendar.weekDayFrom(date: date!)
        let dayNumber = calendar.dayComponentFrom(date: date!)
        year = data.year
        let firstWeekday = MealPlanner.getWeekdayForFirstDay(dayNumber: dayNumber, weekday: weekday)
        let daysInPreviousMonth = calendar.daysInMonth(date: date ?? Date(), monthsDifference: -1)
        
        for d in day {
            var dayButtonDate: String?
            d.layer.borderWidth = 0.5
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
                    d.tag = 11
                    // tell the delegate what the current day is
                    delegate.dateButtonSelected(month: Month.monthFromInt(int: calendar.component(.month, from: date ?? Date())), day: Int(d.titleLabel!.text!)!, year: calendar.component(.year, from: date ?? Date()))
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
    
    private func setRecipeOnDayUI(b: UIButton, shortDate: String?) {
        
        // need to get the number of recipes with a matching data
        // add up to three views to the date for how many recipes that date has
        if let shortDate = shortDate, let recipes = recipes {
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
                print("\(shortDate) has \(counter) recipes")
                counter = min(3, counter)
                b.translatesAutoresizingMaskIntoConstraints = false
                        
                let sv = UIStackView()
                sv.translatesAutoresizingMaskIntoConstraints = false
                sv.axis = .horizontal
                sv.distribution = .fill
                sv.spacing = 5.0
                
                
                
                for _ in 1...counter {
                    let view = UIView()
                    sv.insertArrangedSubview(view, at: 0)
                    view.backgroundColor = Colors.label
                    view.heightAnchor.constraint(equalToConstant: 5).isActive = true
                    view.widthAnchor.constraint(equalToConstant: 5).isActive = true
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
            }
            
        }
    }
    
    // MARK: @objc funcs
    @objc func buttonPressed(_ sender: UIButton) {
        
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
        
        delegate.dateButtonSelected(month: month, day: Int(sender.titleLabel!.text!)!, year: yearInt)
        delegate.selectedDay(button: sender)
    }
    
    @objc func dateButtonChangedSelector(_ notification: Notification) {
        if let dict = notification.userInfo as? [String:Any] {
            if let shortDate = dict["shortDate"] as? String {
                let shortDateComponents = shortDate.split(separator: ".").map({Int($0)})
                print("Worked from notification, date is: \(shortDate), this calendar is: \(monthYear?.0), \(monthYear?.1)") // prints multiple times since it is once per each view
                // need to use this date to alter the UI for the correct day buttons
                // need to rememebr what buttons were changed, and then change them back when a new date is selected
                // delegate.selectedDay(button: <#T##UIButton#>) <- use this, and alter the implementation so that it has multiple selected days in VC
                
                var januaryIsNextMonth = false
                var decemberIsPreviousMonth = false
                
                let monthFromButton = shortDateComponents[0]!
                var monthsToTest: [Int] = []
                monthsToTest.append(monthFromButton)
                
                if monthFromButton + 1 == 13 {
                    monthsToTest.append(1)
                    januaryIsNextMonth = true
                } else {
                    monthsToTest.append(monthFromButton + 1)
                }
                
                if monthFromButton - 1 == 0 {
                    monthsToTest.append(12)
                    decemberIsPreviousMonth = true
                } else {
                    monthsToTest.append(monthFromButton - 1)
                }
                
                if monthsToTest.contains(monthYear?.0 ?? -1) {
                    // then there is a chance the button UI needs to change
                    // find if the new date from the button
                    // first find what tag i should be looking for
                    let dayFromButton = shortDateComponents[1]!
                    
                }
                
            }
        }
    }
    
}




