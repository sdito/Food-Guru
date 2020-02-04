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
    private var isCurrentMonth = false
    private var year: Int?
    private var date: Date?
    private let calendar = Calendar.current
    
    
    func setUI(monthsInFuture: Int) {
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




