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
    
    static func readAllUserLists(db: Firestore, userID: String) -> [List] {
        var lists: [List] = []
        db.collection("lists").whereField("user", isEqualTo: userID).addSnapshotListener { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(String(describing: error))")
                return
            }
            
            for doc in documents {
                let l = List(name: doc.get("name") as! String, stores: (doc.get("stores") as! [String]), categories: (doc.get("categories") as! [String]), people: (doc.get("people") as! [String]), items: nil, numItems: nil/*(doc.get("numItems") as! Int)*/, docID: doc.documentID)
                if lists.isEmpty == false {
                    lists.append(l)
                } else {
                    lists = [l]
                }
            }
        }
        return lists
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
            }
        }
    }
    
}
