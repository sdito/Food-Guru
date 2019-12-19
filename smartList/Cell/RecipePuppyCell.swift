//
//  RecipePuppyCell.swift
//  smartList
//
//  Created by Steven Dito on 12/19/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import UIKit



#warning("do i need class here also")
protocol RecipePuppyCellDelegate: class {
    func urlPressed(url: URL)
}


class RecipePuppyCell: UITableViewCell {
    private var recipeUrl: URL?
    weak var delegate: RecipePuppyCellDelegate!
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var ingredients: UILabel!
    @IBOutlet weak var link: UIButton!
    
    
    func setUI(recipe: Recipe.Puppy) {
        title.text = recipe.title
        ingredients.text = recipe.ingredients
        
        if let url = recipe.url {
            link.setTitle("\(url)", for: .normal)
            recipeUrl = url
        }
    }

    @IBAction func linkButtonPressed(_ sender: Any) {
        if let recipeUrl = recipeUrl {
            delegate.urlPressed(url: recipeUrl)
        }
        
    }
}
