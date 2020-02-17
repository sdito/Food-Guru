//
//  File.swift
//  smartList
//
//  Created by Steven Dito on 2/12/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import Foundation
import RealmSwift



class MPCookbookRecipe: CookbookRecipe {
    
    @objc dynamic var id: String = "" {
        didSet {
            
            write()
        }
    }
    @objc dynamic var date: String = ""
    
    func setUp(cookbookRecipe: CookbookRecipe, id: String, date: String) {
        self.setUp(name: cookbookRecipe.name, servings: cookbookRecipe.servings, cookTime: cookbookRecipe.cookTime, prepTime: cookbookRecipe.prepTime, calories: cookbookRecipe.calories, ingredients: cookbookRecipe.ingredients, instructions: cookbookRecipe.instructions, notes: cookbookRecipe.notes)
        self.id = id
        self.date = date
    }
    
    
    override func write() {
        print("Writing recipe to realm for MPCookbookRecipe")
        let realm = try! Realm()
        
        print(Realm.Configuration.defaultConfiguration.fileURL as Any)
        try! realm.write {
            realm.add(self)
        }
    }
    
}

