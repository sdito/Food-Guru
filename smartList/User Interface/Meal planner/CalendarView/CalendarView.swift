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
For buttons, the initial tag from 1 to 42 is to assist in settig the UI
 
After setting UI, tag will be changed to 0 if the button is for the previous month, 1 if it is the current month, and 2 for the next
month in the calendar
*/

class CalendarView: UIView {
    
    @IBOutlet var day: [UIButton]!
    @IBOutlet weak var monthYearLabel: UILabel!
    private var year: Int?
    private var date: Date?
    private let calendar = Calendar.current
    
    
    func setUI(monthsInFuture: Int) {
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
                // from the current month, so new tag will be 1
                d.setTitle("\(d.tag - firstWeekday + 1)", for: .normal)
                d.tag = 1
            } else {
                // from the 'next' month, so new tag will be 2
                d.alpha = 0.4
                d.setTitle("\(d.tag - numDays - firstWeekday + 1)", for: .normal)
                d.tag = 2
            }
        }
    }
    
    
    @objc func buttonPressed(_ sender: UIButton) {
        print(sender.titleLabel!.text!, sender.tag)
    }
    
    
}




