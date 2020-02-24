//
//  Month.swift
//  smartList
//
//  Created by Steven Dito on 2/3/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import Foundation



enum Month {
    
    case january
    case february
    case march
    case april
    case may
    case june
    case july
    case august
    case september
    case october
    case november
    case december
    
    var description: String {
        switch self {
        case .january:
            return "January"
        case .february:
            return "February"
        case .march:
            return "March"
        case .april:
            return "April"
        case .may:
            return "May"
        case .june:
            return "June"
        case .july:
            return "July"
        case .august:
            return "August"
        case .september:
            return "September"
        case .october:
            return "October"
        case .november:
            return "November"
        case .december:
            return "December"
        }
    }
    
    var int: Int {
        switch self {
        
        case .january:
            return 1
        case .february:
            return 2
        case .march:
            return 3
        case .april:
            return 4
        case .may:
            return 5
        case .june:
            return 6
        case .july:
            return 7
        case .august:
            return 8
        case .september:
            return 9
        case .october:
            return 10
        case .november:
            return 11
        case .december:
            return 12
            
        }
    }
    
    static func monthFromInt(int: Int) -> Month {
        switch int {
        case 1:
            return .january
        case 2:
            return .february
        case 3:
            return .march
        case 4:
            return .april
        case 5:
            return .may
        case 6:
            return .june
        case 7:
            return .july
        case 8:
            return .august
        case 9:
            return .september
        case 10:
            return .october
        case 11:
            return .november
        case 12:
            return .december
        default:
            fatalError()
        }
    }
}
