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
        case mealPlanner
        case darkMode
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
        let mealPlanner = Setting(name: "Meal planner", settingName: .mealPlanner)
        let darkMode = Setting(name: "Dark mode", settingName: .darkMode)
        let contact = Setting(name: "Contact the developer", settingName: .contact)
        let licences = Setting(name: "Software licences", settingName: .licences)
        let about = Setting(name: "About", settingName: .about)
        let tutorial = Setting(name: "Tutorial", settingName: .tutorial)
        
        return (["Users & Accounts", "Application", "Settings", "Support & About"], [[account_, group], [tutorial, recentlyViewedRecipes, storage, mealPlanner], [darkMode], [contact, licences, about]])
    }
    
    
}
// MARK: Setting.SettingName
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
        case .contact:
            return "Contact the developer"
        case .licences:
            return "Licenses"
        case .about:
            return "About"
        case .tutorial:
            return "Tutorial"
        case .mealPlanner:
            return "Meal Planner"
        }
    }
}
