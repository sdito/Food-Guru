//
//  StorageCell.swift
//  smartList
//
//  Created by Steven Dito on 9/8/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import UIKit

class StorageCell: UITableViewCell {
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var added: UILabel!
    @IBOutlet weak var expires: UILabel!
    
    func setUI(item: Item) {
        name.text = item.name
        
        if let time = item.timeAdded {
            added.text = "Added - \(time.dateFormatted(style: .short))"
        } else {
            added.text = ""
        }
        
        if let time = item.timeExpires {
            expires.text = "Expires - \(time.dateFormatted(style: .short))"
        } else {
            expires.text = ""
        }
    }
}
