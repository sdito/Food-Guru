//
//  Item.swift
//  smartList
//
//  Created by Steven Dito on 8/6/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import Foundation
import FirebaseFirestore

struct Item {
    var name: String
    var category: String?
    var store: String?
    //var documentID: DocumentReference?
    var user: String?
    
    init(name: String, category: String?, store: String?/*, documentID: DocumentReference?*/, user: String?) {
        self.name = name
        self.category = category
        self.store = store
        //self.documentID = documentID
        self.user = user
    }
    
    static func readItems(db: Firestore, docID: String, itemsChanged: @escaping (_ items: [Item]) -> Void) {
        var listItems: [Item] = []
        db.collection("lists").document(docID).collection("items").addSnapshotListener { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(String(describing: error))")
                return
            }
            
            for doc in documents {
                let i = Item(name: doc.get("name") as! String, category: (doc.get("category") as! String), store: (doc.get("store") as! String), user: (doc.get("user") as! String))
                if listItems.isEmpty == false {
                    listItems.append(i)
                } else {
                    listItems = [i]
                }
            }
            itemsChanged(listItems)
        }
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
