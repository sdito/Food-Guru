//
//  UITextField-Extension.swift
//  smartList
//
//  Created by Steven Dito on 8/4/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import Foundation
import UIKit

extension UITextField {
    // might not need this code after changing vc for list creating, make sure to check
    func toInt() -> Int? {
        return Int(self.text ?? "")
    }
    
    
    func setUpListToolbar(action: Selector, arrowAction: Selector) {
        let one = UIBarButtonItem(barButtonSystemItem: .fastForward, target: nil, action: arrowAction)
        let two = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let three = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: action)
        one.tintColor = Colors.main
        three.tintColor = Colors.main
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40))
        toolbar.autoresizingMask = .flexibleHeight
        toolbar.setItems([one, two, three], animated: false)
        self.inputAccessoryView = toolbar
    }
    
    
    func setUpStandardFormat(text: String) {
        self.font = UIFont(name: "futura", size: 15)
        self.textColor = Colors.main
        self.placeholder = text
    }
    
    func setUpDoneToolbar(action: Selector, style: UIBarButtonItem.SystemItem) {
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(barButtonSystemItem: style, target: nil, action: action)
        done.tintColor = Colors.main
        let toolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40))
        toolbar.autoresizingMask = .flexibleHeight
        toolbar.setItems([space, done], animated: false)
        self.inputAccessoryView = toolbar
        
    }
    
    func setUpCancelAndAddToolbar(cancelAction: Selector, addAction: Selector) {
        let cancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: cancelAction)
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let add = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: addAction)
        cancel.tintColor = Colors.main
        add.tintColor = Colors.main
        
        let toolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40))
        toolbar.autoresizingMask = .flexibleHeight
        toolbar.setItems([cancel, space, add], animated: false)
        self.inputAccessoryView = toolbar
    }
    
    
}



