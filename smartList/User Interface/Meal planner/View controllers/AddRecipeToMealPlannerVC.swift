//
//  AddRecipeToMealPlannerVC.swift
//  smartList
//
//  Created by Steven Dito on 2/3/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class AddRecipeToMealPlannerVC: UIViewController {
    
    var shortDate: String?
    

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func addNewRecipe(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Recipes", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "cRecipe") as! CreateRecipeVC
        self.navigationController?.pushViewController(vc, animated: true)
        vc.fromPlanner = true
    }
    
}
