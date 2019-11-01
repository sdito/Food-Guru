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
        let buttons: [(name: String, action: Selector)] = [("Select ingredients", #selector(noActionYet)), ("Recommended", #selector(noActionYet)), ("Breakfast", #selector(noActionYet)), ("Lunch", #selector(noActionYet)), ("Dinner", #selector(noActionYet)), ("Low calorie", #selector(noActionYet)), ("Chicken", #selector(noActionYet)), ("Pasta", #selector(noActionYet)), ("Healthy", #selector(noActionYet)), ("Dessert", #selector(noActionYet)), ("Salad", #selector(noActionYet)), ("Beef", #selector(noActionYet)), ("Seafood", #selector(noActionYet)), ("Casserole", #selector(noActionYet)), ("Vegetarian", #selector(noActionYet)), ("Vegan", #selector(noActionYet)), ("Italian", #selector(noActionYet)), ("Snack", #selector(noActionYet)), ("Simple", #selector(noActionYet)), ("Quick", #selector(noActionYet)), ("Slow cooker", #selector(noActionYet))]
        buttons.forEach { (button) in
            let b = UIButton()
            
            b.setTitle(button.name, for: .normal)
            b.titleLabel?.backgroundColor = Colors.main
            b.titleLabel?.font = UIFont(name: "futura", size: 17)
            b.addTarget(self, action: #selector(noActionYet), for: .touchUpInside)
            
            self.insertArrangedSubview(b, at: self.subviews.count)
        }
    }
    
    // purpose of having this sent through notification to RecipeHomeVC then to Search is to keep logic for searching in Search struct
    @objc func noActionYet(sender: Any) {
        var info = (sender as? UIButton)?.titleLabel?.text
        let type = info?.buttonNameSearchType() ?? .other
        
        if info == "Chicken" {
            info = "chicken"
        } else if info == "Beef" {
            info = "beef"
        } else if info == "Pasta" {
            info = "pasta"
        }
        
        if let info = info {
            NotificationCenter.default.post(name: .recipeSearchButtonPressed, object: nil, userInfo: ["buttonName": (name: info, type: type)])
        }
    }
}
