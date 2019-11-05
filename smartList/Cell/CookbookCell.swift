//
//  CookbookCell.swift
//  smartList
//
//  Created by Steven Dito on 11/4/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import UIKit

class CookbookCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    
    func setUI(recipe: CookbookRecipe) {
        nameLabel.text = recipe.name
    }

}
