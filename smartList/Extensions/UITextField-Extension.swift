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
    func insertToolBar() {
        let one = UIBarButtonItem(barButtonSystemItem: .rewind, target: nil, action: nil)
        one.tintColor = .clear
        let two = UIBarButtonItem(barButtonSystemItem: .fastForward, target: nil, action: nil)
        let three = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let toolbar = UIToolbar()
        two.tintColor = Colors.main; three.tintColor = Colors.main
        toolbar.autoresizingMask = .flexibleHeight
        toolbar.setItems([one, two, three], animated: false)
        self.inputAccessoryView = toolbar
    }
}



