//
//  SelectRecipeCell.swift
//  smartList
//
//  Created by Steven Dito on 2/8/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit




protocol SelectRecipeCellDelegate: class {
    func presentRecipeDetail(cookbookRecipe: CookbookRecipe?, recipe: Recipe?)
    func recipeToAdd(recipe: Any)
}




class SelectRecipeCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    weak var delegate: SelectRecipeCellDelegate!
    private var cbr: CookbookRecipe?
    private var r: Recipe?
    
    func setUI(recipe: Any) {
        if type(of: recipe) == CookbookRecipe.self {
            let cbr = recipe as! CookbookRecipe
            self.cbr = cbr
            titleLabel.text = cbr.name
        } else if type(of: recipe) == Recipe.self {
            let r = recipe as! Recipe
            self.r = r
            titleLabel.text = r.name
        }
        
        let gr = UILongPressGestureRecognizer(target: self, action: #selector(grSelector(gesture:)))
        
        self.addGestureRecognizer(gr)
    }
    
    @objc func grSelector(gesture: UIGestureRecognizer) {
        guard gesture.state == .began else { return }
        delegate.presentRecipeDetail(cookbookRecipe: cbr, recipe: r)
    }
    
    @IBAction func recipeSelected(_ sender: Any) {
        delegate.recipeToAdd(recipe: (cbr != nil) ? cbr as Any : r as Any)
    }
    
    
}
