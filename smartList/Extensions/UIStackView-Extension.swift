//
//  UIStackView-Extension.swift
//  smartList
//
//  Created by Steven Dito on 9/12/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

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
        let font = UIFont(name: "futura", size: 17)!
        let buttons: [(name: String, action: Selector)] = [("Select Ingredients", #selector(recipePressed)), ("Expiring", #selector(recipePressed)), ("Breakfast", #selector(recipePressed)), ("Lunch", #selector(recipePressed)), ("Dinner", #selector(recipePressed)), ("Low Calorie", #selector(recipePressed)), ("Chicken", #selector(recipePressed)), ("Pasta", #selector(recipePressed)), ("Healthy", #selector(recipePressed)), ("Dessert", #selector(recipePressed)), ("Salad", #selector(recipePressed)), ("Beef", #selector(recipePressed)), ("Seafood", #selector(recipePressed)), ("Casserole", #selector(recipePressed)), ("Vegetarian", #selector(recipePressed)), ("Vegan", #selector(recipePressed)), ("Italian", #selector(recipePressed)), ("Snack", #selector(recipePressed)), ("Simple", #selector(recipePressed)), ("Quick", #selector(recipePressed)), ("Slow Cooker", #selector(recipePressed))]
        buttons.forEach { (button) in
            let b = UIButton()
            
            b.setTitle(button.name, for: .normal)
            b.titleLabel?.backgroundColor = Colors.main
            b.titleLabel?.font = font
            b.addTarget(self, action: #selector(recipePressed), for: .touchUpInside)
            
            // to get the width of the text by itself in order to add padding to the title
            let textArea = NSString(string: button.name).boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
            let width = ceil(textArea.width)
            b.titleLabel?.widthAnchor.constraint(equalToConstant: width + 20).isActive = true
            b.titleLabel?.textAlignment = .center
            self.insertArrangedSubview(b, at: self.subviews.count)
        }
    }
    
    // purpose of having this sent through notification to RecipeHomeVC then to Search is to keep logic for searching in Search struct
    @objc func recipePressed(sender: Any) {
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
