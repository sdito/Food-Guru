//
//  Item.swift
//  smartList
//
//  Created by Steven Dito on 8/6/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import Foundation
import FirebaseFirestore

struct Item: Equatable {
    var name: String
    var selected: Bool
    var category: String?
    var store: String?
    var user: String?
    var ownID: String?
    var storageSection: FoodStorageType?
    
    var timeAdded: TimeInterval?
    var timeExpires: TimeInterval?
    
    
    init(name: String, selected: Bool, category: String?, store: String?, user: String?, ownID: String?, storageSection: FoodStorageType?, timeAdded: TimeInterval?, timeExpires: TimeInterval?) {
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
    
    
    // hasnt been used yet
    static func readItemsForStorage(db: Firestore!, storageID: String, itemsChanged: @escaping (_ items: [Item]) -> Void) {
        var storageItems: [Item] = []
        db.collection("storages").document(storageID).collection("items").addSnapshotListener { (querySnapshot, error) in
            storageItems.removeAll()
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(String(describing: error))")
                return
            }
            
            for doc in documents {
                let i = Item(name: doc.get("name") as! String, selected: doc.get("selected")! as! Bool, category: (doc.get("category") as! String), store: (doc.get("store") as! String), user: (doc.get("user") as! String), ownID: doc.documentID, storageSection: FoodStorageType.stringToFoodStorageType(string: (doc.get("storageSection") as? String ?? " ")), timeAdded: doc.get("timeAdded") as? TimeInterval, timeExpires: doc.get("timeExpires") as? TimeInterval)
                if storageItems.isEmpty == false {
                    storageItems.append(i)
                } else {
                    storageItems = [i]
                }
            }
            itemsChanged(storageItems)
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
       let reference = db.collection("storages").document(docID).collection("items").document()
        reference.setData([
            "name": self.name,
            "selected": false,
            "category": self.category!,
            "store": self.store!,
            "user": self.user ?? "",
            "ownID": reference.documentID,
            "storageSection": self.storageSection?.string ?? FoodStorageType.unsorted.string,
            "timeAdded": Date().timeIntervalSince1970,
            "timeExpires": self.timeExpires as Any
        ])
    }
    
    
    func selectedItem(db: Firestore) { db.collection("lists").document("\(SharedValues.shared.listIdentifier!.documentID)").collection("items").document(self.ownID!).updateData([
            "selected": self.selected
        ])
    }
    
    #warning("dont think i need storageID here and on deleteItemFromStorage in same file")
    func switchItemToSegment(named: String, db: Firestore, storageID: String) {
        let documentRef = db.collection("storages").document(SharedValues.shared.foodStorageID ?? " ").collection("items").document(self.ownID ?? " ")
        documentRef.updateData([
            "storageSection": named
        ])
    }
    func addExpirationDateToItem(db: Firestore, timeIntervalSince1970: TimeInterval) {
        let documentRef = db.collection("storages").document(SharedValues.shared.foodStorageID ?? " ").collection("items").document(self.ownID ?? " ")
        documentRef.updateData([
            "timeExpires": timeIntervalSince1970
        ])
    }
    
    #warning("have the deleted items go to a recently deleted items in the settings, could have a pop up say after the items are deleted (pop up only shown once) that deleted items can be found in the settings, could also keep track of the user that deletes the items")
    func deleteItemFromStorage(db: Firestore, storageID: String) {
        let documentRef = db.collection("storages").document(SharedValues.shared.foodStorageID ?? " ").collection("items").document(self.ownID ?? " ")
        documentRef.delete()
    }
}


extension Sequence where Element == Item {
    func sortItemsForTableView(segment: FoodStorageType) -> [Item] {
        let sorted = self.filter({$0.storageSection == segment})
        return sorted
    }
}
