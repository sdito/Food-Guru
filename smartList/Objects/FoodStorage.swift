//
//  Storage.swift
//  smartList
//
//  Created by Steven Dito on 9/9/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

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
    
    
    static func addItemsFromListintoFoodStorage(sendList: GroceryList, storageID: String, db: Firestore) {
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
    static func checkForUsersAlreadyInStorage(db: Firestore, groupID: String, isStorageValid: @escaping (_ boolean: Bool?, _ emails: [String]?) -> Void) {
        var storageValid = true
        var emails: [String]?
        let reference = db.collection("groups").document(groupID)
        reference.getDocument { (docSnapshot, error) in
            guard let doc = docSnapshot else { return }
            if doc.get("ownUserStorages") as? [String] != nil && doc.get("ownUserStorages") as? [String] != [] {
                storageValid = false
                emails = doc.get("ownUserStorages") as? [String]
            }
            isStorageValid(storageValid, emails)
        }
    }
    
    static func createStorageToFirestoreWithPeople(db: Firestore!, foodStorage: FoodStorage) {
        // need to check that no users already have a storage, need to write the storage to the individuals in people, create the storage
        checkForUsersAlreadyInStorage(db: db, groupID: SharedValues.shared.groupID ?? " ") { (boolean, inStorageEmails) in
            if boolean == true || foodStorage.isGroup == false {
                if foodStorage.peopleEmails?.count == 1 && foodStorage.isGroup == false {
                    db.collection("groups").document(SharedValues.shared.groupID ?? " ").updateData([
                        "ownUserStorages" : FieldValue.arrayUnion([foodStorage.peopleEmails?.first as Any])
                    ])
                }
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
                        
                        if SharedValues.shared.anonymousUser == false {
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
                        } else {
                            let updateDoc = db.collection("storages").document(foodStorageRef.documentID)
                            if let uid = Auth.auth().currentUser?.uid {
                                updateDoc.updateData([
                                    "shared": [uid]
                                ])
                                let userReference = db.collection("users").document(uid)
                                userReference.updateData([
                                    "storageID": foodStorageRef.documentID
                                ])
                            }
                        }
                    }
                }
            } else {
                var s: String {
                    if inStorageEmails?.count == 1 {
                        return ""
                    } else {
                        return "s"
                    }
                }
                let alert = UIAlertController(title: "Error", message: "Unable to create storage with your group because someone in your group already is in their own storage. Member\(s) in storage already: \(inStorageEmails?.joined(separator: ", ") ?? "")", preferredStyle: .alert)
                alert.addAction(.init(title: "Ok", style: .default, handler: nil))
                UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true)
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
        
        if let groupID = SharedValues.shared.groupID {
            if let email = Auth.auth().currentUser?.email {
                db.collection("groups").document(groupID).updateData([
                    "ownUserStorages": FieldValue.arrayRemove([email])
                ])
            }
        }
        
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
        
        if SharedValues.shared.anonymousUser == true {
            db.collection("users").document(Auth.auth().currentUser?.uid ?? " ").updateData([
                "storageID": FieldValue.delete()
            ])
        }
        
        // doesnt matter when actual storage document is deleted, just need to make sure it would be deleted after the groupID is deleted from the user document
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            print("Deleting storage")
            reference.delete()
        }
        
    }
    
    static func readAndPersistSystemItemsFromStorageWithListener(db: Firestore, storageID: String) {
        let reference = db.collection("storages").document(storageID).collection("items")
        reference.addSnapshotListener { (querySnapshot, error) in
            var items: [String] = []
            guard let documents = querySnapshot?.documents else {
                print("Error retrieving documents: \(String(describing: error))")
                return
            }
            
            for doc in documents {
                let systemItem = doc.get("systemItem") as? String ?? "other"
                items.append(systemItem)
                
            }
            SharedValues.shared.currentItemsInStorage?.removeAll()
            SharedValues.shared.currentItemsInStorage = items
            
        }
    }
    
    
    
    #warning("make sure this is being used below")
    static func findIfUsersStorageIsWithGroup(db: Firestore, storageID: String) {
        let reference = db.collection("storages").document(storageID)
        reference.getDocument { (documentSnapshot, error) in
            guard let doc = documentSnapshot else { return }
            if let isWithGroup = doc.get("isGroup") as? Bool {
                if isWithGroup == true {
                    SharedValues.shared.isStorageWithGroup = true
                } else {
                    SharedValues.shared.isStorageWithGroup = false
                }
            } else {
                SharedValues.shared.isStorageWithGroup = false
            }
        }
    }
    
    #warning("need to make sure this is being used")
    static func addForStorageInformationToGroupMembersProfile(db: Firestore, foodStorageID: String, email: String) {
        // need to get the uid from the email
        User.turnEmailToUid(db: db, email: email) { (uid) in
            if let uid = uid {
                
                let reference = db.collection("users").document(uid)
                reference.updateData([
                    "storageID": foodStorageID
                ]) { err in
                    if let err = err {
                        print("Error merging storage at group profile: \(err)")
                    } else {
                        print("Successfully updated user profile in merging storages to group")
                        let reference = db.collection("storages").document(foodStorageID)
                        reference.updateData([
                            "shared" : FieldValue.arrayUnion([uid])
                        ])
                    }
                }
            }
        }
    }
    
    #warning("need to make sure this is being used")
    static func updateDataInStorageDocument(db: Firestore, foodStorageID: String, emails: [String]) {
        // uids are added to 'shared' in the addForStorageInformationToGroupMembersProfile function
        // need to update 'numPeople' and 'emails'
        // emails need to be the emails for the GROUP MEMBERS
        let reference = db.collection("storages").document(foodStorageID)
        reference.updateData([
            "emails" : emails,
            "numPeople": emails.count,
            "isGroup": true
        ])
        
        
    }
    
    
}
