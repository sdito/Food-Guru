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
    var storageSection: String?
    
    var timeAdded: TimeInterval?
    var timeExpires: TimeInterval?
    
    
    init(name: String, selected: Bool, category: String?, store: String?, user: String?, ownID: String?, storageSection: String?, timeAdded: TimeInterval?, timeExpires: TimeInterval?) {
        self.name = name
        self.selected = selected
        self.category = category
        self.store = store
        self.user = user
        self.ownID = ownID
        self.storageSection = storageSection
        self.timeAdded = timeAdded
        self.timeExpires = timeExpires
    }
    
    //correctly reads the ownID of the document of items
    static func readItemsForList(db: Firestore, docID: String, itemsChanged: @escaping (_ items: [Item]) -> Void) {
        var listItems: [Item] = []
        db.collection("lists").document(docID).collection("items").addSnapshotListener { (querySnapshot, error) in
            listItems.removeAll()
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(String(describing: error))")
                return
            }
            
            for doc in documents {
                let i = Item(name: doc.get("name") as! String, selected: doc.get("selected")! as! Bool, category: (doc.get("category") as! String), store: (doc.get("store") as! String), user: (doc.get("user") as! String), ownID: doc.documentID, storageSection: nil, timeAdded: nil, timeExpires: nil)
                if listItems.isEmpty == false {
                    listItems.append(i)
                } else {
                    listItems = [i]
                }
            }
            itemsChanged(listItems)
        }
    }
    
//    static func readItemsForStorage(db: Firestore, docID: String, itemsChanged: @escaping (_ items: [Item]) -> Void) {
//        db.collection("storage").document(docID).collection("items").addSnapshotListener { (querySnapshot, error) in
//            guard let documents = querySnapshot?.documents else {
//                print("Error fetching documents: \(String(describing: error))")
//                return
//            }
//
//            for doc in documents {
//
//            }
//        }
//    }
    
}

extension Item {
    mutating func writeToFirestore(db: Firestore!) {
        let itemRef = db.collection("lists").document("\(SharedValues.shared.listIdentifier!.documentID)").collection("items").document()
        self.ownID = itemRef.documentID
        itemRef.setData([
            "name": self.name,
            "category": self.category!,
            "store": self.store!,
            "user": SharedValues.shared.userID ?? "did not write",
            "selected": self.selected
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written")
            }
        }
    }
    func writeToFirestoreForStorage(db: Firestore!, docID: String) {
       let reference = db.collection("storage").document(docID).collection("items").document()
        reference.setData([
            "name": self.name,
            "selected": false,
            "category": self.category!,
            "store": self.store!,
            "user": self.user ?? "",
            "ownID": self.ownID ?? "",
            "storageSection": "none",
            "timeAdded": Date().timeIntervalSince1970
        ])
    }
    func selectedItem(db: Firestore) { db.collection("lists").document("\(SharedValues.shared.listIdentifier!.documentID)").collection("items").document(self.ownID!).updateData([
            "selected": self.selected
        ])
    }
}

