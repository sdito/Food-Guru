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



protocol GroceryListDelegate: class {
    func itemsUpdated()
    func reloadTable()
    func updateListUI()
    func potentialUiForRow(item: Item)
}



class GroceryList {
    
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
    var systemCategories: [String] = Category.allCases.map { (ctgry) -> String in
        "\(ctgry)"
    }
    var itemListener: ListenerRegistration?
    var listListener: ListenerRegistration?
    weak var delegate: GroceryListDelegate!
    
    init(name: String, isGroup: Bool?, stores: [String]?, people: [String]?, items: [Item]?, numItems: Int?, docID: String?, timeIntervalSince1970: TimeInterval?, groupID: String?, ownID: String?) {
        self.name = name
        self.isGroup = isGroup
        self.stores = stores
        self.people = people
        self.items = items
        self.numItems = numItems
        self.docID = docID
        self.timeIntervalSince1970 = timeIntervalSince1970
        self.groupID = groupID
        self.ownID = ownID
    }
    
    // MARK: General
    
    func listenerOnListWithDocID(db: Firestore, docID: String) {
        let reference = db.collection("lists").document(docID)
        listListener?.remove()
        listListener = reference.addSnapshotListener { (docSnapshot, error) in
            if let doc = docSnapshot {
                if doc.get("name") != nil {
                    self.name = doc.get("name") as! String
                    self.people = doc.get("people") as? [String]
                    self.stores = doc.get("stores") as? [String]
                    self.items = self.removeItemsThatNoLongerBelong()
                    self.delegate?.updateListUI()

                }
            }
        }
    }
    
    // to update list information i.e. if stores changed
    
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
                
                var storeForItems: String {
                    if self.stores?.isEmpty == false && self.stores != nil {
                        return self.stores!.first!
                    } else {
                        return ""
                    }
                }
                
                // Need to get the items that do not have a store associated with them, from there make the user either sort all those items or just move them all to one store
                if self.stores?.isEmpty == false && self.stores != nil {
                    if let items = self.items {
                        for item in items {
                            if item.store == "", let itemID = item.ownID {
                                print("Should be chaning the store to: \(storeForItems)")
                                let itemRef = db.collection("lists").document(listID).collection("items").document(itemID)
                                itemRef.updateData([
                                    "store": storeForItems
                                ])
                            }
                        }
                    }
                }
                
