//
//  ListHomeCell.swift
//  smartList
//
//  Created by Steven Dito on 9/23/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import UIKit

class ListHomeCell: UITableViewCell {
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var numberItems: UILabel!
    @IBOutlet weak var createdAgo: UILabel!
    
    func setUI(list: GroceryList) {
        name.text = list.name
        createdAgo.text = list.timeIntervalSince1970?.timeSince()
        switch list.numItems {
        case nil:
            numberItems.text = "No items"
        case 0:
            numberItems.text = "No items"
        case 1:
            numberItems.text = "1 item"
        default:
            numberItems.text = "\(list.numItems ?? 0) items"
        }
        
        if SharedValues.shared.isPhone == false {
            name.font = UIFont(name: "futura", size: 30)
            numberItems.font = UIFont(name: "futura", size: 24)
            createdAgo.font = UIFont(name: "futura", size: 18)
            
        }
        
    }

}
