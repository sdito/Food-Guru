//
//  MealPlannerCell.swift
//  smartList
//
//  Created by Steven Dito on 2/23/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit



protocol MealPlannerCellDelegate: class {
    func cellSelected(recipe: MealPlanner.RecipeTransfer?)
}



class MealPlannerCell: UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    
    weak var delegate: MealPlannerCellDelegate!
    private var recipe: MealPlanner.RecipeTransfer?
    
    func setUI(recipe: MealPlanner.RecipeTransfer) {
        self.recipe = recipe
        title.text = recipe.name
    }
    
    
    @IBAction func editMealPlanRecipePressed(_ sender: Any) {
        delegate.cellSelected(recipe: recipe)
    }
    
    
}
