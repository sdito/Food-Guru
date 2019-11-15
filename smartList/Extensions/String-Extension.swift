//
//  String-Extension.swift
//  smartList
//
//  Created by Steven Dito on 8/10/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import Foundation

extension String {
    func imagePathToDocID() -> String {
        let slashIndex = self.firstIndex(of: "/")!
        let periodIndex: String.Index = self.firstIndex(of: ".") ?? self.endIndex
        var str = self[slashIndex..<periodIndex]
        str.removeFirst()
        return String(str)
    }
    func seperateByNewLine() -> [String] {
        let lines = self.split {$0.isNewline}
        return lines.map({String($0)})
    }
    func buttonNameSearchType() -> SearchType {
        switch self {
        case "Select Ingredients":
            return .ingredient
        case "Recommended":
            return .other
        case "Breakfast":
            return .recipe
        case "Lunch":
            return .recipe
        case "Dinner":
            return .recipe
        case "Low Calorie":
            return .recipe
        case "Chicken":
            return .ingredient
        case "Pasta":
            return .ingredient
        case "Healthy":
            return .recipe
        case "Dessert":
            return .recipe
        case "Salad":
            return .recipe
        case "Beef":
            return .ingredient
        case "Seafood":
            return .recipe
        case "Casserole":
            return .recipe
        case "Vegetarian":
            return .recipe
        case "Vegan":
            return .recipe
        case "Italian":
            return .cuisine
        case "Snack":
            return .recipe
        case "Simple":
            return .other
        case "Quick":
            return .other
        case "Slow Cooker":
            return .recipe
        default:
            return .other
        }
    }
}

extension Sequence where Element == String {
    func removeBlanks() -> [String] {
        return self.filter({$0 != ""})
    }
    

}


