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
    var listIdentifier: DocumentReference? {
        didSet {
            print(self.listIdentifier?.documentID)
        }
    }
    
    static let shared = SharedValues()
    private init() {}
}
