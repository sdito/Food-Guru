//
//  SettingSwitchCell.swift
//  smartList
//
//  Created by Steven Dito on 3/28/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class SettingSwitchCell: UITableViewCell {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var actionSwitch: UISwitch!
    
    private var defaults = UserDefaults.standard
    
    func setUIforMealPlanner() {
        
        label.text = "Don't ask before adding ingredients from meal planner to list"
        
        let value = defaults.bool(forKey: "dontAskBeforeAddingToMP")
        actionSwitch.setOn(value, animated: false)
        
        actionSwitch.addTarget(self, action: #selector(mealPlannerSwitchChanged(_:)), for: .valueChanged)
        
    }
    
    @objc func mealPlannerSwitchChanged(_ sender: UISwitch) {
        switch sender.isOn {
        case true:
            defaults.set(true, forKey: "dontAskBeforeAddingToMP")
        case false:
            defaults.set(false, forKey: "dontAskBeforeAddingToMP")
            
        }
    }

}
