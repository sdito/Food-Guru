//
//  Date-Extension.swift
//  smartList
//
//  Created by Steven Dito on 3/5/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import Foundation


extension Date {
    func dbFormat() -> String {
        
        let calendar = Calendar.current
        let month = calendar.component(.month, from: self)
        let day = calendar.component(.day, from: self)
        let year = calendar.component(.year, from: self)
        
        return "\(month).\(day).\(year)"
    }
}
