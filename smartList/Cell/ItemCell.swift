//
//  ItemCell.swift
//  smartList
//
//  Created by Steven Dito on 8/10/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import UIKit


protocol ItemCellDelegate {
    func edit(item: Item)
}


class ItemCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    
    var delegate: ItemCellDelegate!
    private var item: Item?
    
    
    func setUI(item: Item) {
        self.item = item
        if item.selected == true {
            let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: item.name)
            attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
            attributeString.addAttribute(NSAttributedString.Key.strikethroughColor, value: UIColor.red, range: NSMakeRange(0, attributeString.length))
            nameLabel.attributedText = attributeString
        } else {
            nameLabel.attributedText = nil
            nameLabel.text = item.name
        }
        
        if SharedValues.shared.isPhone == false {
            nameLabel.font = UIFont(name: "futura", size: 30)
            quantityLabel.font = UIFont(name: "futura", size: 20)
        }
        
        if let q = item.quantity {
            if q != "" {
                quantityLabel.isHidden = false
                quantityLabel.text = "(\(q))"
            } else {
               quantityLabel.isHidden = true
            }
        } else {
            quantityLabel.isHidden = true
        }
    }
    @IBAction func editItemAction(_ sender: Any) {
        if let item = item {
            delegate.edit(item: item)
        }
    }
    
}
