//
//  TimeInterval-Extension.swift
//  smartList
//
//  Created by Steven Dito on 9/5/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import Foundation
import UIKit

extension TimeInterval {
    func timeSince() -> String {
        let difference = abs(Date().timeIntervalSince1970 - self)
        switch difference {
        
        // seconds, just created
        case 0...60:
            return "Created now"
        // return in minutes
        case 60...3600:
            return "\(Int(difference/60)) minutes ago"
        // return in hours
        case 3600...86_400:
            return "\(Int(difference/3600)) hours ago"
        
        // return in days
        case 86_400...2_678_400:
            var days: Int {
                if Int(difference/86_400) == 0 {
                    return 1
                } else {
                    return Int(difference/86_400)
                }
            }
            return "\(days) days ago"
        
        // return in months
        case 2_678_400...31_538_000:
            var months: Int {
                if Int(difference/2_628_000) == 0 {
                    return 1
                } else {
                    return Int(difference/2_628_000)
                }
            }
            return "\(months) months ago"
        
        // return in years
        case 31_538_000...:
            return "\(Int(difference/31_538_000)) years ago"
            
        default:
            return ""
        }
    }
}
