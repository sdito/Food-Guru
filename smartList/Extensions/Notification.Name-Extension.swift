//
//  Notification.Name-Extension.swift
//  smartList
//
//  Created by Steven Dito on 9/15/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import Foundation


extension Notification.Name {
    static let foodStorageIDchanged = Notification.Name("stevenDito.foodStorageIDchanged")
    static let groupIDchanged = Notification.Name("stevenDito.groupIDchanged")
    static let itemAddedFromRecipe = Notification.Name("stevenDito.itemAddedFromRecipe")
    static let recipeSearchButtonPressed = Notification.Name("stevenDito.recipeSearchButtonPressed")
    static let savedRecipesChanged = Notification.Name("stevenDito.savedRecipesChanged")
    static let haveSavedRecipesAppear = Notification.Name("stevenDito.haveSavedRecipesAppear")
    
    static let recipeDataFromURLReceived = Notification.Name("stevenDito.recipeDataFromURLReceived")
}
