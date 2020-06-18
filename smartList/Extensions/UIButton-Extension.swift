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
    
    func currentSearchStyle(search: NetworkSearch) {
        let buttonText: String = search.text
        self.tag = search.type.toTagRepresentation()
        self.setTitle(buttonText, for: .normal)
        self.contentEdgeInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
        self.titleLabel?.font = UIFont(name: "futura", size: 13)
        self.layer.cornerRadius = 5
        if #available(iOS 13.0, *) {
            self.backgroundColor = .systemGray6
            self.setTitleColor(.systemGray, for: .normal)
        } else {
            self.backgroundColor = .lightGray
            self.setTitleColor(Colors.main, for: .normal)
        }
        self.clipsToBounds = true
    }
    
    func clearAllCurrentSearchesStyle() {
        self.setTitle("Clear", for: .normal)
        self.contentEdgeInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
        self.titleLabel?.font = UIFont(name: "futura", size: 13)
        self.layer.cornerRadius = 5
        self.backgroundColor = Colors.main
        if #available(iOS 13.0, *) {
            self.setTitleColor(.systemBackground, for: .normal)
        } else {
            self.setTitleColor(.white, for: .normal)
        }
        self.clipsToBounds = true
    }
    
    
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


