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
        case recentlyViewedRecipes
        case storage
        case darkMode
        case notifications
        case contact
        case licences
        case about
        case tutorial
    }
    
    static func createSettings() -> ([String], [[Setting]]) {
        let account_ = Setting(name: "Account", settingName: .account)
        let group = Setting(name: "Group", settingName: .group)
        let recentlyViewedRecipes = Setting(name: "Recently viewed recipes", settingName: .recentlyViewedRecipes)
        let storage = Setting(name: "Storage", settingName: .storage)
        let darkMode = Setting(name: "Dark mode", settingName: .darkMode)
        let notifications = Setting(name: "Notifications", settingName: .notifications)
        let contact = Setting(name: "Contact the developer", settingName: .contact)
        let licences = Setting(name: "Software licences", settingName: .licences)
        let about = Setting(name: "About", settingName: .about)
        let tutorial = Setting(name: "Tutorial", settingName: .tutorial)
        
        return (["Users & Accounts", "Application", "Settings", "Support & About"], [[account_, group], [tutorial, recentlyViewedRecipes, storage], [darkMode, notifications], [contact, licences, about]])
    }
    
    
}

extension Setting.SettingName {
    func description() -> String {
        switch self {
        case .account:
            return "Account"
        case .group:
            return "Group"
        case .recentlyViewedRecipes:
            return "Recently viewed recipes"
        case .storage:
            return "Storage"
        case .darkMode:
            return "Dark mode"
        case .notifications:
            return "Notifications"
        case .contact:
            return "Contact the developer"
        case .licences:
            return "Licenses"
        case .about:
            return "About"
        case .tutorial:
            return "Tutorial"
        }
    }
}
