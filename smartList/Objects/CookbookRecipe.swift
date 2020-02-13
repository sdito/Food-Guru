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
    var systemItems = List<String>()
    @objc dynamic var notes: String? = nil
    
    func setUp(name: String, servings: RealmOptional<Int>, cookTime: RealmOptional<Int>, prepTime: RealmOptional<Int>, calories: RealmOptional<Int>, ingredients: List<String>, instructions: List<String>, notes: String?) {
        
        self.name = name
        self.servings = servings
        self.cookTime = cookTime
        self.prepTime = prepTime
        self.calories = calories
        self.ingredients = ingredients
        self.instructions = instructions
        self.notes = notes
        
        var gis:[GenericItem] = []
        for ingredient in ingredients {
            let genericItem = Search.turnIntoSystemItem(string: ingredient)
            gis.append(genericItem)
        }
        let gisString: [String] = gis.map({"has_\($0)"})
        gisString.forEach { (str) in
            systemItems.append(str)
        }
    }
    
    func write() {
        let realm = try! Realm()
        try! realm.write {
            realm.add(self)
        }
    }
    func delete() {
        let realm = try! Realm()
        try? realm.write {
            realm.delete(self)
        }
    }
    
    
    // MARK: UI
    // Used to set up the UI for when the recipe is in cookbook rather than a regular recipe
    func addButtonIngredientViewsTo(stackView: UIStackView, delegateVC: UIViewController) {
        for item in self.ingredients {
            let v = Bundle.main.loadNibNamed("ButtonIngredientView", owner: nil, options: nil)?.first as! ButtonIngredientView
            
            v.setUI(ingredient: item)
            v.delegate = delegateVC as? ButtonIngredientViewDelegate
            stackView.insertArrangedSubview(v, at: 1)
        }
    }
    
    // Used to set up the UI for when the recipe is in cookbook rather than a regular recipe
    func addInstructionsToInstructionStackView(stackView: UIStackView) {
        var counter = 1
        for item in self.instructions {
            let v = Bundle.main.loadNibNamed("LabelInstructionView", owner: nil, options: nil)?.first as! LabelInstructionView
            v.setUI(num: counter, instr: item)
            stackView.insertArrangedSubview(v, at: stackView.subviews.count)
            counter += 1
        }
    }
    
}
