//
//  RecipeSearchCell.swift
//  smartList
//
//  Created by Steven Dito on 10/18/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import UIKit

class RecipeSearchCell: UITableViewCell {
    
    @IBOutlet weak var label: UILabel!
    
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if selected == true {
            label.textColor = Colors.main
            self.accessoryType = .checkmark
        } else {
            self.accessoryType = .none
            if #available(iOS 13.0, *) {
                label.textColor = .label
            } else {
                label.textColor = .black
            }
        }
    }
    
    func setUI(item: Item) {
        self.selectionStyle = .none
        label.text = item.name
        if #available(iOS 13.0, *) {
            label.textColor = .label
        } else {
            label.textColor = .black
        }
        
    }
    
}
