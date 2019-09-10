//
//  SettingBasicCell.swift
//  smartList
//
//  Created by Steven Dito on 9/9/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import UIKit

class SettingBasicCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
    
    func setUI(str: String) {
        label.text = str
    }
}
