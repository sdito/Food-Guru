//
//  String-Extension.swift
//  smartList
//
//  Created by Steven Dito on 8/10/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import Foundation

extension String {
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
    func getIngredientsFromString(ingredients: [String]) -> [String] {
        guard let range = self.range(of: "title=\"") else {
            return Array(Set(ingredients))
        }
        let ingredientStartRange = range.upperBound
        let textAfterIngredientStart = String(self[ingredientStartRange...])
        let idx = textAfterIngredientStart.firstIndex(of: "\"")!
        let rightIndex = textAfterIngredientStart.range(of: "\"")
        let ingredient = String(textAfterIngredientStart[..<idx])
        let newStringRange = rightIndex!.upperBound...
        let newString = String(self[newStringRange])
        return newString.getIngredientsFromString(ingredients: ingredients + [ingredient])
    }
    
    
    func getInstructionsFromString(instructions: [String]) -> [String] {
        guard let range = self.range(of: "\"recipe-directions__list--item\">") else {
            var toReturn: [String] = []
            instructions.forEach { (instruct) in
                let r = instruct.range(of: "\n")!.lowerBound
                let newInstruction = String(instruct[...r])
                toReturn.append(newInstruction.filter({!$0.isNewline}))
            }
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
    
    //, one with hours and minutes to test
    func getCookAndPrepTime() -> (cookTime: Int?, prepTime: Int?) {
        let leftPrepTimeRange = self.range(of: "aria-label=\"Prep time")!.upperBound
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
        
        
        let leftCookPrepTimeRange = self.range(of: "aria-label=\"Cook time:")!.upperBound
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
        
        return (cookTimeMinutes, prepTimeMinutes)
    }
    
    func getServingsFromHTML() -> Int? {
        let leftSide = self.range(of: "<section class=\"adjustServings panel")!.upperBound
        let rightSide = self.range(of: "ul class=\"adjust-servings__form\"")!.lowerBound
        let range = leftSide..<rightSide
        let text = String(self[range])
        //#error("not working right, need to pull the numbers that come before Servings, also later need to convert everything to ints")
        
        let nums = text.getNumbers()
        return nums.first
//        let secondLeftSide = text.range(of: "yields ")!.upperBound
//        let newStringForManipulation = text[secondLeftSide...]
//
//        let firstOfNewString = newStringForManipulation.firstIndex(of: newStringForManipulation.first!)!
//        let endOfServingNumber = newStringForManipulation.firstIndex(of: " ")!
//
//        let secondRange = firstOfNewString..<endOfServingNumber
//        let secondText = String(text[secondRange])
//
//        return secondText.filter({$0.isNumber})
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
    //        ","prepTime":"PT15M","cookTime":"PT7H","totalTime":"PT7H15M","
    func getCookAndPrepTimeFromHTML_ARTWO() -> (cook: Int, prep: Int) {
        let cookLeftSide = self.range(of: "\"cookTime\":\"")!.upperBound
        let cookRightSide = self.range(of: "\",\"totalTime\":")!.lowerBound
        let cookRange = cookLeftSide..<cookRightSide
        let cookText = String(self[cookRange])
        
        
        let prepLeftSide = self.range(of: "\"prepTime\":\"")!.upperBound
        let prepRightSide = self.range(of: "\",\"cookTime\":")!.lowerBound
        let prepRange = prepLeftSide..<prepRightSide
        let prepText = String(self[prepRange])
        
        
        return (cookText.getMinutesFromString_ARTWO(), prepText.getMinutesFromString_ARTWO())
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


