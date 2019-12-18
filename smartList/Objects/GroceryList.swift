//
//  List.swift
//  smartList
//
//  Created by Steven Dito on 8/6/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

struct GroceryList {
    var name: String
    var isGroup: Bool?
    var stores: [String]?
    var people: [String]?
    var items: [Item]?
    var numItems: Int?
    var docID: String?
    var timeIntervalSince1970: TimeInterval?
    var groupID: String?
    var ownID: String?
    //var categories: [String]?
    var systemCategories: [String] = Category.allCases.map { (ctgry) -> String in
        "\(ctgry)"
    }
    
    init(name: String, isGroup: Bool?, stores: [String]?, /*categories: [String]?, */people: [String]?, items: [Item]?, numItems: Int?, docID: String?, timeIntervalSince1970: TimeInterval?, groupID: String?, ownID: String?) {
        self.name = name
        self.isGroup = isGroup
        self.stores = stores
        //self.categories = categories
        self.people = people
        self.items = items
        self.numItems = numItems
        self.docID = docID
        self.timeIntervalSince1970 = timeIntervalSince1970
        self.groupID = groupID
        self.ownID = ownID
    }
    
    
    static func getUsersCurrentList(db: Firestore, userID: String, listReturned: @escaping (_ list: GroceryList?) -> Void) {
        var listID: GroceryList?
        db.collection("lists").whereField("shared", arrayContains: userID).order(by: "timeIntervalSince1970", descending: true).limit(to: 1).getDocuments { (querySnapshot, error) in
            if let doc = querySnapshot?.documents.first {
                listID = GroceryList(name: doc.get("name") as! String, isGroup: doc.get("isGroup") as? Bool, stores: (doc.get("stores") as! [String]), people: (doc.get("people") as! [String]), items: nil, numItems: (doc.get("numItems") as! Int?), docID: doc.documentID, timeIntervalSince1970: doc.get("timeIntervalSince1970") as? TimeInterval, groupID: doc.get("groupID") as? String, ownID: doc.get("ownID") as? String)
            }
            listReturned(listID)
        }
    }
    
    static func listenerOnListWithDocID(db: Firestore, docID: String, listReturned: @escaping (_ list: GroceryList?) -> Void) {
        let reference = db.collection("lists").document(docID)
        var l: GroceryList?
        reference.addSnapshotListener { (docSnapshot, error) in
            if let doc = docSnapshot {
                if doc.get("name") != nil {
                    l = GroceryList(name: doc.get("name") as! String, isGroup: doc.get("isGroup") as? Bool, stores: (doc.get("stores") as! [String]), people: (doc.get("people") as! [String]), items: nil, numItems: (doc.get("numItems") as! Int?), docID: doc.documentID, timeIntervalSince1970: doc.get("timeIntervalSince1970") as? TimeInterval, groupID: doc.get("groupID") as? String, ownID: doc.get("ownID") as? String)
                }
                
            }
            listReturned(l)
        }
    }
    
    static func readAllUserLists(db: Firestore, userID: String, listsChanged: @escaping (_ lists: [GroceryList]) -> Void) {
        var lists: [GroceryList] = []
        db.collection("lists").whereField("shared", arrayContains: userID).addSnapshotListener { (querySnapshot, error) in
            lists.removeAll()
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(String(describing: error))")
                return
            }
            for doc in documents {
                let l = GroceryList(name: doc.get("name") as! String, isGroup: doc.get("isGroup") as? Bool, stores: (doc.get("stores") as! [String]), people: (doc.get("people") as! [String]), items: nil, numItems: (doc.get("numItems") as! Int?), docID: doc.documentID, timeIntervalSince1970: doc.get("timeIntervalSince1970") as? TimeInterval, groupID: doc.get("groupID") as? String, ownID: doc.get("ownID") as? String)
                
                if lists.isEmpty == false {
                    lists.append(l)
                } else {
                    lists = [l]
                }
            }
            lists = lists.sorted(by: { (l1, l2) -> Bool in
                l1.timeIntervalSince1970 ?? 0 > l2.timeIntervalSince1970 ?? 0
            })
            listsChanged(lists)
        }
    }
    
    static func addItemToListFromRecipe(db: Firestore, listID: String, name: String, userID: String, store: String) {
        let reference = db.collection("lists").document(listID).collection("items").document()
        let genericName = Search.turnIntoSystemItem(string: name)
        let words = name.split{ !$0.isLetter }.map { (sStr) -> String in
            String(sStr)
        }
        let genericCategory = GenericItem.getCategory(item: genericName, words: words)
        reference.setData([
            "name": name,
            "selected": false,
            "store": store,
            "user": userID,
            "systemCategory": "\(genericCategory)",
            "category": "\(genericCategory)",
            "systemItem": "\(genericName)"
        ]) { err in
            if let err = err {
                print("Error adding item from recipe to list: \(err)")
            } else {
                print("Document successfully written")
                NotificationCenter.default.post(name: .itemAddedFromRecipe, object: nil, userInfo: ["itemName": name])
            }
        }
    }
    
    static func handleProcessForAutomaticallyGeneratedListFromRecipe(db: Firestore, items: [String]) {
        #warning("this should work, probbaly need to test it a few more times just to make sure")
        let reference = db.collection("lists").document()
        let uid = Auth.auth().currentUser?.uid
        SharedValues.shared.listIdentifier = reference
        
        reference.setData([
            "name": "Grocery List",
            "isGroup": false,
            "stores": [],
            "people": [""],
            "shared": [Auth.auth().currentUser!.uid] as Any,
            "user": uid as Any,
            "timeIntervalSince1970": Date().timeIntervalSince1970,
            "ownID": SharedValues.shared.listIdentifier?.documentID as Any
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                for i in items {
                    let words = i.split{ !$0.isLetter }.map { (sStr) -> String in
                        String(sStr)
                    }
                    let genericItem = Search.turnIntoSystemItem(string: i)
                    let category = GenericItem.getCategory(item: genericItem, words: words)
                    
                    let item = Item(name: i, selected: false, category: category.rawValue, store: "", user: nil, ownID: nil, storageSection: nil, timeAdded: nil, timeExpires: nil, systemItem: genericItem, systemCategory: category)
                    let ref = db.collection("lists").document(SharedValues.shared.listIdentifier!.documentID).collection("items").document()
                    ref.setData([
                        "name": item.name,
                        "category": item.category!,
                        "store": item.store!,
                        "user": SharedValues.shared.userID ?? "did not write",
                        "selected": item.selected,
                        "systemItem": "\(item.systemItem ?? .other)",
                        "systemCategory": "\(item.systemCategory ?? .other)"
                    ]) { err in
                        if let err = err {
                            print("Error writing document for new list from recipe: \(err)")
                        } else {
                            print("Document successfully written")
                        }
                    }
                }
                
            }
        }
    }
    
}


