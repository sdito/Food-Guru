//
//  RecipeCell.swift
//  smartList
//
//  Created by Steven Dito on 9/28/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import UIKit

class RecipeCell: UICollectionViewCell {
    @IBOutlet weak var recipeImage: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var cuisine: UILabel!
    @IBOutlet weak var recipeDescription: UILabel!
    
    func setUI(recipe: Recipe) {
        title.text = recipe.name
        cuisine.text = recipe.cuisineType
        recipeDescription.text = recipe.recipeType.joined(separator: ", ")
    }
}

