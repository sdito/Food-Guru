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





/// Each time a value is added, need to set it to nil in User.resetSharedValues()





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
    
    var sentRecipesInfo: (recipes: [Recipe], ingredients: [String])?
    
    var currentItemsInStorage: [String]? {
        didSet {
            print(self.currentItemsInStorage as Any)
        }
    }
    
    var anonymousUser: Bool?
    
    var newUsername: String?
    
    var previouslyViewedRecipes: [String:[String:Any]]?
    
    var isPhone: Bool = UIDevice.current.userInterfaceIdiom == .phone
    
    var isStorageWithGroup: Bool?
    
    var mealPlannerID: String?
    
    static let shared = SharedValues()
    
    
    
    private init() {}
}
