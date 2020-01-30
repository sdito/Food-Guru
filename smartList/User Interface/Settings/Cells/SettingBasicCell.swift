//
//  SettingBasicCell.swift
//  smartList
//
//  Created by Steven Dito on 9/9/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import UIKit


// Not just used in settings related VCs
class SettingBasicCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        if SharedValues.shared.isPhone == false {
            label.font = UIFont(name: "futura", size: 24)
        }
    }
    
    func setUI(str: String) {
        label.text = str
    }
}

