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


