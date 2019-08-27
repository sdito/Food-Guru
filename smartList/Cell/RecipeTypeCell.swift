//
//  RecipeTypeCell.swift
//  smartList
//
//  Created by Steven Dito on 8/26/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import UIKit

class RecipeTypeCell: UITableViewCell {
    
    @IBOutlet weak var typeLabel: UILabel!
    
    func setUI(type: String) {
        typeLabel.text = type
        
        if self.isSelected == true {
            typeLabel.textColor = Colors.main
            self.accessoryType = .checkmark
        } else {
            typeLabel.textColor = .black
            self.accessoryType = .none
        }
    }
    
}
