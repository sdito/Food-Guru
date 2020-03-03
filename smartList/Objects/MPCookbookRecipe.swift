//
//  File.swift
//  smartList
//
//  Created by Steven Dito on 2/12/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import Foundation
import RealmSwift
import FirebaseFirestore



class MPCookbookRecipe: CookbookRecipe {

    @objc dynamic var id: String = ""
    @objc dynamic var date: String = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    override func write() {
        print("Writing recipe to realm for MPCookbookRecipe")
        let realm = try! Realm()
        
        try! realm.write {
            realm.add(self)
        }
    }
    
    func set(cookbookRecipe: CookbookRecipe, date: String) {
        setUp(name: cookbookRecipe.name, servings: cookbookRecipe.servings, cookTime: cookbookRecipe.cookTime, prepTime: cookbookRecipe.prepTime, calories: cookbookRecipe.calories, ingredients: cookbookRecipe.ingredients, instructions: cookbookRecipe.instructions, notes: cookbookRecipe.notes)
        self.date = date
    }
    
    func toCookbookRecipe() -> CookbookRecipe {
        let cbr = CookbookRecipe()
        cbr.setUp(name: self.name, servings: self.servings, cookTime: self.cookTime, prepTime: self.prepTime, calories: self.calories, ingredients: self.ingredients, instructions: self.instructions, notes: self.notes)
        return cbr
    }
    
}


extension DocumentSnapshot {
    func getMPCookbookRecipe() -> MPCookbookRecipe {
        // need to use this in MealPlanner recipe to add new recipes from user's document
        let recipe = MPCookbookRecipe()
        let servings = RealmOptional.init(self.get("numServes") as? Int)
        let cookTime = RealmOptional.init(self.get("cookTime") as? Int)
        let prepTime = RealmOptional.init(self.get("prepTime") as? Int)
        let calories = RealmOptional.init(self.get("calories") as? Int)
        let ingredients = self.get("ingredients") as! [String]
        let realmIngredients = List<String>()
        for i in ingredients {
            realmIngredients.append(i)
        }
        let instructions = self.get("instructions") as! [String]
        let realmInstructions = List<String>()
        for i in instructions {
            realmInstructions.append(i)
        }
        
        recipe.setUp(name: self.get("name") as! String, servings: servings, cookTime: cookTime, prepTime: prepTime, calories: calories, ingredients: realmIngredients, instructions: realmInstructions, notes: self.get("notes") as? String)
        recipe.date = self.get("date") as! String
        recipe.id = self.get("ownID") as! String
        
        return recipe
    }
}




class UserDevice: Object {
    @objc dynamic var uid: String = ""
}
