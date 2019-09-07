//
//  RecipeShowCell.swift
//  smartList
//
//  Created by Steven Dito on 9/6/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import UIKit

class RecipeShowCell: UICollectionViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var cuisine: UILabel!
    @IBOutlet weak var recipeDescription: UILabel!
    
    
    func setUI(recipe: Recipe) {
        title.text = recipe.name
        
        cuisine.text = recipe.cuisineType
        recipeDescription.text = recipe.recipeType.joined(separator: " - ")
        recipe.getImageFromStorage { (img) in
            self.image.image = img
        }
        //image.clipsToBounds = true
        //image.layer.cornerRadius = 10
        image.addShadow(offset: CGSize.init(width: 0, height: 3), color: UIColor.black, radius: 2.0, opacity: 0.35)
        
    }
    
}
