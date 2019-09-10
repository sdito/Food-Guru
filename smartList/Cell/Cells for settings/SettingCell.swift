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
    
    
    func setUI(setting: Setting) {
        title.text = setting.name
    }

}
