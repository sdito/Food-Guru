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
            label.textColor = Colors.label
        }
    }
    
    func setUI(item: Item) {
        self.selectionStyle = .none
        label.text = item.name
        label.textColor = Colors.label
    }
    
}
