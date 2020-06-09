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
    @IBOutlet weak var secondaryLabel: UILabel!
    @IBOutlet weak var img: UIImageView!
    
    
    func setUI(networkSearch: NetworkSearch, inItems: Bool, list: Bool, search: Bool, smallStyle: Bool)  {
        
        label.text = networkSearch.text
        
        var iconImage: UIImage {
            switch list {
            case true:
                return UIImage(named: "list_icon")!
            case false:
                return UIImage(named: "storage_icon")!
            }
        }
        
        if !search {
            img.image = iconImage
            secondaryLabel.isHidden = true
        } else {
            secondaryLabel.isHidden = false
            if networkSearch.type == .ingredient {
                secondaryLabel.text = "INGREDIENT"
            } else {
                secondaryLabel.text = "TAG/TYPE"
                
            }
        }
        
        if inItems {
            img.isHidden = false
        } else {
            img.isHidden = true
        }
        // if iPad, then make the font slightly bigger
        if !SharedValues.shared.isPhone {
            
        }
        
        if smallStyle && SharedValues.shared.isPhone  {
            // make smaller to fit better
            label.font = UIFont(name: "futura", size: 13)
        } else if !smallStyle && !SharedValues.shared.isPhone {
            // if iPad and small style, just leave at standard
            label.font = UIFont(name: "futura", size: 23)
        }
        
    }
    
    
    
}
