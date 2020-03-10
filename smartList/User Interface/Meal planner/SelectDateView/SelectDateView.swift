//
//  SelectDateView.swift
//  smartList
//
//  Created by Steven Dito on 3/4/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit
import Foundation



protocol SelectDateViewDelegate: class {
    func dateSelected(date: Date, recipe: MealPlanner.RecipeTransfer?, copyRecipe: Bool)
}



class SelectDateView: UIView {
    
    @IBOutlet weak var recipeNameLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var copyRecipe = false
    weak var delegate: SelectDateViewDelegate!
    private var recipe: MealPlanner.RecipeTransfer?
    
    func setUI(recipe: MealPlanner.RecipeTransfer, copyRecipe: Bool) {
        self.recipe = recipe
        self.copyRecipe = copyRecipe
        recipeNameLabel.text = "Change date for \(recipe.name)"
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        // send the new value to the delegate, then dismiss
        delegate.dateSelected(date: datePicker.date, recipe: recipe, copyRecipe: copyRecipe)
        
        self.findViewController()?.dismiss(animated: true, completion: nil)
    }
    
}
