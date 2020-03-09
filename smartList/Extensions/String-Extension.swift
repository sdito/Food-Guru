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
        return MealPlanner.RecipeTransfer(date: parts[0], id: parts[1], name: parts[2])
    }
    
    
    func getQuantityFromIngredient() -> (ingredient: String, quantity: String) {
        var ing: [String] = []
        var qua: [String] = []
    
        var leftParen = false
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
                        leftParen = true
                    }
                    qua.append(word)
                } else if word.contains(")") {
                    leftParen = false
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
    func buttonNameSearchType() -> SearchType {
        switch self {
        case "Select Ingredients":
            return .ingredient
        case "Expiring":
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
    
    // MARK: URL recipe parse
    func getIngredientsFromString(ingredients: [String]) -> [String] {
        guard let range = self.range(of: "title=\"") else {
            let ridOfTitleIngredients = ingredients.filter({$0.last != ":"})
            return Array(Set(ridOfTitleIngredients))
        }
        let ingredientStartRange = range.upperBound
        let textAfterIngredientStart = String(self[ingredientStartRange...])
        let idx = textAfterIngredientStart.firstIndex(of: "\"")!
        var ingredient = String(textAfterIngredientStart[..<idx])
        ingredient = ingredient.replacingOccurrences(of: "&#39;", with: "'")
        let returnIngredients = ingredients + [ingredient]
        let returnText = String(textAfterIngredientStart[idx...])
        
        return returnText.getIngredientsFromString(ingredients: returnIngredients)
    }

    
    
    func getInstructionsFromString(instructions: [String]) -> [String] {
        guard let range = self.range(of: "\"recipe-directions__list--item\">") else {
            var toReturn: [String] = []
            instructions.forEach { (instruct) in
                let r = instruct.range(of: "\n")!.lowerBound
                let newInstruction = String(instruct[...r])
                toReturn.append(newInstruction.filter({!$0.isNewline}))
            }
            toReturn = toReturn.map({$0.replacingOccurrences(of: "&#39;", with: "'")})
            return toReturn
        }
        let instructionStartRange = range.upperBound
        let textAfterInstructionStart = String(self[instructionStartRange...])
        let idx = textAfterInstructionStart.firstIndex(of: "<")!
        let rightIndex = textAfterInstructionStart.range(of: "<")
        let instruction = String(textAfterInstructionStart[..<idx])
        let newStringRange = rightIndex!.upperBound...
        let newString = String(self[newStringRange])
        
        var instructionsToReturn: [String] {
            if instructions.contains(instruction) {
                return instructions
            } else {
                return instructions + [instruction]
            }
        }
        return newString.getInstructionsFromString(instructions: instructionsToReturn)
    }
    func getPrepTime() -> Int? {
        guard let leftPrepTimeRange = self.range(of: "aria-label=\"Prep time")?.upperBound else { return nil}
        let stringToFindRightSidePREP = String(self[leftPrepTimeRange...])
        let rightPrepTimeRange = stringToFindRightSidePREP.range(of: "\">")?.lowerBound
        let firstForNewString = stringToFindRightSidePREP.firstIndex(of: stringToFindRightSidePREP.first!)
        let prepTimeStringRange = firstForNewString!..<rightPrepTimeRange!
        let prepTimeString = String(stringToFindRightSidePREP[prepTimeStringRange])
        let prepTimeNums = prepTimeString.getNumbers()
        var prepTimeMinutes: Int? {
            if prepTimeNums.count == 1 {
                if prepTimeString.contains("H") {
                    return prepTimeNums.first! * 60
                } else {
                    return prepTimeNums.first!
                }
            } else if prepTimeNums.count == 2 {
                return (prepTimeNums[0] * 60) + prepTimeNums[1]
            } else {
                return nil
            }
        }
        return prepTimeMinutes
    }
    //, one with hours and minutes to test
    func getCookTime() -> Int? {

        guard let leftCookPrepTimeRange = self.range(of: "aria-label=\"Cook time:")?.upperBound else { return nil }
        let stringToFindRightSideCOOK = String(self[leftCookPrepTimeRange...])
        let rightCookTimeRange = stringToFindRightSideCOOK.range(of: "\">")?.lowerBound
        let firstForNewStringCook = stringToFindRightSideCOOK.firstIndex(of: stringToFindRightSideCOOK.first!)
        let cookTimeStringRange = firstForNewStringCook!..<rightCookTimeRange!
        let cookTimeString = String(stringToFindRightSideCOOK[cookTimeStringRange])
        let cookTimeNums = cookTimeString.getNumbers()
        var cookTimeMinutes: Int? {
            if cookTimeNums.count == 1 {
                if cookTimeString.contains("H") {
                    return cookTimeNums.first! * 60
                } else {
                    return cookTimeNums.first!
                }
                
            } else if cookTimeNums.count == 2 {
                return (cookTimeNums[0] * 60) + cookTimeNums[1]
            } else {
                return nil
            }
        }
        
        return cookTimeMinutes
    }
    
    func getServingsFromHTML() -> Int? {
        let leftSide = self.range(of: "<section class=\"adjustServings panel")!.upperBound
        let rightSide = self.range(of: "ul class=\"adjust-servings__form\"")!.lowerBound
        let range = leftSide..<rightSide
        let text = String(self[range])
        //#error("not working right, need to pull the numbers that come before Servings, also later need to convert everything to ints")
        
        let nums = text.getNumbers()
        return nums.first
    }
    
    func getTitleFromHTML() -> String {
        let leftSide = self.range(of: "<title>")!.upperBound
        let rightSide = self.range(of: "</title>")!.lowerBound
        let range = leftSide..<rightSide
        let str = String(self[range])
        let up = str.range(of: "Recipe - Allrecipes.com")
        let lower = str.startIndex
        let r = lower..<up!.lowerBound
        
        var finalRdOne = String(str[r])
        if !finalRdOne.contains("&#x27;") {
            return finalRdOne
        } else {
            finalRdOne = finalRdOne.replacingOccurrences(of: "&#x27;", with: "'")
            return finalRdOne
        }
        
    }
    func getCaloriesFromHTML() -> Int? {
        let leftSide = self.range(of: "<span itemprop=\"calories\">")!.upperBound
        let rightSide = self.range(of: " calories;</span>")!.lowerBound
        let range = leftSide..<rightSide
        return Int(String(self[range]))
    }
    func getIngredientsFromHTML_ARTWO() -> [String] {
        var ingredients: [String] = []
        var ingredientBeingAddedNow = false
        var currentIngredient: String = ""
        for char in self {
            switch ingredientBeingAddedNow {
            case true:
                if char == "\"" {
                    ingredients.append(currentIngredient)
                    currentIngredient = ""
                    ingredientBeingAddedNow = false
                } else {
                    currentIngredient.append(char)
                }
            case false:
                if char == "\"" {
                    ingredientBeingAddedNow = true
                }
            }
        }
        return ingredients
    }

    func getInstructionsFromHTML_ARTWO(_ currInstructions: [String] = []) -> [String]? {
        guard let leftStartIndex = self.range(of: "\"HowToStep\",\"text\":\"")?.upperBound else {
            return currInstructions
        }
        let newStringRange = leftStartIndex...
        let newString = String(self[newStringRange])
        var instruction: String = ""
        for char in newString {
            if char != "\"" {
                instruction.append(char)
            } else {
                let rangeOfNewInstruction = newString.range(of: instruction)!.upperBound
                let returnString = String(newString[rangeOfNewInstruction...])
                return returnString.getInstructionsFromHTML_ARTWO(currInstructions + [instruction])
            }
        }
        return nil
    }
    
    func getServingsFromHTML_ARTWO() -> Int? {
        let leftSide = self.range(of: "serving\">Original recipe")!.upperBound
        let rightSide = self.range(of: "servings</div>")!.lowerBound
        let range = leftSide..<rightSide
        let text = String(self[range])
        let nums = text.getNumbers()
        return nums.first
    }
    
    func getCookTimeARTWO() -> Int? {
        guard let cookLeftSide = self.range(of: "\"cookTime\":\"")?.upperBound else { return nil }
        guard let cookRightSide = self.range(of: "\",\"totalTime\":")?.lowerBound else { return nil }
        let cookRange = cookLeftSide..<cookRightSide
        let cookText = String(self[cookRange])
        return cookText.getMinutesFromString_ARTWO()
    }
    func getPrepTimeARTWO() -> Int? {
        guard let prepLeftSide = self.range(of: "\"prepTime\":\"")?.upperBound else { return nil }
        guard let prepRightSide = self.range(of: "\",\"cookTime\":")?.lowerBound else { return nil }
        let prepRange = prepLeftSide..<prepRightSide
        let prepText = String(self[prepRange])
        return prepText.getMinutesFromString_ARTWO()
    }
    
    
    func getMinutesFromString_ARTWO() -> Int {
        let hasHours = self.contains("H")
        let nums = self.getNumbers()
        
        if nums.count == 1 {
            if hasHours == true {
                return nums.first! * 60
            } else {
                return nums.first!
            }
        } else {
            return (nums[0] * 60) + nums[1]
        }
    }
    
    func getCaloriesFromHTML_ARTWO() -> Int? {
        let left = self.range(of: "\"calories\":\"")!.upperBound
        let right = self.range(of: "calories\",\"carbohydrateContent")!.lowerBound
        let range = left..<right
        let str = String(self[range])
        return Int(str.filter({$0.isNumber}))
    }
    // MARK: End URL parse
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
                            print("Unable to cast to number")
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
