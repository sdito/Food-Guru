//
//  UIStackView-Extension.swift
//  smartList
//
//  Created by Steven Dito on 8/19/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import Foundation
import UIKit

extension UIStackView {
    func insertRow() {
        //needs a label for number and associated text field
        let sv = UIStackView()
        sv.axis = .horizontal
        
        let label = UILabel()
        label.font = UIFont(name: "futura", size: 17)
        label.text = "\(self.subviews.count + 1)."
        
        let textField = UITextField()
        textField.font = UIFont(name: "futura", size: 17)
        textField.textColor = Colors.main
        
        sv.insertSubview(label, at: 0)
        sv.insertSubview(textField, at: 1)
        self.insertSubview(sv, at: self.subviews.count)
    }
    
    func createInstructionRow() {
        //insert it into self at 'last'
        let sv = UIStackView()
        sv.axis = .horizontal
        
        let button = UIButton()
        button.setTitle("+", for: .normal)
        button.setTitleColor(Colors.main, for: .normal)
        button.titleLabel?.font = UIFont(name: "futura", size: 17)
        
        let tv = UITextView()
        tv.isScrollEnabled = false
        tv.border()
        tv.textColor = Colors.main
        tv.font = UIFont(name: "futura", size: 17)
        
        sv.insertSubview(button, at: 0)
        sv.insertSubview(tv, at: 1)
        
        //sv.subviews[0].widthAnchor.constraint(equalTo: sv.subviews[1].widthAnchor, multiplier: 0.1, constant: 1)
        
        self.insertSubview(sv, at: self.subviews.count + 1)
    }
}
