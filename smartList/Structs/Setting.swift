//
//  Setting.swift
//  smartList
//
//  Created by Steven Dito on 9/9/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import Foundation
import UIKit

struct Setting {
    var name: String
    var cells: [UITableViewCell]
    
    init(name: String, cells: [UITableViewCell]) {
        self.name = name
        self.cells = cells
    }
    
    
    static func createSettings() -> ([String], [[Setting]]) {
        //Account
        let account = Setting(name: "Account", cells: [UITableViewCell()])
        
        
        //Group
        let group = Setting(name: "Group", cells: [UITableViewCell()])
        
        
        //Text size
        let textSize = Setting(name: "Text size", cells: [UITableViewCell()])
        
        
        //Dark mode
        let darkMode = Setting(name: "Dark mode", cells: [UITableViewCell()])
        
        
        //Notifications
        let notifications = Setting(name: "Notifications", cells: [UITableViewCell()])
        
        
        //Contact
        let contact = Setting(name: "Contact the developer", cells: [UITableViewCell()])
        
        
        //Licences
        let licences = Setting(name: "Software licences", cells: [UITableViewCell()])
        
        
        //About
        let about1 = SettingBasicCell()
        about1.setUI(str: "This is the text for the cell tot talk about the about section for this app.")
        let about = Setting(name: "About", cells: [about1])
        
        
        return (["Users & Accounts", "Settings", "Support & About"], [[account, group], [textSize, darkMode, notifications], [contact, licences, about]])
    }
}