                if let items = self.items {
                    if let stores = self.stores {
                        for item in items {
                            if let store = item.store {
                                if !stores.contains(store) {
                                    if let itemID = item.ownID {
                                        let itemRef = db.collection("lists").document(listID).collection("items").document(itemID)
                                        itemRef.updateData([
                                            "store": storeForItems
                                        ])
                                    }
                                }
                            } else {
                                if let itemID = item.ownID {
                                    let itemRef = db.collection("lists").document(listID).collection("items").document(itemID)
                                    itemRef.updateData([
                                        "store": storeForItems
                                    ])
                                }
                            }
                        }
                    } else {
                        for item in items {
                            if item.store != "" {
                                if let itemID = item.ownID {
                                    let itemRef = db.collection("lists").document(listID).collection("items").document(itemID)
                                    itemRef.updateData([
                                        "store": storeForItems
                                    ])
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    
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
    
    
    
    
    class func updateListTimeIntervalTime(db: Firestore, listID: String, timeToSetTo timeInterval: TimeInterval) {
        let reference = db.collection("lists").document(listID)
        reference.updateData([
            "timeIntervalSince1970": timeInterval
        ])
    }
    
    // MARK: Items
    
    func readItemsForList(db: Firestore, docID: String) {
        itemListener?.remove()
        itemListener = db.collection("lists").document(docID).collection("items").addSnapshotListener { (querySnapshot, error) in
            guard let docs = querySnapshot?.documentChanges else {
                self.items = nil
                return
            }
            docs.forEach { (doc) in
                switch doc.type {
                case .added, .modified:
                    self.items?.removeAll(where: { (itm) -> Bool in
                        itm.ownID == doc.document.documentID
                    })
                    let item = doc.document.getItem()
                    self.items?.append(item)
                    
                    if doc.type == .added {
                        self.delegate.potentialUiForRow(item: item)
                    }
                case .removed:
                    self.items?.removeAll(where: { (itm) -> Bool in
                        itm.ownID == doc.document.documentID
                    })
                }
            }
            self.delegate!.itemsUpdated()
        }
    }
    
    // MARK: User
    
    class func getUsersCurrentList(db: Firestore, userID: String, listReturned: @escaping (_ list: GroceryList?) -> Void) {
        var listID: GroceryList?
        db.collection("lists").whereField("shared", arrayContains: userID).order(by: "timeIntervalSince1970", descending: true).limit(to: 1).getDocuments { (querySnapshot, error) in
            if let doc = querySnapshot?.documents.first {
                listID = GroceryList(name: doc.get("name") as! String, isGroup: doc.get("isGroup") as? Bool, stores: (doc.get("stores") as! [String]), people: (doc.get("people") as! [String]), items: nil, numItems: (doc.get("numItems") as! Int?), docID: doc.documentID, timeIntervalSince1970: doc.get("timeIntervalSince1970") as? TimeInterval, groupID: doc.get("groupID") as? String, ownID: doc.get("ownID") as? String)
            }
            listReturned(listID)
        }
    }
    
    // used for ListHomeVC to allow user to select all posible lists
    class func readAllUserLists(db: Firestore, userID: String, listsChanged: @escaping (_ lists: [GroceryList]) -> Void) {
        var lists: [GroceryList] = []
        db.collection("lists").whereField("shared", arrayContains: userID).addSnapshotListener { (querySnapshot, error) in
            lists.removeAll()
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(String(describing: error))")
                return
            }
            for doc in documents {
                let l = GroceryList(name: doc.get("name") as! String, isGroup: doc.get("isGroup") as? Bool, stores: (doc.get("stores") as! [String]), people: (doc.get("people") as! [String]), items: nil, numItems: (doc.get("numItems") as? Int), docID: doc.documentID, timeIntervalSince1970: doc.get("timeIntervalSince1970") as? TimeInterval, groupID: doc.get("groupID") as? String, ownID: doc.get("ownID") as? String)
                
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
    
    // MARK: Recipe
    class func handleProcessForAutomaticallyGeneratedListFromRecipe(db: Firestore, items: [String]) {
        let reference = db.collection("lists").document()
        let uid = Auth.auth().currentUser?.uid
        SharedValues.shared.listIdentifier = reference
        
        var listName: String {
            if let name = Auth.auth().currentUser?.displayName {
                return "\(name)'s grocery list"
            } else {
                return "Grocery list"
            }
        }
        
        reference.setData([
            "name": listName,
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
                        String(sStr.lowercased())
                    }
                    let genericItem = Search.turnIntoSystemItem(string: i)
                    let category = GenericItem.getCategory(item: genericItem, words: words)
                    
                    let ingAndQuan = i.getQuantityFromIngredient()
                    let item = Item(name: ingAndQuan.ingredient, selected: false, category: category.rawValue, store: "", user: nil, ownID: nil, storageSection: nil, timeAdded: nil, timeExpires: nil, systemItem: genericItem, systemCategory: category, quantity: ingAndQuan.quantity)
                    let ref = db.collection("lists").document(SharedValues.shared.listIdentifier!.documentID).collection("items").document()
                    ref.setData([
                        "name": item.name,
                        "category": item.category!,
                        "store": item.store!,
                        "user": Auth.auth().currentUser?.displayName as Any,
                        "selected": item.selected,
                        "systemItem": "\(item.systemItem ?? .other)",
                        "systemCategory": "\(item.systemCategory ?? .other)",
                        "quantity": item.quantity as Any
                    ]) { err in
                        if let err = err {
                            print("Error writing document for new list from recipe: \(err)")
                        } else {
                            print("Document successfully written")
                            NotificationCenter.default.post(name: .itemAddedFromRecipe, object: nil, userInfo: ["itemName": i])
                        }
                    }
                }
            }
        }
    }
    
    static func addItemToListFromRecipe(db: Firestore, listID: String, name: String, userID: String, store: String) {
        let reference = db.collection("lists").document(listID).collection("items").document()
        let genericName = Search.turnIntoSystemItem(string: name)
        let words = name.split{ !$0.isLetter }.map { (sStr) -> String in
            String(sStr.lowercased())
        }
        
        let ingAndQuan = name.getQuantityFromIngredient()
        let genericCategory = GenericItem.getCategory(item: genericName, words: words)
        reference.setData([
            "name": ingAndQuan.ingredient,
            "selected": false,
            "store": store,
            "user": Auth.auth().currentUser?.displayName as Any,
            "systemCategory": "\(genericCategory)",
            "category": "\(genericCategory)",
            "systemItem": "\(genericName)",
            "quantity": ingAndQuan.quantity
        ]) { err in
            if let err = err {
                print("Error adding item from recipe to list: \(err)")
            } else {
                print("Document successfully written")
                NotificationCenter.default.post(name: .itemAddedFromRecipe, object: nil, userInfo: ["itemName": name])
                
            }
        }
    }
    
    
    
    // MARK: UI
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
                
                if i1.name != i2.name {
                    return i1.name < i2.name
                } else {
                    return i1.ownID ?? "b" < i2.ownID ?? "a"
                }
                
                
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


// MARK: Sequence
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
