//
//  SettingCell.swift
//  smartList
//
//  Created by Steven Dito on 9/9/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import UIKit

class SettingCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    
    override func awakeFromNib() {
        if SharedValues.shared.isPhone == false {
            title.font = UIFont(name: "futura", size: 24)
        }
    }
    
    func setUI(setting: Setting) {
        title.text = setting.name
    }

}
