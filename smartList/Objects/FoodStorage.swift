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
    
    
    static func addItemsFromListintoFoodStorage(sendList: List, storageID: String, db: Firestore) {
        for item in sendList.items ?? [] {
            print(item.selected)
            if item.selected == true {
                item.writeToFirestoreForStorage(db: db, docID: storageID)
            }
        }
    }
    
    static func getEmailsfromStorageID(storageID: String, db: Firestore, emailsReturned: @escaping (_ emails: [String]?) -> Void) {
        var emails: [String]?
        db.collection("storages").document(storageID).getDocument { (docSnapshot, error) in
            if let doc = docSnapshot {
                emails = doc.get("emails") as? [String]
            }
            emailsReturned(emails)
        }
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
    static func deleteItemsFromStorage(db: Firestore, storageID: String) {
        db.collection("storages").document(storageID).collection("items").getDocuments { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(String(describing: error))")
                return
            }
            for doc in documents {
                if let itemID = doc.get("ownID") as? String {
                    db.collection("storages").document(storageID).collection("items").document(itemID).delete()
                    print("Item being deleted from storage: \(String(describing: doc.get("name")))")
                }
                
            }
        }
    }
    static func deleteStorage(db: Firestore, storageID: String) {
        // need to delete the storage and also the foodStorageID from user's document
        let reference = db.collection("storages").document(storageID)
        FoodStorage.getEmailsfromStorageID(storageID: storageID, db: db) { (emails) in
            emails?.forEach({ (email) in
                User.turnEmailToUid(db: db, email: email) { (uid) in
                    if let uid = uid {
                      let userReference = db.collection("users").document(uid)
                      print("Deleting from userID: \(uid)")
                      userReference.updateData([
                        "storageID": FieldValue.delete()
                      ])
                    }
                }
            })
        }
        
        // doesnt matter when actual storage document is deleted, just need to make sure it would be deleted after the groupID is deleted from the user document
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            print("Deleting storage")
            reference.delete()
        }
        
    }
}
