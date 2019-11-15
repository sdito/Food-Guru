//
//  VisionDocumentText-Extension.swift
//  smartList
//
//  Created by Steven Dito on 11/14/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import Foundation
import Firebase


extension VisionDocumentText {
    func tryToGetRecipeInfo() {
        let blocks = self.blocks.map({$0.text.lowercased()})
        var ingredientsSeen = false
        var instructionsSeen = false
        
        let wordsForIngredients = ["ingredients", "you will need"]
        let wordsForInstructions = ["instruction", "method", "directions", "to prepare"]
        
        var firstRunIngredients: [String] = []
        var firstRunInstructions: [String] = []
        /*
         - could look for the word "serves" for the number in it
         - some recipes might have the instruction number and the ingredient in a different block
         - some recipes might have all the instructions or ingredients in the same block
        */
        
        for block in blocks {
            switch (ingredientsSeen, instructionsSeen) {
            case (false, false):
                print("false, false")
                wordsForIngredients.forEach { (ingredient) in
                    if block.contains(ingredient) {
                        firstRunIngredients.append(block)
                        ingredientsSeen = true
                    } else {
                    }
                }
            case (true, false):
                print("true, false")
                wordsForInstructions.forEach { (instruction) in
                    if block.contains(instruction) {
                        firstRunInstructions.append(block)
                        instructionsSeen = true
                    }
                }
            case (false, true):
                print("false, true")
            case (true, true):
                print("true, true")
                firstRunInstructions.append(block)
            }
        }
        
        
        var secondRunIngredients: [String] {
            for block in firstRunIngredients {
                //let split = block.split by \n
            }
        }
        
        
        
        
        print()
        print()
        print("Ingredient blocks: \(firstRunIngredients)")
        print()
        print("Instruction blocks: \(firstRunInstructions)")
        print()
        print()
    }
}
