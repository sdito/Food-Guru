//
//  MealPlannerCell.swift
//  smartList
//
//  Created by Steven Dito on 2/23/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class MealPlannerCell: UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    
    func setUI(recipeName: String) {
        title.text = recipeName
    }
}
