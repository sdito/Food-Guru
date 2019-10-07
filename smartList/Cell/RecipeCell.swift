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
    @IBOutlet weak var tagline: UILabel!
    
    func setUI(recipe: Recipe) {
        for subview in recipeImage.subviews {
            subview.removeFromSuperview()
        }
        
        title.text = recipe.name
        cuisine.text = recipe.cuisineType
        tagline.text = recipe.recipeType.joined(separator: ", ")
        recipeImage.layer.cornerRadius = 4.0
        recipeImage.clipsToBounds = true
        
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
    }
}