extension GroceryList {
    func writeToFirestore(db: Firestore!) {
        SharedValues.shared.listIdentifier = db.collection("lists").document()
        SharedValues.shared.listIdentifier?.setData([
            "name": self.name,
            "isGroup": self.isGroup ?? false,
            "stores": self.stores as Any,
            "people": Array(Set(self.people!)).sorted(),
            "user": SharedValues.shared.userID ?? "did not write",
            "timeIntervalSince1970": Date().timeIntervalSince1970,
            "groupID": self.groupID as Any,
            "ownID": SharedValues.shared.listIdentifier?.documentID as Any
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written")
                User.emailToUid(emails: self.people, db: db, listID: SharedValues.shared.listIdentifier!.documentID)
            }
        }
    }
    
    
    func deleteListToFirestore(db: Firestore!) {
        db.collection("lists").document(self.docID ?? " ").delete()
    }
    
    
    func editListToFirestore(db: Firestore!, listID: String) {
        
        db.collection("lists").document(listID).updateData([
            "name": self.name,
            "stores": self.stores!,
            "people": Array(Set(self.people!)).sorted(),
            "timeIntervalSince1970": Date().timeIntervalSince1970
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document sucessfully updated")
                User.emailToUid(emails: self.people, db: db, listID: listID)
                if self.stores?.isEmpty == false {
                    // Need to get the items that do not have a store associated with them, from there make the user either sort all those items or just move them all to one store
                    let itemsReference = db.collection("lists").document(listID).collection("items").whereField("store", isEqualTo: "")
                    
                    itemsReference.getDocuments { (querySnapshot, error) in
                        guard let documents = querySnapshot?.documents else {
                            print("Error reading documents: \(error?.localizedDescription ?? "error")")
                            return
                        }
                        
                        // documents are the items that have no store
                        for doc in documents {
                            let id = doc.documentID
                            if let store = self.stores?.last {
                                let specificItemReference = db.collection("lists").document(listID).collection("items").document(id)
                                specificItemReference.updateData([
                                    "store" : store
                                ])
                            }
                        }
                        
//                        #error("need to update the UI to reflect that there are stores now")
                        
                    }
                }
                
                
                
                
                
            }
        }
    }
    
    func removeItemsThatNoLongerBelong() -> [Item] {
        let dontDelete = ""
        var stores: Set<String> = Set(self.stores ?? [dontDelete])
        stores.insert(dontDelete)
        var goodItems: [Item] = []
        if let items = self.items {
            for item in items {
                if stores.contains(item.store ?? "") {
                    goodItems.append(item)
                } else {
                    print("Item is being deleted: \(item.name)")
                    item.deleteItemFromList(db: Firestore.firestore(), listID: self.docID ?? " ")
                }
            }
        }
        return goodItems
    }
    
    func sortForTableView(from store: String) -> ([String], [[Item]]) {
        var categories = self.systemCategories
        var sortedItems: [[Item]] = []
        
        categories.forEach({ (category) in
            var itms: [Item] = []
            self.items?.forEach({ (itm) in
                //print(store)
                if itm.category == category && itm.store == store {
                    itms.append(itm)
                }
            })
            let itmsInOrder = itms.sorted(by: { (i1, i2) -> Bool in
                i1.name < i2.name
            })
            if itmsInOrder.isEmpty == false {
                sortedItems.append(itmsInOrder)
            } else {
                if let idx = categories.firstIndex(of: category) {
                    categories.remove(at: idx)
                }
                
            }

        })
        let textDescription = categories.map { (str) -> String in
            (Category(rawValue: str)?.textDescription ?? "Other")
        }
        return (textDescription, sortedItems)
    }
}


extension Sequence where Element == GroceryList {
    func organizeTableViewForListHome() -> ([String]?, [[GroceryList]]?) {
        let lists = self as? [GroceryList]
        switch lists?.count {
        case nil:
            return (nil, nil)
        case 1:
            return (["Current list"], [lists!])
        default:
            
            var notFirst = lists
            if notFirst?.count ?? 0 >= 2 {
                notFirst?.remove(at: 0)
                return (["Current list", "Past lists"], [[(lists?.first)!], notFirst!])
            } else {
                return (nil, nil)
            }
            
        }
    }
}
