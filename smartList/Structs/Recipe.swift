//
//  Recipe.swift
//  smartList
//
//  Created by Steven Dito on 8/24/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import Foundation
import FirebaseFirestore


struct Recipe {
    var name: String
    var type: [String]
    var cookTime: Int
    var prepTime: Int
    var ingredients: [String]
    var instructions: [String]
    var calories: Int
    var id: String?
    
    init(name: String, type: [String], cookTime: Int, prepTime: Int, ingredients: [String], instructions: [String], calories: Int, id: String?) {
        self.name = name
        self.type = type
        self.cookTime = cookTime
        self.prepTime = prepTime
        self.ingredients = ingredients
        self.instructions = instructions
        self.calories = calories
        self.id = id
    }
    
    static func readRecipes() {
        
    }
    
}



extension Recipe {
    mutating func writeToFirestore(db: Firestore!) {
        let doc = db.collection("recipe").document()
        self.id = doc.documentID
        doc.setData([
            "name": self.name,
            "type": self.type,
            "cookTime": self.cookTime,
            "prepTime": self.prepTime,
            "ingredients": self.ingredients,
            "instructions": self.instructions,
            "calories": self.calories
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written")
            }
        }
    }
}
