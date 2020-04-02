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
    @IBOutlet weak var img: UIImageView!
    
    
    func setUI(text: String, inItems: Bool, list: Bool) {
        print("Is for list: \(list)")
        
        
        label.text = text
        
        var iconImage: UIImage {
            switch list {
            case true:
                return UIImage(named: "list_icon")!
            case false:
                return UIImage(named: "storage_icon")!
            }
        }
        
        img.image = iconImage
        
        if inItems {
            img.isHidden = false
        } else {
            img.isHidden = true
        }
        // if iPad, then make the font slightly bigger
        if !SharedValues.shared.isPhone {
            label.font = UIFont(name: "futura", size: 23)
        }
    }
    
    
    
}
