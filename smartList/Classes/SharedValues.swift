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
    var currentCategory: String = ""
    var listIdentifier: DocumentReference?
    var userID: String?
    var recipeType: [String]?
    var cuisineType: String?
    var currText: UIView?
    var groupID: String?
    var data: (emails: [String], date: String)?
    
    static let shared = SharedValues()
    private init() {}
}
