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
    var selected: Bool
    var category: String?
    var store: String?
    var user: String?
    var ownID: String?
    
    init(name: String, selected: Bool, category: String?, store: String?, user: String?, ownID: String?) {
        self.name = name
        self.selected = selected
        self.category = category
        self.store = store
        self.user = user
        self.ownID = ownID
    }
    
    //correctly reads the ownID of the document of items
    static func readItems(db: Firestore, docID: String, itemsChanged: @escaping (_ items: [Item]) -> Void) {
        var listItems: [Item] = []
        db.collection("lists").document(docID).collection("items").addSnapshotListener { (querySnapshot, error) in
            listItems.removeAll()
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(String(describing: error))")
                return
            }
            
            for doc in documents {
                let i = Item(name: doc.get("name") as! String, selected: false, category: (doc.get("category") as! String), store: (doc.get("store") as! String), user: (doc.get("user") as! String), ownID: doc.documentID)
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
    mutating func writeToFirestore(db: Firestore!) {
        let itemRef = db.collection("lists").document("\(SharedValues.shared.listIdentifier!.documentID)").collection("items").document()
        self.ownID = itemRef.documentID
        itemRef.setData([
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
    /*
    mutating func selectedItem(db: Firestore) {
        // to change the local item from the list and write to the db that the item was selected
        // in the future, could only continuously write to the db is another user is viewing the list
        
        
    }
 */
}
