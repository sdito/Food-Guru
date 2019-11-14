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
    @IBOutlet weak var amountIngredients: UILabel!
    
    func setUI(recipe: CookbookRecipe, systemItems: [String]) {
        var useSystemItems = systemItems.map({"has_\($0)"})
        useSystemItems.removeAll(where: {$0 == "has_other"})
        nameLabel.text = recipe.name
        
        var countHave = 0
        recipe.systemItems.forEach { (str) in
            if useSystemItems.contains("\(str)") {
                countHave += 1
            }
        }
        
        amountIngredients.text = "\(countHave) / \(recipe.systemItems.count)"
    }

}
