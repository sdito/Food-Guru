//
//  CreateNewItemCell.swift
//  smartList
//
//  Created by Steven Dito on 10/19/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import UIKit

class CreateNewItemCell: UITableViewCell {
    
    @IBOutlet weak var label: UILabel!
    
    func setUI(text: String) {
        label.text = text
        
        // if iPad, then make the font slightly bigger
        if !SharedValues.shared.isPhone {
            label.font = UIFont(name: "futura", size: 23)
        }
    }
    
    
    
}
