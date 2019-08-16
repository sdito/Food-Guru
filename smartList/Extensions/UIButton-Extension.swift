//
//  UIButton-Extension.swift
//  smartList
//
//  Created by Steven Dito on 8/5/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//


import Foundation
import UIKit



extension UIButton {
    func selected() {
        self.alpha = 1.0
    }
    func notSelected() {
        self.alpha = 0.6
    }
    
    func createCategoryButton(with title: String) {
        self.titleLabel?.font = UIFont(name: "futura", size: 18)
        self.setTitle(title, for: .normal)
        self.setTitleColor(.white, for: .normal)
        //self.backgroundColor = Colors.main
        
        
        self.layer.cornerRadius = 10
        self.setGradientBackground(colorOne: Colors.main, colorTwo: Colors.mainGradient)
        self.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
    
    }
    
    @objc func buttonAction(sender: UIButton) {
        SharedValues.shared.currentCategory = self.titleLabel?.text ?? "Other"
    }
}




extension Array where Element: UIButton {
    func setSelected(selected: UIButton) {
        for i in self {
            if i == selected {
                i.selected()
            } else {
                i.notSelected()
            }
        }
    }
}


