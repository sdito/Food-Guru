//
//  RecipeCell.swift
//  smartList
//
//  Created by Steven Dito on 9/28/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth



class RecipeCell: UICollectionViewCell {
    
    @IBOutlet weak var recipeImage: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var tagline: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    
    private var recipe: Recipe?

    func setUI(recipe: Recipe) {
        self.recipe = recipe
        for subview in recipeImage.subviews {
            subview.removeFromSuperview()
        }
        
        title.text = recipe.name
        tagline.text = recipe.tagline
        recipeImage.layer.cornerRadius = 4.0
        recipeImage.clipsToBounds = true
        favoriteButton.layer.cornerRadius = favoriteButton.frame.size.height/2
        favoriteButton.clipsToBounds = true

        // image set from RecipeHomeVC for easier control of cache
        self.contentView.layer.cornerRadius = 4.0
        self.contentView.layer.borderWidth = 1.0
        self.contentView.layer.borderColor = UIColor.clear.cgColor
        self.contentView.layer.masksToBounds = true

        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        self.layer.shadowRadius = 2.0
        self.layer.shadowOpacity = 0.5
        self.layer.masksToBounds = false
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.contentView.layer.cornerRadius).cgPath
        
        
        favoriteButton.addTarget(self, action: #selector(favoriteButtonPressed), for: .touchUpInside)
        
        
        if SharedValues.shared.savedRecipes?.contains("\(recipe.djangoID)") ?? false {
            self.favoriteButton.backgroundColor = Colors.main
        } else {
            self.favoriteButton.backgroundColor = Colors.systemGray
        }
        
    }
    // MARK: Button pressed
    @objc func favoriteButtonPressed() {
        let db = Firestore.firestore()
        
        if let recipe = self.recipe {
            if SharedValues.shared.savedRecipes?.contains("\(recipe.djangoID)") ?? false {
                Recipe.removeRecipeFromSavedRecipes(db: db, recipe: recipe)
                self.recipe?.removeRecipeDocumentFromUserProfile(db: db)
            } else {
                Recipe.addRecipeToSavedRecipes(db: db, recipe: recipe)
                self.recipe?.addRecipeDocumentToUserProfile(db: db)
            }
        }
        
        
        
    }
    
}

