//
//  String-Extension.swift
//  smartList
//
//  Created by Steven Dito on 8/10/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

extension String {
    
    func getLastPartOfSearchForQuery() -> String {
        guard self != "" else { return self }
        let reversed = self.reversed()
        var ending = ""
        
        for char in reversed {
            if char != "," && char != "\"" {
                ending.insert(char, at: ending.startIndex)
            } else {
                return ending.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        
        return ending.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func updateSearchText(newItem: String) -> String {
        let updatedNewItem: String = newItem.contains(",") ? "\"\(newItem)\"" : newItem
        var parts = self.splitCommaAndQuotes()
        if parts.count == 1 {
            return "\(updatedNewItem), "
        } else {
            parts.removeLast(1)
            parts.append(updatedNewItem)
            let txt = parts.joined(separator: ", ")
            return "\(txt), "
        }
    }
    
    func splitCommaAndQuotes() -> [String] {
        var results: [String] = []
        let quote = "\""
        let comma = ","
        var quoteOpen = false
        var currString = ""
        
        for c in self {
            let char = "\(c)"
            if char == quote {
                if quoteOpen {
                    results.append(currString)
                    quoteOpen = false
                    currString = ""
                } else {
                    quoteOpen = true
                    if currString != "" {
                        results.append(currString)
                        currString = ""
                    }
                }
            } else if char == comma {
                if !quoteOpen {
                    if currString != "" {
                        results.append(currString)
                        currString = ""
                    }
                } else {
                    currString.append(char)
                }
            } else {
                if currString == "" {
                    if char != " " {
                        currString.append(char)
                    }
                } else {
                    currString.append(char)
                }
            }
        }
        
        if currString != "" {
            results.append(currString)
        }
        
        return results
    }
    
    func splitIngredientToNumberAndQuantity() -> (wholeNumber: String?, fraction: String?, quantity: String) {
        var idx: String.Index {
            let one = self.firstIndex(where: {$0.isLetter})
            if one != nil {
                return one!
            } else {
                return self.endIndex
            }
        }
            
        let numberString = String(self[self.startIndex..<idx])
        let numberParts = numberString.split(separator: " ").map({String($0)})
        let endPart = String(self[idx...])
        if numberParts.count == 0 {
            return (nil, nil, self)
        } else if numberParts.count == 1 {
            let part = numberParts[0]
            if part.contains("/") {
                return ("0", part, endPart)
            } else {
                return (part, nil, endPart)
            }
            
        } else if numberParts.count == 2 {
            
            return (numberParts[0], numberParts[1], endPart)
        } else {
            return (nil, nil, self)
        }
    }
    
    func getMeasurement(wholeNumber: String?, fraction: String?) -> String {
        
        var isPlural: Bool {
            if wholeNumber == "0" || (wholeNumber == "1" && (fraction == nil || fraction == "")) {
                return false
            } else {
                return true
            }
        }
        switch self {
        case "cup":
            switch isPlural {
            case true:
                return "cups"
            case false:
                return "cup"
            }
        case "can":
            switch isPlural {
            case true:
                return "cans"
            case false:
                return "can"
            }
        case "oz":
            switch isPlural {
            case true:
                return "ounces"
            case false:
                return "ounce"
            }
        case "gal":
            switch isPlural {
            case true:
                return "gallons"
            case false:
                return "gallon"
            }
        case "lb":
            switch isPlural {
            case true:
                return "pound"
            case false:
                return "pounds"
            }
        case "tsp":
            switch isPlural {
            case true:
                return "teaspoon"
            case false:
                return "teaspoons"
            }
        case "tbsp":
            switch isPlural {
            case true:
                return "tablespoons"
            case false:
                return "tablespoon"
            }
        case "bag":
            switch isPlural {
            case true:
                return "bags"
            case false:
                return "bag"
            }
        case "jar":
            switch isPlural {
            case true:
                return "jars"
            case false:
                return "jar"
            }
        case "box":
            switch isPlural {
            case true:
                return "boxes"
            case false:
                return "box"
            }
        case "bttl":
            switch isPlural {
            case true:
                return "bottles"
            case false:
                return "bottle"
            }
        case "pckg":
            switch isPlural {
            case true:
                return "packages"
            case false:
                return "package"
            }
        case "g":
            switch isPlural {
            case true:
                return "grams"
            case false:
                return "gram"
            }
        case "L":
            switch isPlural {
            case true:
                return "liters"
            case false:
                return "liter"
            }
        case "kg":switch isPlural {
        case true:
            return "kilograms"
        case false:
            return "kilogram"
        }
        default:
            return self
        }
    }
    
    func getPreviousMonth() -> String {
        var monthYear = self.split(separator: ".").map({Int($0)!})
        
        if monthYear[0] - 1 == 0 {
            monthYear[0] = 12
            monthYear[1] -= 1
        } else {
            monthYear[0] -= 1
        }
        
        return "\(monthYear[0]).\(monthYear[1])"
    }
    
    func getNextMonth() -> String {
        var monthYear = self.split(separator: ".").map({Int($0)!})
        
        if monthYear[0] + 1 == 13 {
            monthYear[0] = 1
            monthYear[1] += 1
        } else {
            monthYear[0] += 1
        }
        
        return "\(monthYear[0]).\(monthYear[1])"
    }
    
    func mealPlanReadRecipeHelper() -> MealPlanner.RecipeTransfer {
        let parts = self.components(separatedBy: "__")
        
        var metadata: String? {
            if parts.count >= 4 {
                return parts[3]
            } else {
                return nil
            }
        }
        return MealPlanner.RecipeTransfer(date: parts[0], id: parts[1], name: parts[2], metadata: metadata)
    }
    
    
    func getQuantityFromIngredient() -> (ingredient: String, quantity: String) {
        var ing: [String] = []
        var qua: [String] = []
    
//        var leftParen = false
        var doneWithQuantity = false
        
        let measurements = ["cup", "ounce", "pound", "gallon", "packet", "cups", "ounces", "pounds", "packets", "gallons", "teaspoon", "teaspoons", "tablespoons", "tablespoon", "clove", "cloves", "cubes", "cube", "package", "packages", "can", "cans", "pinch", "bottle", "bottles", "bag", "bags", "slice", "slices", "quarts", "quart", "box", "boxes", "fluid"]
        let words = self.split(separator: " ").map({String($0)})
        
        words.forEach { (word) in
            if !doneWithQuantity {
                if !word.containsLetters() {
                    qua.append(word)
                }
                
                else if word.contains("(") {
                    if word.contains(")") == false {
//                        leftParen = true
                    }
                    qua.append(word)
                } else if word.contains(")") {
//                    leftParen = false
                    qua.append(word)
                } else {
                    if measurements.contains(word.lowercased()) {
                        qua.append(word)
                    } else {
                        doneWithQuantity = true
                        ing.append(word)
                    }
                }
            } else {
                ing.append(word)
            }
        }
        
        var returnQuantity: String {
            if qua == [] {
                return ""
            } else {
                return qua.joined(separator: " ")
            }
        }
        
        if ing.isEmpty {
            return (self, "")
        } else {
            return (ing.joined(separator: " "), returnQuantity)
        }
        
    }
    
    func shortDateToDisplay() -> String {
        let parts = self.split(separator: ".").map({String($0)})
        let month = Month.monthFromInt(int: Int(parts[0])!).description
        let day = parts[1]
        return "\(month) \(day)"
    }
    
    func shortDateGetDateEnding() -> String {
        let parts = self.split(separator: ".").map({String($0)})
        if let day = Int(parts[1]) {
            return day.getMonthDayEnding()
        } else {
            return ""
        }
        
    }
    
    func shortDateToMonthYear() -> String {
        let parts = self.split(separator: ".").map({String($0)})
        let month = parts[0]
        let year = parts[2]
        return "\(month).\(year)"
    }
    
    func containsLetters() -> Bool {
        for char in self {
            if char.isLetter {
                return true
            }
        }
        return false
    }
    
    func sizeForText(font: UIFont) -> CGRect {
        let rect = NSString(string: self).boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return rect
    }
    
    func trimUntilText() -> String {
        guard let idx = self.firstIndex(where: {$0.isLetter}) else { return self }
        let str = String(self[idx...])
        return str
        
    }
    
    func getAmountForNewItem() -> String {
        guard let idx = self.firstIndex(where: {$0.isLetter}) else { return "" }
        let str = String(self[..<idx])
        return str
    }
    
    func trim() -> String {
          return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    func getBeginningAddress() -> String {
        guard let index = self.firstIndex(of: "@") else { return self }
        let range = self.startIndex..<index
        let str = String(self[range])
        return str
    }
    
    static func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    func resizedTo(_ size: String) -> String {
        var tempStr = self
        tempStr.removeLast(4)
        tempStr.append(contentsOf: "_\(size).jpg")
        return tempStr
    }
    
    func getNumbers() -> [Int] {
        var numbers: [Int] = []
        var currNumber: String = ""
        for char in self {
            if char.isNumber {
                currNumber.append(char)
            } else {
                if currNumber != "" {
                    numbers.append(Int(currNumber)!)
                    currNumber = ""
                }
            }
        }
        return numbers
    }
    
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
    
}


// MARK: Sequence
extension Sequence where Element == String {
    func removeBlanks() -> [String] {
        return self.filter({$0 != ""})
    }
    
    func changeRecipeIngredientScale(ratio: (Int, Int)) -> [String] {
        var newItems: [String] = []
        for item in self {
            var runningAmount: (Int, Int) = (0,0)
            // need to isolate the number part
            let idx = item.firstIndex{$0.isLetter || $0 == "("}
            if let idx = idx {
                let str = String(item[item.startIndex..<idx])
                let nums = str.split(separator: " ").map({String($0)})
                for num in nums {
                    if num.contains("/") {
                        let parts = num.split(separator: "/").map({String($0)})
                        if parts.count != 2 {
                            print("Too many numbers")
                        } else {
                            if let n = Int(parts[0]), let d = Int(parts[1]) {
                                
                                if runningAmount == (0,0) {
                                    runningAmount.0 = n
                                    runningAmount.1 = d
                                } else {
                                    let newDenominator = d * runningAmount.1
                                    let oldToNew = runningAmount.0 * d
                                    let newToNew = n * runningAmount.1
                                    let newNumerator = oldToNew + newToNew
                                    runningAmount.0 = newNumerator
                                    runningAmount.1 = newDenominator
                                }
                            }
                        }
                    } else {
                        if let number = Int(String(num)) {
                            if runningAmount == (0,0) {
                                runningAmount.0 = number
                                runningAmount.1 = 1
                            } else {
                                runningAmount.0 += (number * runningAmount.1)
                            }
                        } else {
                            print("Unable to cast to number: \(num)")
                        }
                    }
                }
                
                var newRatio = (runningAmount.0 * ratio.0, runningAmount.1 * ratio.1)
                
                for n in (2...10).reversed() {
                    if (newRatio.0 % n == 0) && (newRatio.1 % n == 0) {
                        newRatio.0 = newRatio.0 / n
                        newRatio.1 = newRatio.1 / n
                    }
                }
                // now with the new ratio, need to have the number in the string format
                // parts would be the whole number, and the remainder in a fraction
                var measurement: String {
                    if newRatio.1 == 1 {
                        return "\(newRatio.0)"
                    } else if newRatio.0 == newRatio.1 {
                        return ""
                    } else if newRatio.0 > newRatio.1 {
                        let whole = newRatio.0 / newRatio.1
                        let remainder = newRatio.0 % newRatio.1
                        if remainder == 0 {
                            return "\(whole)"
                        } else {
                            return "\(whole) \(remainder)/\(newRatio.1)"
                        }
                    } else if newRatio.0 < newRatio.1 {
                        return "\(newRatio.0)/\(newRatio.1)"
                    } else {
                        return ""
                    }
                }
                
                let range = item.startIndex..<idx
                
                var newString: String {
                    if measurement != "" {
                        return item.replacingCharacters(in: range, with: "\(measurement) ")
                    } else {
                        return item
                    }
                }
                
                newItems.append(newString)
                
            }
        }
        return newItems
    }
}



extension Optional where Wrapped == String {
    func plusOne() -> String? {
        guard let str = self else { return "-1" }
        guard let int = Int(str) else { return "-1" }
        return "\(int + 1)"
    }
    func minusOne() -> String? {
        guard let str = self else { return "-1" }
        guard let int = Int(str) else { return "-1" }
        return "\(int - 1)"
    }
}
