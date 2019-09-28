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
}
