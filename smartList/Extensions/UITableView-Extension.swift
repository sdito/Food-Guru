//
//  UITableView-Extension.swift
//  smartList
//
//  Created by Steven Dito on 6/17/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit


extension UITableView {
    func heightOfCells() -> CGFloat? {
        
        let number = self.numberOfRows(inSection: 0)
        if number >= 1 {
            let cell = self.cellForRow(at: IndexPath(row: 0, section: 0))
            if let height = cell?.bounds.height {
                return height * CGFloat(number)
            }
        }
        return nil
    }
}
