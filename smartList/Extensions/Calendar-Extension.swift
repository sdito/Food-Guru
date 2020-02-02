//
//  Calendar-Extension.swift
//  smartList
//
//  Created by Steven Dito on 2/1/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import Foundation


extension Calendar {
    func weekDayFrom(date: Date) -> Int {
        return self.component(.weekday, from: date)
    }
    
    func dayComponentFrom(date: Date) -> Int {
        return self.component(.day, from: date)
    }
    
    func monthsInFutureData(_ n: Int) -> (year: Int, month: String, nDays: Int, dateUsed: Date) {
        let futureDate = self.date(byAdding: .month, value: n, to: Date())!
        let year = self.component(.year, from: futureDate)
        let month = self.component(.month, from: futureDate).getMonthFromInt()
        let range = self.range(of: .day, in: .month, for: futureDate)
        
        
        return (year, month, range!.count, futureDate)
    }
    
    func daysInMonth(date: Date, monthsDifference: Int) -> Int {
        let futureDate = self.date(byAdding: .month, value: monthsDifference, to: date)!
        return self.range(of: .day, in: .month, for: futureDate)?.count ?? 31
    }
}
