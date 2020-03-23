//
//  MealPlannerCell.swift
//  smartList
//
//  Created by Steven Dito on 2/23/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit



protocol MealPlannerCellDelegate: class {
    func cellSelected(recipe: MealPlanner.RecipeTransfer?, sender: UIView)
}



class MealPlannerCell: UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var buttonOutlet: UIButton!
    @IBOutlet weak var buttonHeight: NSLayoutConstraint!
    
    weak var delegate: MealPlannerCellDelegate!
    private var recipe: MealPlanner.RecipeTransfer?
    private var initial = true
    
    func setUI(recipe: MealPlanner.RecipeTransfer) {
        self.recipe = recipe
        title.text = recipe.name
        setUpInitialUI()
        initial = false
    }
    
    func setUpInitialUI() {
        if !SharedValues.shared.isPhone && initial == true {
            buttonHeight.isActive = false
            buttonOutlet.heightAnchor.constraint(equalToConstant: 25).isActive = true
            title.font = UIFont(name: "futura", size: 23)
        }
    }
    
    
    @IBAction func editMealPlanRecipePressed(_ sender: Any) {
        delegate.cellSelected(recipe: recipe, sender: buttonOutlet)
    }
    
    
}
