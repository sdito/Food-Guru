//
//  Search.swift
//  smartList
//
//  Created by Steven Dito on 10/8/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import Foundation
import FirebaseFirestore


struct Search {
    static func searchForRecipe(db: Firestore, item1: String?, item2: String?, descriptor: String?, cuisine: String?) {
        let reference1 = db.collection("recipes").whereField("ingredients", arrayContains: item1)
        let reference2 = db.collection("recipes").whereField("ingredients", arrayContains: item2!)
        reference2.getDocuments { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("Error retrieving documents: \(String(describing: error))")
                return
            }
            for doc in documents {
                print(doc.data())
            }
        }
        
    }
}
