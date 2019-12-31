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
    var delegate: ItemCellDelegate!
    private var item: Item?
    @IBOutlet weak var nameLabel: UILabel!
    
    func setUI(item: Item) {
        self.item = item
        if item.selected == true {
            //self.backgroundColor = #colorLiteral(red: 1, green: 0.1211283586, blue: 0.1838686673, alpha: 1)
            let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: item.name)
            attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
            attributeString.addAttribute(NSAttributedString.Key.strikethroughColor, value: UIColor.red, range: NSMakeRange(0, attributeString.length))
            nameLabel.attributedText = attributeString
        } else {
            //self.backgroundColor = .white
            nameLabel.attributedText = nil
            nameLabel.text = item.name
        }
        
        if SharedValues.shared.isPhone == false {
            nameLabel.font = UIFont(name: "futura", size: 30)
        }
    }
    @IBAction func editItemAction(_ sender: Any) {
        if let item = item {
            delegate.edit(item: item)
        }
    }
    
}
