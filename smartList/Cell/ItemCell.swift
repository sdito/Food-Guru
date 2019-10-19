//
//  ItemCell.swift
//  smartList
//
//  Created by Steven Dito on 8/10/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import UIKit

class ItemCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    
    func setUI(item: Item) {
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
    }
    
}
