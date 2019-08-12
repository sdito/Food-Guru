//
//  Item.swift
//  smartList
//
//  Created by Steven Dito on 8/6/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import Foundation
//import FirebaseCore
import FirebaseFirestore

class Item {
    var name: String
    var category: String?
    var store: String?
    var documentID: DocumentReference?
    
    init(name: String, category: String?, store: String?, documentID: DocumentReference?) {
        self.name = name
        self.category = category
        self.store = store
        self.documentID = documentID
    }
}


extension Item {
    func writeToFirestore(db: Firestore!) {
        db.collection("lists").document("\(SharedValues.shared.listIdentifier!.documentID)").collection("items").document().setData([
            "name": self.name,
            "category": self.category!,
            "store": self.store!,
            "user": SharedValues.shared.userID ?? "did not write"
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written")
            }
        }
        
    }
}
