//
//  SettingViewedRecipeCell.swift
//  smartList
//
//  Created by Steven Dito on 12/20/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import UIKit

class SettingViewedRecipeCell: UITableViewCell {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var time: UILabel!
    
    func setUIfromData(data: [String:Any]) {
        name.text = data["name"] as? String
        time.text = (data["timeIntervalSince1970"] as? TimeInterval)?.timeSince()
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(recognizer))
        
        self.addGestureRecognizer(gestureRecognizer)
        
    }
    
    @objc func recognizer() {
        #warning("need to implement to show recipe or something like that")
        print(self.name.text)
    }
}
