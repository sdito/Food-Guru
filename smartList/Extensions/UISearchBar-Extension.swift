//
//  UISearchBar-Extension.swift
//  smartList
//
//  Created by Steven Dito on 9/27/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import Foundation
import UIKit

extension UISearchBar {
    func setTextProperties() {
        let inside = self.value(forKey: "searchField") as? UITextField
        inside?.textColor = Colors.main
        inside?.font = UIFont(name: "futura", size: 17)
    }
    func setUpToolBar(action: Selector) {
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: action)
    
        done.tintColor = Colors.main
        let toolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40))
        
        toolbar.autoresizingMask = .flexibleHeight
        toolbar.setItems([space, done], animated: false)
        self.inputAccessoryView = toolbar
    }
    func setUpAddItemToolbar(cancelAction: Selector, addAction: Selector) {
        let toolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: cancelAction)
        let add = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: addAction)
        cancel.tintColor = Colors.main
        add.tintColor = Colors.main
        toolbar.autoresizingMask = .flexibleHeight
        toolbar.setItems([cancel, space, add], animated: false)
        self.inputAccessoryView = toolbar
    }
}
