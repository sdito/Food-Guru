//
//  AddRecipeToMealPlannerVC.swift
//  smartList
//
//  Created by Steven Dito on 2/3/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class AddRecipeToMealPlannerVC: UIViewController {
    
    var shortDate: String? {
        didSet {
            self.title = self.shortDate!.shortDateToDisplay()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

}
