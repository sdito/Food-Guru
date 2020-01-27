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
    
    func setUI(type: String, set: Set<String>?) {
        typeLabel.text = type
        
        if set?.contains(type) ?? false {
            typeLabel.textColor = Colors.main
            self.accessoryType = .checkmark
        } else {
            if #available(iOS 13.0, *) {
                typeLabel.textColor = .label
            } else {
                typeLabel.textColor = .black
            }
            self.accessoryType = .none
        }
    }
    
}
