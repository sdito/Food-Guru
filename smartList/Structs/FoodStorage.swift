//
//  Storage.swift
//  smartList
//
//  Created by Steven Dito on 9/9/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import Foundation
import FirebaseFirestore

struct FoodStorage {
    var name: String
    var peopleIDs: [String]?
    var peopleEmails: [String]?
    var items: [Item]?
    
    init(name: String, peopleIDs: [String]?, peopleEmails: [String]?, items: [Item]?) {
        self.name = name
        self.peopleIDs = peopleIDs
        self.peopleEmails = peopleEmails
        self.items = items
    }
    
    
}
