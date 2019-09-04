//
//  Recipe.swift
//  smartList
//
//  Created by Steven Dito on 8/24/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

struct Recipe {
    var name: String
    var recipeType: [String]
    var cuisineType: String
    var cookTime: Int
    var prepTime: Int
    var ingredients: [String]
    var instructions: [String]
    var calories: Int?
    var numServes: Int
    var userID: String?
    var numReviews: Int?
    var numStars: Int?
    var notes: String?
    
    init(name: String, recipeType: [String], cuisineType: String, cookTime: Int, prepTime: Int, ingredients: [String], instructions: [String], calories: Int?, numServes: Int, userID: String?, numReviews: Int?, numStars: Int?, notes: String?) {
        self.name = name
        self.recipeType = recipeType
        self.cuisineType = cuisineType
        self.cookTime = cookTime
        self.prepTime = prepTime
        self.ingredients = ingredients
        self.instructions = instructions
        self.calories = calories
        self.numServes = numServes
        self.userID = userID
        self.numReviews = numReviews
        self.numStars = numStars
        self.notes = notes
    }
    
    static func readRecipes(db: Firestore!, ingredients: [String]?, type: [String]?, user: String?) -> [Recipe]? {
        var recipies: [Recipe]?
        
        // all nil
        if ingredients == nil && type == nil && user == nil {
            return nil
        } else if ingredients == nil && type == nil {
            db.collection("recipes").whereField("user", isEqualTo: user as Any).getDocuments() {(QuerySnapshot, err) in
                if let err = err {
                    print("Error reading documents: \(err)")
                } else {
                    for doc in QuerySnapshot!.documents {
                        let d = Recipe(name: doc.get("name") as! String, recipeType: doc.get("recipeType") as! [String], cuisineType: doc.get("cuisineType") as! String, cookTime: doc.get("cookTime") as! Int, prepTime: doc.get("prepTime") as! Int, ingredients: doc.get("ingredients") as! [String], instructions: doc.get("instructions") as! [String], calories: doc.get("calories") as? Int, numServes: doc.get("numServes") as! Int, userID: doc.get("userID") as? String, numReviews: doc.get("numReviews") as? Int, numStars: doc.get("numStars") as? Int, notes: doc.get("notes") as? String)
                        if recipies == nil {
                            recipies = [d]
                        } else {
                            recipies!.append(d)
                        }
                    }
                }
            }
        } else if ingredients == nil && type != nil && user == nil {
            
        } else if ingredients != nil && type == nil && user == nil {
            
        } else if ingredients == nil && type != nil && user != nil {
            
        } else if ingredients != nil && type == nil && user != nil {
            
        } else if ingredients != nil && type != nil && user == nil {
            
        } else if ingredients != nil && type != nil && user != nil {
            
        } else {
            print("Missing one of the combinations for recipie search")
        }
        return recipies
    }

}



extension Recipe {
    func writeToFirestore(db: Firestore!) {
        let doc = db.collection("recipes").document()
        doc.setData([
            "name": self.name,
            "recipeType": self.recipeType,
            "cuisineType": self.cuisineType,
            "cookTime": self.cookTime,
            "prepTime": self.prepTime,
            "ingredients": self.ingredients,
            "instructions": self.instructions,
            "calories": self.calories as Any,
            "numServes": self.numServes,
            "userID": self.userID as Any,
            "numReviews": self.numReviews as Any,
            "numStars": self.numStars as Any,
            "notes": self.notes as Any
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written")
            }
        }
    }
}
