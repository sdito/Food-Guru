//
//  TabVC.swift
//  smartList
//
//  Created by Steven Dito on 9/5/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import UIKit
import FirebaseFirestore
import StoreKit

class TabVC: UITabBarController {
    var db: Firestore!
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        User.writeNewUserDocumentIfApplicable(db: db)
        User.setAndPersistGroupDataInSharedValues(db: db)
        
        let defaults = UserDefaults.standard
        let numTimesRan = defaults.integer(forKey: "timesOpened")
        
        if numTimesRan == 10 {
            SKStoreReviewController.requestReview()
        }
        
        defaults.set(numTimesRan + 1, forKey: "timesOpened")
        
    }
    
}

