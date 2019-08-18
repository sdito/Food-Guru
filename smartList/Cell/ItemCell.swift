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
        
        
        nameLabel.text = item.name
        if item.selected == true {
            self.backgroundColor = .red
        } else {
            self.backgroundColor = .white
        }
    }
}
