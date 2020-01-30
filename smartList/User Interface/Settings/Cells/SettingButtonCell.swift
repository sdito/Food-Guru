//
//  SettingButtonCell.swift
//  smartList
//
//  Created by Steven Dito on 9/10/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import UIKit

// Not just used in settings related VCs
class SettingButtonCell: UITableViewCell {

    override func awakeFromNib() {
        if SharedValues.shared.isPhone == false {
            button.titleLabel?.font = UIFont(name: "futura", size: 20)
        }
    }
    
    @IBOutlet weak var button: UIButton!
    func setUI(title: String) {
        button.setTitle(title, for: .normal)
    }
}
