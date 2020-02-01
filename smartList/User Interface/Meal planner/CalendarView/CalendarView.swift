//
//  CalendarView.swift
//  smartList
//
//  Created by Steven Dito on 1/31/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit
import Foundation


class CalendarView: UIView {
    
    var date: Date?
    
    private let calendar = Calendar.current
    
    @IBOutlet var day: [UIButton]!
    @IBOutlet weak var monthYearLabel: UILabel!
    
    func setUI(monthsInFuture: Int) {
        let data = calendar.monthsInFutureData(monthsInFuture)
        monthYearLabel.text = "\(data.month) \(data.year)"
        
    }
}



#warning("move to own file")
extension Calendar {
    
    
    func weekDayFrom(date: Date) -> Int {
        return self.component(.weekday, from: date)
    }
    
    func monthsInFutureData(_ n: Int) -> (year: Int, month: String, nDays: Int) {
        let futureDate = self.date(byAdding: .month, value: n, to: Date())!
        let year = self.component(.year, from: futureDate)
        let month = self.component(.month, from: futureDate).getMonthFromInt()
        let range = self.range(of: .day, in: .month, for: futureDate)
        
        
        return (year, month, range!.count)
    }
    
}
