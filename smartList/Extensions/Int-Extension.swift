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
}
