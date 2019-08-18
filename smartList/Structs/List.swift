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
    var stores: [String]?
    var categories: [String]?
    var people: [String]?
    var items: [Item]?
    var numItems: Int?
    var docID: String?
    
    init(name: String, stores: [String]?, categories: [String]?, people: [String]?, items: [Item]?, numItems: Int?, docID: String?) {
        self.name = name
        self.stores = stores
        self.categories = categories
        self.people = people
        self.items = items
        self.numItems = numItems
        self.docID = docID
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
                let l = List(name: doc.get("name") as! String, stores: (doc.get("stores") as! [String]), categories: (doc.get("categories") as! [String]), people: (doc.get("people") as! [String]), items: nil, numItems: (doc.get("numItems") as! Int?), docID: doc.documentID)
                if lists.isEmpty == false {
                    lists.append(l)
                } else {
                    lists = [l]
                }
            }
            listsChanged(lists)
            // has the correct value in lists right here, returns [] though
        }
        //db.collection("lists").whereField("shared", arrayContains: userID)
    }
}


extension List {
    func writeToFirestore(db: Firestore!) {
        SharedValues.shared.listIdentifier = db.collection("lists").document()
        SharedValues.shared.listIdentifier?.setData([
            "name": self.name,
            "stores": self.stores!,
            "categories": self.categories!,
            "people": self.people!,
            "user": SharedValues.shared.userID ?? "did not write"
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written")
                User.emailToUid(emails: self.people, db: db, listID: SharedValues.shared.listIdentifier!.documentID)
            }
        }
    }
    func sortForTableView(from store: String) -> ([String]?, [[Item]]) {
        var categories = self.categories?.sorted()
        var sortedItems: [[Item]] = []
        
        if categories?.isEmpty == true {
            categories = ["All"]
            let itmsForValue = self.items?.sorted(by: { (i1, i2) -> Bool in
                i1.name < i2.name
            })
            sortedItems = [itmsForValue] as! [[Item]]
        } else {
            categories?.forEach({ (category) in
                var itms: [Item] = []
                self.items?.forEach({ (itm) in
                    if itm.category == category {
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
