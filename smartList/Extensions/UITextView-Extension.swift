//
//  UITextView-Extension.swift
//  smartList
//
//  Created by Steven Dito on 10/6/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//
import UIKit


extension UITextView {
    func setUpDoneToolbar(action: Selector, style: UIBarButtonItem.SystemItem) {
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(barButtonSystemItem: style, target: nil, action: action)
        done.tintColor = Colors.main
        let toolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40))
        toolbar.autoresizingMask = .flexibleHeight
        toolbar.setItems([space, done], animated: false)
        self.inputAccessoryView = toolbar
        
    }
}
