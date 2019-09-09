//
//  RecipeShowCell.swift
//  smartList
//
//  Created by Steven Dito on 9/7/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import UIKit

class RecipeShowCell: UITableViewCell {
    @IBOutlet weak var recipeImage: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var cuisine: UILabel!
    @IBOutlet weak var recipeDescription: UILabel!
    
    
    func setUI(recipe: Recipe) {
        title.text = recipe.name
        cuisine.text = recipe.cuisineType
        recipeDescription.text = recipe.recipeType.joined(separator: ", ")
        recipe.getImageFromStorage { (img) in
            self.recipeImage.image = img
        }
    }

}
