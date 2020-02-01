//
//  Int-Extension.swift
//  smartList
//
//  Created by Steven Dito on 1/16/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import Foundation


extension Int {
    func getDisplayHoursAndMinutes() -> String {
        guard self > 59 else { return "\(self) m" }
        
        let hours = self/60
        let minutes = self%60
        
        if minutes == 0 {
            return "\(hours) h"
        } else {
            return "\(hours) h \(minutes) m"
        }
    }
    
    func getMonthFromInt() -> String {
        switch self {
        case 1:
            return "January"
        case 2:
            return "February"
        case 3:
            return "March"
        case 4:
            return "April"
        case 5:
            return "May"
        case 6:
            return "June"
        case 7:
            return "July"
        case 8:
            return "August"
        case 9:
            return "September"
        case 10:
            return "October"
        case 11:
            return "November"
        case 12:
            return "December"
        default:
            fatalError()
        }
    }
}
