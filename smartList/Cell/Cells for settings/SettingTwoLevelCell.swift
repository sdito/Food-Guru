//
//  SettingTwoLevelCell.swift
//  smartList
//
//  Created by Steven Dito on 9/11/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import UIKit

class SettingTwoLevelCell: UITableViewCell {
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var bottomLabel: UILabel!
    
    func setUI(date: String, emails: [String]) {
        topLabel.text = "Created on \(date)"
        bottomLabel.text = emails.joined(separator: "\n")
    }
}
