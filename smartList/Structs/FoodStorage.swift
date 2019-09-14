//
//  Storage.swift
//  smartList
//
//  Created by Steven Dito on 9/9/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import Foundation
import FirebaseFirestore

struct FoodStorage {
    var isGroup: Bool?
    var groupID: String?
    var peopleEmails: [String]?
    var items: [Item]?
    var numberOfPeople: Int?
    
    init(isGroup: Bool?, groupID: String?, peopleEmails: [String]?, items: [Item]?, numberOfPeople: Int?) {
        self.isGroup = isGroup
        self.groupID = groupID
        self.peopleEmails = peopleEmails
        self.items = items
        self.numberOfPeople = numberOfPeople
    }
    
    
    static func createStorageToFirestoreWithPeople(db: Firestore!, foodStorage: FoodStorage) {
        // need to write the storage to the individuals in people, create the storage
        let foodStorageRef = db.collection("storages").document()
        foodStorageRef.setData([
            "emails": foodStorage.peopleEmails as Any,
            "isGroup": foodStorage.isGroup as Any,
            "groupID": foodStorage.groupID as Any,
            "numPeople": foodStorage.numberOfPeople as Any,
            "ownID": foodStorageRef.documentID
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written")
                
                // will handle writing to the user's file in this part
                var userIDs: [String] = []
                foodStorage.peopleEmails?.forEach({ (email) in
                    db.collection("users").whereField("email", isEqualTo: email).getDocuments(completion: { (querySnapshot, err) in
                        if let doc = querySnapshot?.documents.first {
                            if let id = doc.get("uid") as? String {
                                userIDs.append(id)
                                db.collection("users").document(id).updateData([
                                    "storageID": foodStorageRef.documentID
                                    ])
                                
                            }
                        }
                        let updateDoc = db.collection("storages").document(foodStorageRef.documentID)
                        updateDoc.updateData([
                            "shared": userIDs
                        ])
                    })
                })
            }
        }
    }
    
}
