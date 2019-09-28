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
    var categories: [String]?
    var people: [String]?
    var items: [Item]?
    var numItems: Int?
    var docID: String?
    var timeIntervalSince1970: TimeInterval?
    var groupID: String?
    
    
    init(name: String, isGroup: Bool?, stores: [String]?, categories: [String]?, people: [String]?, items: [Item]?, numItems: Int?, docID: String?, timeIntervalSince1970: TimeInterval?, groupID: String?) {
        self.name = name
        self.isGroup = isGroup
        self.stores = stores
        self.categories = categories
        self.people = people
        self.items = items
        self.numItems = numItems
        self.docID = docID
        self.timeIntervalSince1970 = timeIntervalSince1970
        self.groupID = groupID
    }
    
    static func listenerOnListWithDocID(db: Firestore, docID: String, listReturned: @escaping (_ list: List?) -> Void) {
        let reference = db.collection("lists").document(docID)
        var l: List?
        reference.addSnapshotListener { (docSnapshot, error) in
            if let doc = docSnapshot {
                if doc.get("name") != nil {
                  l = List(name: doc.get("name") as! String, isGroup: doc.get("isGroup") as? Bool, stores: (doc.get("stores") as! [String]), categories: (doc.get("categories") as! [String]), people: (doc.get("people") as! [String]), items: nil, numItems: (doc.get("numItems") as! Int?), docID: doc.documentID, timeIntervalSince1970: doc.get("timeIntervalSince1970") as? TimeInterval, groupID: doc.get("groupID") as? String)
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
                let l = List(name: doc.get("name") as! String, isGroup: doc.get("isGroup") as? Bool, stores: (doc.get("stores") as! [String]), categories: (doc.get("categories") as! [String]), people: (doc.get("people") as! [String]), items: nil, numItems: (doc.get("numItems") as! Int?), docID: doc.documentID, timeIntervalSince1970: doc.get("timeIntervalSince1970") as? TimeInterval, groupID: doc.get("groupID") as? String)
                
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
}


extension List {
    func writeToFirestore(db: Firestore!) {
        SharedValues.shared.listIdentifier = db.collection("lists").document()
        SharedValues.shared.listIdentifier?.setData([
            "name": self.name,
            "isGroup": self.isGroup ?? false,
            "stores": self.stores!,
            "categories": self.categories!,
            "people": Array(Set(self.people!)).sorted(),
            "user": SharedValues.shared.userID ?? "did not write",
            "timeIntervalSince1970": Date().timeIntervalSince1970,
            "groupID": self.groupID as Any
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
            "categories": self.categories!,
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
        let categories: Set<String> = Set(self.categories ?? [""])
        let stores: Set<String> = Set(self.stores ?? [""])
        var goodItems: [Item] = []
        if let items = self.items {
            for item in items {
                if categories.contains(item.category ?? "") && stores.contains(item.store ?? "") {
                    goodItems.append(item)
                } else {
                    print("Item is being deleted: \(item.name)")
                    item.deleteItemFromList(db: Firestore.firestore(), listID: self.docID ?? " ")
                }
            }
        }
        return goodItems
    }
    
    func sortForTableView(from store: String) -> ([String]?, [[Item]]) {
        
        var categories = self.categories?.sorted()
        categories?.append("")
        var sortedItems: [[Item]] = []
        
        if categories?.isEmpty == true {
            // will never get called at the moment since "" is being appended to categories before this
            categories = ["All"]
            let itmsForValue = self.items?.sorted(by: { (i1, i2) -> Bool in
                i1.name < i2.name
            })
            sortedItems = [itmsForValue] as! [[Item]]
        } else {
            categories?.forEach({ (category) in
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
                
                sortedItems.append(itmsInOrder)
            })
        }
        
        return (categories, sortedItems)
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
