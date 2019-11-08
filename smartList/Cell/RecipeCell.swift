//
//  RecipeCell.swift
//  smartList
//
//  Created by Steven Dito on 9/28/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import UIKit



protocol RecipeCellDelegate {
    func addToFavorites(recipe: Recipe?)
    func removeFromFavorites(recipe: Recipe?)
}




class RecipeCell: UICollectionViewCell {
    
    var delegate: RecipeCellDelegate!
    
    var selectionState: Bool = false {
        didSet {
            switch self.selectionState {
            case true:
                delegate.addToFavorites(recipe: recipe)
            case false:
                delegate.removeFromFavorites(recipe: recipe)
            }
        }
    }
    
    private var recipe: Recipe?
    @IBOutlet weak var recipeImage: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var cuisine: UILabel!
    @IBOutlet weak var tagline: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    
    func setUI(recipe: Recipe) {
        self.recipe = recipe
        for subview in recipeImage.subviews {
            subview.removeFromSuperview()
        }
        
        title.text = recipe.name
        cuisine.text = recipe.cuisineType
        tagline.text = recipe.recipeType.joined(separator: ", ")
        recipeImage.layer.cornerRadius = 4.0
        recipeImage.clipsToBounds = true
        favoriteButton.layer.cornerRadius = favoriteButton.frame.size.height/2
        favoriteButton.clipsToBounds = true
        
        if let stars = recipe.numStars, let reviews = recipe.numReviews {
            let v = Bundle.main.loadNibNamed("StarRatingView", owner: nil, options: nil)?.first as! StarRatingView
            v.translatesAutoresizingMaskIntoConstraints = false
            v.setUI(rating: Double(stars) / Double(reviews), nReviews: reviews)
            v.layer.cornerRadius = 4
            v.clipsToBounds = true
            //v.widthAnchor.constraint(equalToConstant: 100).isActive = true
            recipeImage.insertSubview(v, at: 1)
        }
        
        
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

        
    }
    
    
    @objc func favoriteButtonPressed() {
        
        // use shared values to store the saved recipes (image path) for the user (with a listener)
        // if the image path is in shared recipes, then it is selected, else it is not selected
        // only way the selection state of the button changes is from if it is in shared values
        
    }
    
}

