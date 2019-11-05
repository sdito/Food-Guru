//
//  CookbookRecipe.swift
//  smartList
//
//  Created by Steven Dito on 11/3/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import Foundation
import RealmSwift
import Realm

class CookbookRecipe: Object {
    @objc dynamic var name: String = ""
    var servings = RealmOptional<Int>()
    var cookTime = RealmOptional<Int>()
    var prepTime = RealmOptional<Int>()
    var calories = RealmOptional<Int>()
    var ingredients = List<String>()
    var instructions = List<String>()
    @objc dynamic var notes: String? = nil
    
//    convenience init(name: String, servings: RealmOptional<Int>, cookTime: RealmOptional<Int>, prepTime: RealmOptional<Int>, calories: RealmOptional<Int>, ingredients: List<String>, instructions: List<String>, notes: String?) {
//        self.init()
//        self.name = name
//        self.servings = servings
//        self.cookTime = cookTime
//        self.prepTime = prepTime
//        self.calories = calories
//        self.ingredients = ingredients
//        self.instructions = instructions
//        self.notes = notes
//    }
    
    func setUp(name: String, servings: RealmOptional<Int>, cookTime: RealmOptional<Int>, prepTime: RealmOptional<Int>, calories: RealmOptional<Int>, ingredients: List<String>, instructions: List<String>, notes: String?) {
        self.name = name
        self.servings = servings
        self.cookTime = cookTime
        self.prepTime = prepTime
        self.calories = calories
        self.ingredients = ingredients
        self.instructions = instructions
        self.notes = notes
    }
    
//    required init() {
//        fatalError("init() has not been implemented")
//    }
//
//    required init(realm: RLMRealm, schema: RLMObjectSchema) {
//        fatalError("init(realm:schema:) has not been implemented")
//    }
//
//    required init(value: Any, schema: RLMSchema) {
//        fatalError("init(value:schema:) has not been implemented")
//    }
    
   
    
}
