//
//  SharedValues.swift
//  smartList
//
//  Created by Steven Dito on 8/10/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import Foundation
import FirebaseCore
import FirebaseFirestore

class SharedValues {
    //var currentCategory: String = ""
    var listIdentifier: DocumentReference?
    var userID: String?
    var recipeType: [String]?
    var cuisineType: String?
    var currText: UIView?
    
    var groupID: String? {
        didSet {
            NotificationCenter.default.post(name: .groupIDchanged, object: nil)
        }
    }
    var groupEmails: [String]?
    var groupDate: TimeInterval?
    var foodStorageEmails: [String]?
    var savedRecipes: [String]? {
        didSet {
            NotificationCenter.default.post(name: .savedRecipesChanged, object: nil)
        }
    }
    var foodStorageID: String? {
        didSet {
            NotificationCenter.default.post(name: .foodStorageIDchanged, object: nil)
        }
    }
    
    var sentRecipesInto: (recipes: [Recipe], ingredients: [String])?
    
    
    static let shared = SharedValues()
    private init() {}
}
