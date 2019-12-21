//
//  TabVC.swift
//  smartList
//
//  Created by Steven Dito on 9/5/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth


class TabVC: UITabBarController {
    var db: Firestore!
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        User.writeNewUserDocumentIfApplicable(db: db)
        User.setAndPersistGroupDataInSharedValues(db: db)
        
    }
}

