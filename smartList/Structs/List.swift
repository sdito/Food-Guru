//
//  List.swift
//  smartList
//
//  Created by Steven Dito on 8/6/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import Foundation
import FirebaseCore
import FirebaseFirestore

struct List {
    var name: String
    var stores: [String]?
    var categories: [String]?
    var people: [String]?
    var items: [Item]?
    
    init(name: String, stores: [String]?, categories: [String]?, people: [String]?, items: [Item]?) {
        self.name = name
        self.stores = stores
        self.categories = categories
        self.people = people
        self.items = items
    }
}


extension List {
    func writeToFirestore(db: Firestore!) {
        SharedValues.shared.listIdentifier = db.collection("lists").document()
        SharedValues.shared.listIdentifier?.setData([
            "name": self.name,
            "stores": self.stores!,
            "categories": self.categories!,
            "people": self.people!
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written")
            }
        }
    }
    
}
