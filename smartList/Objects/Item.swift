//
//  Item.swift
//  smartList
//
//  Created by Steven Dito on 8/6/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

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
    
    var systemItem: GenericItem?
    var systemCategory: Category?
    
    init(name: String, selected: Bool, category: String?, store: String?, user: String?, ownID: String?, storageSection: FoodStorageType?, timeAdded: TimeInterval?, timeExpires: TimeInterval?, systemItem: GenericItem?, systemCategory: Category?) {
        self.name = name
        self.selected = selected
        self.category = category
        self.store = store
        self.user = user
        self.ownID = ownID
        self.storageSection = storageSection
        self.timeAdded = timeAdded
        self.timeExpires = timeExpires
        self.systemItem = systemItem
        self.systemCategory = systemCategory
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
                let systemItem = GenericItem(rawValue: doc.get("systemItem") as? String ?? "other")
                let systemCategory = Category(rawValue: doc.get("systemCategory") as? String ?? "other")
                let i = Item(name: doc.get("name") as! String, selected: doc.get("selected")! as! Bool, category: (doc.get("category") as! String), store: (doc.get("store") as! String), user: (doc.get("user") as? String), ownID: doc.documentID, storageSection: nil, timeAdded: nil, timeExpires: nil, systemItem: systemItem, systemCategory: systemCategory)
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
                let systemItem = GenericItem(rawValue: doc.get("systemItem") as? String ?? "other")
                let systemCategory = Category(rawValue: doc.get("systemCategory") as? String ?? "other")
                let i = Item(name: doc.get("name") as! String, selected: doc.get("selected")! as! Bool, category: (doc.get("category") as! String), store: (doc.get("store") as! String), user: (doc.get("user") as? String), ownID: doc.documentID, storageSection: FoodStorageType.stringToFoodStorageType(string: (doc.get("storageSection") as? String ?? " ")), timeAdded: doc.get("timeAdded") as? TimeInterval, timeExpires: doc.get("timeExpires") as? TimeInterval, systemItem: systemItem, systemCategory: systemCategory)
                if storageItems.isEmpty == false {
                    storageItems.append(i)
                } else {
                    storageItems = [i]
                }
            }
            itemsChanged(storageItems)
        }
    }
    static func readItemsForStorageNoListener(db: Firestore, storageID: String, itemsReturned: @escaping (_ items: [Item]) -> Void) {
        var storageItems: [Item] = []
        db.collection("storages").document(storageID).collection("items").getDocuments { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(String(describing: error))")
                return
            }
            
            for doc in documents {
              let systemItem = GenericItem(rawValue: doc.get("systemItem") as? String ?? "other")
                let systemCategory = Category(rawValue: doc.get("systemCategory") as? String ?? "other")
                let i = Item(name: doc.get("name") as! String, selected: doc.get("selected")! as! Bool, category: (doc.get("category") as! String), store: (doc.get("store") as! String), user: (doc.get("user") as? String), ownID: doc.documentID, storageSection: FoodStorageType.stringToFoodStorageType(string: (doc.get("storageSection") as? String ?? " ")), timeAdded: doc.get("timeAdded") as? TimeInterval, timeExpires: doc.get("timeExpires") as? TimeInterval, systemItem: systemItem, systemCategory: systemCategory)
                if storageItems.isEmpty == false {
                    storageItems.append(i)
                } else {
                    storageItems = [i]
                }
            }
            itemsReturned(storageItems)
        }
    }
    
    
    static func createItemFrom(text: String) -> Item {
        let systemItem = Search.turnIntoSystemItem(string: text)
        let words = text.split{ !$0.isLetter }.map { (sStr) -> String in
            String(sStr)
        }
        let systemCategory = GenericItem.getCategory(item: systemItem, words: words)
        let item = Item(name: text, selected: false, category: systemCategory.rawValue, store: nil, user: Auth.auth().currentUser?.displayName, ownID: nil, storageSection: nil, timeAdded: nil, timeExpires: nil, systemItem: systemItem, systemCategory: systemCategory)
        return item
    }
    
    static func updateItemForListName(name: String, itemID: String, listID: String, db: Firestore) {
        let reference = db.collection("lists").document(listID).collection("items").document(itemID)
        reference.updateData([
            "name": name
        ])
    }
    static func updateItemForListStore(store: String, itemID: String, listID: String, db: Firestore) {
        let reference = db.collection("lists").document(listID).collection("items").document(itemID)
        reference.updateData([
            "store": store
        ])
    }
    static func updateItemForListCategory(category: String, itemID: String, listID: String, db: Firestore) {
        let reference = db.collection("lists").document(listID).collection("items").document(itemID)
        reference.updateData([
            "category": category
        ])
    }
}

