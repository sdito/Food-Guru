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
}



class CalendarView: UIView {
    
    @IBOutlet var day: [UIButton]!
    @IBOutlet weak var monthYearLabel: UILabel!
    
    weak var delegate: CalendarViewDelegate!
    var monthsInFuture: Int?
    private var isCurrentMonth = false
    private var year: Int?
    private var date: Date?
    private let calendar = Calendar.current
    
    
    func setUI(monthsInFuture: Int) {
        self.monthsInFuture = monthsInFuture
        if monthsInFuture == 0 {
            isCurrentMonth = true
        }
        let data = calendar.monthsInFutureData(monthsInFuture)
        monthYearLabel.text = "\(data.month) \(data.year)"
        date = data.dateUsed
        let numDays = data.nDays
        let weekday = calendar.weekDayFrom(date: date!)
        let dayNumber = calendar.dayComponentFrom(date: date!)
        year = data.year
        let firstWeekday = MealPlanner.getWeekdayForFirstDay(dayNumber: dayNumber, weekday: weekday)
        
        let daysInPreviousMonth = calendar.daysInMonth(date: date ?? Date(), monthsDifference: -1)
        
        for d in day {
            
            if d.tag == 1 {
                // test for setting ui for when there are recipes on that day, a small dot for each recipe on that day, up to 3 dots
                d.translatesAutoresizingMaskIntoConstraints = false
                
                let sv = UIStackView()
                sv.translatesAutoresizingMaskIntoConstraints = false
                sv.axis = .horizontal
                sv.alignment = .center
                sv.distribution = .fillEqually
                sv.spacing = 5.0
                
                let view = UIView()
                let view2 = UIView()
                let view3 = UIView()
                
                sv.insertArrangedSubview(view, at: 0)
                sv.insertArrangedSubview(view2, at: 0)
                sv.insertArrangedSubview(view3, at: 0)
                
                view.backgroundColor = .red; view2.backgroundColor = .red; view3.backgroundColor = .red
                view.heightAnchor.constraint(equalToConstant: 7.5).isActive = true
                view2.heightAnchor.constraint(equalToConstant: 7.5).isActive = true
                view3.heightAnchor.constraint(equalToConstant: 7.5).isActive = true
                view.widthAnchor.constraint(equalToConstant: 7.5).isActive = true
                view2.widthAnchor.constraint(equalToConstant: 7.5).isActive = true
                view3.widthAnchor.constraint(equalToConstant: 7.5).isActive = true
                
                d.addSubview(sv)
                d.bringSubviewToFront(sv)
//                sv.heightAnchor.constraint(equalToConstant: d.bounds.height / 3).isActive = true
                sv.leadingAnchor.constraint(greaterThanOrEqualTo: d.leadingAnchor).isActive = true
                sv.trailingAnchor.constraint(greaterThanOrEqualTo: d.trailingAnchor).isActive = true
                sv.bottomAnchor.constraint(equalTo: d.bottomAnchor).isActive = true
                
                
            }
            
            d.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
            if d.tag < firstWeekday {
                // from the 'before' month, so new tag will be 0
                d.alpha = 0.4
                d.setTitle("\(d.tag + daysInPreviousMonth - firstWeekday + 1)", for: .normal)
                d.tag = 0
                
            } else if d.tag < firstWeekday + numDays {
                let dateNumber = d.tag - firstWeekday + 1
                d.setTitle("\(dateNumber)", for: .normal)
                d.tag = 1
                
                if isCurrentMonth && dateNumber == calendar.component(.day, from: date ?? Date()) {
                    d.setTitleColor(.systemGreen, for: .normal)
                    
                    // tell the delegate what the current day is
                    delegate.dateButtonSelected(month: Month.monthFromInt(int: calendar.component(.month, from: date ?? Date())), day: Int(d.titleLabel!.text!)!, year: calendar.component(.year, from: date ?? Date()))
                }
            } else {
                // from the 'next' month, so new tag will be 2
                d.alpha = 0.4
                d.setTitle("\(d.tag - numDays - firstWeekday + 1)", for: .normal)
                d.tag = 2
            }
        }
    }
    
    // MARK: Button action
    @objc func buttonPressed(_ sender: UIButton) {
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
    }
    
    
}




