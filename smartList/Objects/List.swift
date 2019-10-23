//
//  List.swift
//  smartList
//
//  Created by Steven Dito on 8/6/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import Foundation
//import FirebaseCore
import FirebaseFirestore

struct List {
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
    static func getUsersCurrentList(db: Firestore, userID: String, listReturned: @escaping (_ list: List?) -> Void) {
        var listID: List?
        db.collection("lists").whereField("shared", arrayContains: userID).order(by: "timeIntervalSince1970", descending: true).limit(to: 1).getDocuments { (querySnapshot, error) in
            if let doc = querySnapshot?.documents.first {
                listID = List(name: doc.get("name") as! String, isGroup: doc.get("isGroup") as? Bool, stores: (doc.get("stores") as! [String]), people: (doc.get("people") as! [String]), items: nil, numItems: (doc.get("numItems") as! Int?), docID: doc.documentID, timeIntervalSince1970: doc.get("timeIntervalSince1970") as? TimeInterval, groupID: doc.get("groupID") as? String, ownID: doc.get("ownID") as? String)
            }
            listReturned(listID)
        }
    }
    
    static func listenerOnListWithDocID(db: Firestore, docID: String, listReturned: @escaping (_ list: List?) -> Void) {
        let reference = db.collection("lists").document(docID)
        var l: List?
        reference.addSnapshotListener { (docSnapshot, error) in
            if let doc = docSnapshot {
                if doc.get("name") != nil {
                    l = List(name: doc.get("name") as! String, isGroup: doc.get("isGroup") as? Bool, stores: (doc.get("stores") as! [String]), people: (doc.get("people") as! [String]), items: nil, numItems: (doc.get("numItems") as! Int?), docID: doc.documentID, timeIntervalSince1970: doc.get("timeIntervalSince1970") as? TimeInterval, groupID: doc.get("groupID") as? String, ownID: doc.get("ownID") as? String)
                }
                
            }
            listReturned(l)
        }
    }
    
    static func readAllUserLists(db: Firestore, userID: String, listsChanged: @escaping (_ lists: [List]) -> Void) {
        var lists: [List] = []
        db.collection("lists").whereField("shared", arrayContains: userID).addSnapshotListener { (querySnapshot, error) in
            lists.removeAll()
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(String(describing: error))")
                return
            }
            for doc in documents {
                let l = List(name: doc.get("name") as! String, isGroup: doc.get("isGroup") as? Bool, stores: (doc.get("stores") as! [String]), people: (doc.get("people") as! [String]), items: nil, numItems: (doc.get("numItems") as! Int?), docID: doc.documentID, timeIntervalSince1970: doc.get("timeIntervalSince1970") as? TimeInterval, groupID: doc.get("groupID") as? String, ownID: doc.get("ownID") as? String)
                
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
        //db.collection("lists").whereField("shared", arrayContains: userID)
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
}


extension List {
    func writeToFirestore(db: Firestore!) {
        SharedValues.shared.listIdentifier = db.collection("lists").document()
        SharedValues.shared.listIdentifier?.setData([
            "name": self.name,
            "isGroup": self.isGroup ?? false,
            "stores": self.stores!,
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
                //#error("list UI is updated on the tableView, but the buttons do not update at the to the new categories and also stores probably, need to delete the items from the list below currently returns nil for both so thats a lot of fun")
                
                
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


extension Sequence where Element == List {
    func organizeTableViewForListHome() -> ([String]?, [[List]]?) {
        let lists = self as? [List]
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