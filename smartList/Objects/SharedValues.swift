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
import StoreKit

/// Each time a value is added, need to set it to nil in User.resetSharedValues()


class SharedValues {

    var listIdentifier: DocumentReference?
    var userID: String?
    
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
            #warning("should so something with deleting the listener when there is a new one, come back")
            FoodStorage.readAndPersistSystemItemsFromStorageWithListener(db: Firestore.firestore(), storageID: foodStorageID ?? " ")
            NotificationCenter.default.post(name: .foodStorageIDchanged, object: nil)
        }
    }
    
    var sentRecipesInfo: [NetworkSearch]?
    
    var currentItemsInStorage: [String]?
    
    var anonymousUser: Bool?
    
    var newUsername: String?
    
    var previouslyViewedRecipes: [String:[String:Any]]?
    
    var isPhone: Bool = UIDevice.current.userInterfaceIdiom == .phone
    
    var isStorageWithGroup: Bool?
    
    var mealPlannerID: String?
    
    static let shared = SharedValues()
    
    func updateUiIfApplicable() {
        
        mealPlannerHomeVC?.updateUiIfApplicable()
        
        // To eventually ask for app store review
        let defaults = UserDefaults.standard
        let numTimesRan = defaults.integer(forKey: "timesOpened")
        
        
        defaults.set(numTimesRan + 1, forKey: "timesOpened")
        if numTimesRan == 4 {
            SKStoreReviewController.requestReview()
        }
        print(numTimesRan)
        
    }
    
    var mealPlannerHomeVC: MealPlannerHomeVC?
    
    private init() {}
}
