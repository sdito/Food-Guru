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
        let buttons: [(name: String, action: Selector)] = [("From your ingredients", #selector(action)), ("Recommended", #selector(action)), ("Breakfast", #selector(action)), ("Lunch", #selector(action)), ("Dinner", #selector(action)), ("Low calorie", #selector(action)), ("Chicken", #selector(action)), ("Pasta", #selector(action)), ("Healthy", #selector(action)), ("Dessert", #selector(action)), ("Salad", #selector(action)), ("Beef", #selector(action)), ("Seafood", #selector(action)), ("Casserole", #selector(action)), ("Vegetarian", #selector(action)), ("Vegan", #selector(action)), ("Italian", #selector(action)), ("Snack", #selector(action)), ("Simple", #selector(action)), ("Quick", #selector(action)), ("Slow cooker", #selector(action))]
        buttons.forEach { (button) in
            let b = UIButton()
            
            b.setTitle(button.name, for: .normal)
            b.titleLabel?.backgroundColor = Colors.main
            b.titleLabel?.font = UIFont(name: "futura", size: 17)
            b.addTarget(self, action: #selector(action), for: .touchUpInside)
            
            self.insertArrangedSubview(b, at: self.subviews.count)
        }
    }
    
    // purpose of having this sent through notification to RecipeHomeVC then to Search is to keep logic for searching in Search struct
    @objc func action(sender: Any) {
        let info = (sender as? UIButton)?.titleLabel?.text
        if let info = info {
            NotificationCenter.default.post(name: .recipeSearchButtonPressed, object: nil, userInfo: ["buttonName": info])
        }
    }
}
