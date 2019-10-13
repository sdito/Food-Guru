//
//  UIStackView-Extension.swift
//  smartList
//
//  Created by Steven Dito on 9/12/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import Foundation
import UIKit

extension UIStackView {
    func extractDataFromStackView() -> [String]? {
        var items: [String] = []
        self.subviews.forEach { (subview) in
            if type(of: subview) == UITextField.self {
                items.append((subview as! UITextField).text ?? "")
            }
        }
        return items
    }
    func setUpQuickSearchButtons() {
        let buttonNames = ["By ingredient", "Recommended", "Breakfast", "Lunch", "Dinner", "Low calorie", "Chicken", "Pasta", "Healthy", "Dessert", "Salad", "Beef", "Seafood", "Casserole", "Vegetarian", "Vegan", "Italian", "Snack", "Healthy", "Simple", "Quick", "Slow Cooker"]
        buttonNames.forEach { (buttonName) in
            let b = UIButton()
            b.setTitle(buttonName, for: .normal)
            self.insertArrangedSubview(b, at: self.subviews.count)
        }
    }
}
