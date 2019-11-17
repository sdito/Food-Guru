//
//  String-Extension.swift
//  smartList
//
//  Created by Steven Dito on 8/10/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import Foundation

extension String {
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
    
    
    func getCookAndPrepTime() -> (cookTime: String, prepTime: String) {
        let leftPrepTimeRange = self.range(of: "aria-label=\"Prep time")!.upperBound
        let stringToFindRightSidePREP = String(self[leftPrepTimeRange...])
        let rightPrepTimeRange = stringToFindRightSidePREP.range(of: "\">")?.lowerBound
        let firstForNewString = stringToFindRightSidePREP.firstIndex(of: stringToFindRightSidePREP.first!)
        let prepTimeStringRange = firstForNewString!..<rightPrepTimeRange!
        let prepTimeString = String(stringToFindRightSidePREP[prepTimeStringRange])
        
        let leftCookPrepTimeRange = self.range(of: "aria-label=\"Cook time:")!.upperBound
        let stringToFindRightSideCOOK = String(self[leftCookPrepTimeRange...])
        let rightCookTimeRange = stringToFindRightSideCOOK.range(of: "\">")?.lowerBound
        let firstForNewStringCook = stringToFindRightSideCOOK.firstIndex(of: stringToFindRightSideCOOK.first!)
        let cookTimeStringRange = firstForNewStringCook!..<rightCookTimeRange!
        let cookTimeString = String(stringToFindRightSideCOOK[cookTimeStringRange])
        
        return (cookTimeString.filter({$0 != ":"}), prepTimeString.filter({$0 != ":"}))
    }
    
    func getServingsFromHTML() -> String {
        let leftSide = self.range(of: "<section class=\"adjustServings panel")!.upperBound
        let rightSide = self.range(of: "ul class=\"adjust-servings__form\"")!.lowerBound
        let range = leftSide..<rightSide
        let text = String(self[range])
        #error("not working right, need to pull the numbers that come before Servings")
        return text.filter({$0.isNumber})
    }
    
    func getTitleFromHTML() -> String {
        let leftSide = self.range(of: "<title>")!.upperBound
        let rightSide = self.range(of: "</title>")!.lowerBound
        let range = leftSide..<rightSide
        return String(self[range])
    }
    
    func getCaloriesFromHTML() -> String {
        let leftSide = self.range(of: "<span itemprop=\"calories\">")!.upperBound
        let rightSide = self.range(of: " calories;</span>")!.lowerBound
        let range = leftSide..<rightSide
        return String(self[range])
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


