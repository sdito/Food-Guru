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
    
    func handleSelectedForBottomTab(selected: Bool) {
        if selected {
            self.layer.cornerRadius = 4.0
            self.clipsToBounds = true
            self.backgroundColor = Colors.secondary
        } else {
            self.backgroundColor = .clear
        }
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