extension Item {
    
    mutating func writeToFirestoreForList(db: Firestore!) {
        let itemRef = db.collection("lists").document("\(SharedValues.shared.listIdentifier!.documentID)").collection("items").document()
        self.ownID = itemRef.documentID
        itemRef.setData([
            "name": self.name,
            "category": self.category!,
            "store": self.store!,
            "user": Auth.auth().currentUser?.displayName as Any,
            "selected": self.selected,
            "systemItem": "\(self.systemItem ?? .other)",
            "systemCategory": "\(self.systemCategory ?? .other)"
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
            "store": self.store as Any,
            "user": Auth.auth().currentUser?.displayName as Any,
            "ownID": reference.documentID,
            "storageSection": self.storageSection?.string ?? FoodStorageType.unsorted.string,
            "timeAdded": Date().timeIntervalSince1970,
            "timeExpires": self.timeExpires as Any,
            "systemItem": "\(self.systemItem ?? .other)",
            "systemCategory": "\(self.systemCategory ?? .other)"
        ])
    }
    
    
    func selectedItem(db: Firestore) { db.collection("lists").document("\(SharedValues.shared.listIdentifier!.documentID)").collection("items").document(self.ownID!).updateData([
            "selected": self.selected
        ])
    }
    
    
    func switchItemToSegment(named: String, db: Firestore/*, storageID: String*/) {
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
    
    
    func deleteItemFromStorage(db: Firestore, storageID: String) {
        print(storageID)
        let documentRef = db.collection("storages").document(SharedValues.shared.foodStorageID ?? " ").collection("items").document(self.ownID ?? " ")
        documentRef.delete()
    }
    
    func deleteItemFromStorageFromSpecificStorageID(db: Firestore, storageID: String) {
        let documentRef = db.collection("storages").document(storageID).collection("items").document(self.ownID ?? " ")
        documentRef.delete()
    }
    
    func deleteItemFromList(db: Firestore, listID: String) {
        let documentRef = db.collection("lists").document(listID).collection("items").document(self.ownID ?? " ")
        documentRef.delete()
    }
}


extension Sequence where Element == Item {
    func sortItemsForTableView(segment: FoodStorageType, searchText: String) -> [Item] {
        var returnSorted = self.filter({$0.storageSection == segment})
        returnSorted.sort { (i1, i2) -> Bool in
            i1.timeExpires ?? 0 < i2.timeExpires ?? 0
        }
        if searchText != "" {
            returnSorted = returnSorted.filter({ (itm) -> Bool in
                //itm.name.lowercased().starts(with: searchText.lowercased())
                itm.name.lowercased().contains(searchText.lowercased())
            })
        }
        return returnSorted
    }
}


#warning("make sure this is being used")
extension QueryDocumentSnapshot {
    func getItem() -> Item {
        let systemItem = GenericItem(rawValue: self.get("systemItem") as? String ?? "other")
        let systemCategory = Category(rawValue: self.get("systemCategory") as? String ?? "other")
        let i = Item(name: self.get("name") as! String, selected: self.get("selected")! as! Bool, category: (self.get("category") as! String), store: (self.get("store") as! String), user: (self.get("user") as? String), ownID: self.documentID, storageSection: FoodStorageType.stringToFoodStorageType(string: (self.get("storageSection") as? String ?? " ")), timeAdded: self.get("timeAdded") as? TimeInterval, timeExpires: self.get("timeExpires") as? TimeInterval, systemItem: systemItem, systemCategory: systemCategory)
        return i
    }
}
