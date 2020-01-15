//
//  FoodStorageType.swift
//  smartList
//
//  Created by Steven Dito on 9/16/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import Foundation
import UIKit

enum FoodStorageType {
    case unsorted
    case fridge
    case freezer
    case pantry
    
    
    var string: String {
        switch self {
        case .unsorted:
            return "unsorted"
        case .fridge:
            return "fridge"
        case .freezer:
            return "freezer"
        case .pantry:
            return "pantry"
        }
    }
    
    static func stringToFoodStorageType(string: String) -> FoodStorageType {
        switch string {
        case "none":
            return .unsorted
        case "fridge":
            return .fridge
        case "freezer":
            return .freezer
        case "pantry":
            return .pantry
        default:
            return .unsorted
        }
    }
    
    static func selectedSegment(segmentedControl: UISegmentedControl) -> FoodStorageType {

        
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            return .unsorted
        case 1:
            return .fridge
        case 2:
            return .freezer
        case 3:
            return .pantry
        default:
            return .unsorted
        }
    }
    
    static func isUnsortedSegmentNeeded(types: [FoodStorageType]) -> Bool {
        for t in types {
            if t == .unsorted {
                return true
            }
        }
        return false
    }
}

