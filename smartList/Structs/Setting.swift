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
    var settingName: SettingName
    
    init(name: String, settingName: SettingName) {
        self.name = name
        self.settingName = settingName
    }
    
    enum SettingName {
        case account
        case group
        case textSize
        case darkMode
        case notifications
        case contact
        case licences
        case about
    }
    
    static func createSettings() -> ([String], [[Setting]]) {
        let account_ = Setting(name: "Account", settingName: .account)
        let group = Setting(name: "Group", settingName: .group)
        let textSize = Setting(name: "Text size", settingName: .textSize)
        let darkMode = Setting(name: "Dark mode", settingName: .darkMode)
        let notifications = Setting(name: "Notifications", settingName: .notifications)
        let contact = Setting(name: "Contact the developer", settingName: .contact)
        let licences = Setting(name: "Software licences", settingName: .licences)
        let about = Setting(name: "About", settingName: .about)
        
        
        return (["Users & Accounts", "Settings", "Support & About"], [[account_, group], [textSize, darkMode, notifications], [contact, licences, about]])
    }
    
    
}
