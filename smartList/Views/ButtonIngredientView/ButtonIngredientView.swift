//
//  ButtonIngredientView.swift
//  smartList
//
//  Created by Steven Dito on 9/30/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import UIKit

class ButtonIngredientView: UIView {
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var label: UILabel!
    
    func setUI(ingredient: String) {
        label.text = ingredient
        //button.addTarget(self, action: <#T##Selector#>, for: .touchUpInside)
    }
    
}
