//
//  User.swift
//  smartList
//
//  Created by Steven Dito on 8/17/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

struct User {
    
    static func comparePeopleIn(list: List, foodStorageEmails: [String]?) -> (isEqual: Bool, emailsDifferent: [String]?) {
        var listPeople = Set(list.people ?? [])
        var foodStoragePeople = Set(foodStorageEmails ?? [])
        
        if listPeople == foodStoragePeople {
            return (true, nil)
        } else {
            listPeople.subtract(Set(foodStorageEmails ?? []))
            foodStoragePeople.subtract(Set(list.people ?? []))
            
            let both = listPeople.union(foodStoragePeople)
            return (false, Array(both).sorted())
        }
    }
    
    
    static func editedGroupInfo(db: Firestore, initialEmails: [String], updatedEmails: [String], groupID: String, storageID: String) {
        //first need to find out of the storage is part of a group
        db.collection("storages").document(storageID).getDocument { (docSnapshot, error) in
            if let doc = docSnapshot {
                let isGroup = doc.get("isGroup") as? Bool
                switch isGroup {
                // STORAGE IS WITH THE GROUP
                case true:
                    // 1: update the group (email only)
                    db.collection("groups").document(groupID).updateData([
                        "emails": updatedEmails
                    ])
                    
                    // 2: update the storage (emails and uid)
                    db.collection("storages").document(storageID).updateData([
                        "emails": updatedEmails
                    ])
                    
                    var uids: [String] = []
                    for person in updatedEmails {
                        turnEmailToUid(db: db, email: person) { (uid) in
                            uids.append(uid ?? " ")
                            if uids.count == updatedEmails.count {
                                db.collection("storages").document(storageID).updateData([
                                    "shared" : uids
                                ])
                            }
                        }
                    }
                    // 3: update each user
                        // deleted users
                    initialEmails.forEach { (email) in
                        if !updatedEmails.contains(email) {
                            print("need to delete: \(email)")
                            turnEmailToUid(db: db, email: email) { (uid) in
                                db.collection("users").document(uid ?? " ").updateData([
                                    "storageID": FieldValue.delete(),
                                    "groupID": FieldValue.delete()
                                ])
                            }
                        }
                    }
                    
                        // new users
                    updatedEmails.forEach { (email) in
                        if !initialEmails.contains(email) {
                            print("need to add: \(email)")
                            turnEmailToUid(db: db, email: email) { (uid) in
                                db.collection("users").document(uid ?? " ").updateData([
                                    "storageID": storageID,
                                    "groupID": groupID
                                ])
                            }
                        }
                    }
                // STORAGE IS NOT WITH THE GROUP
                case false:
                    // works for adding
                    updatedEmails.forEach { (email) in
                        if !initialEmails.contains(email) {
                            print("need to add: \(email)")
                            turnEmailToUid(db: db, email: email) { (uid) in
                                db.collection("users").document(uid ?? " ").updateData([
                                    "groupID": groupID
                                ])
                            }
                        }
                    }
                    
                    initialEmails.forEach { (email) in
                        if !updatedEmails.contains(email) {
                            print("need to delete: \(email)")
                            turnEmailToUid(db: db, email: email) { (uid) in
                                db.collection("users").document(uid ?? " ").updateData([
                                    "groupID": FieldValue.delete()
                                ])
                            }
                        }
                    }
                    
                    db.collection("groups").document(groupID).updateData([
                        "emails": updatedEmails
                    ])
                    
                default:
                    return
                }
            }
        }
    }
    
    static func emailToUid(emails: [String]?, db: Firestore, listID: String) {
        var userIDs: [String] = []
        emails?.forEach({ (email) in
            db.collection("users").whereField("email", isEqualTo: email).getDocuments { (querySnapshot, err) in
                //print(querySnapshot?.documents.first?.data())
                if let doc = querySnapshot?.documents.first {
                    //print(doc.get("uid"))
                    if let id = doc.get("uid") as? String {
                        userIDs.append(id)
                    }
                }
                let updateDoc = db.collection("lists").document(listID)
                updateDoc.updateData([
                    "shared": userIDs
                ])
            }
        })
    }
    
//    }
    
    
    static func turnEmailToUid(db: Firestore, email: String, uidReturned: @escaping (_ userID: String?) -> Void) {
        var uid: String?
        db.collection("users").whereField("email", isEqualTo: email).getDocuments { (querySnapshot, err) in
            if let doc = querySnapshot?.documents.first {
                if let id = doc.get("uid") as? String {
                    uid = id
                    
                }
            }
            uidReturned(uid)
        }
    }
    static func checkIfEmailIsValid(db: Firestore, email: String, emailCheckReturned: @escaping (_ check: EmailCheck?) -> Void) {
        var emailCheck: EmailCheck = .noUser
        db.collection("users").whereField("email", isEqualTo: email).getDocuments { (querySnapshot, error) in
            if let doc = querySnapshot?.documents.first {
                if doc.get("uid") != nil {
                    if doc.get("groupID") == nil {
                        emailCheck = .approved
                    } else {
                        emailCheck = .alreadyInGroup
                    }
                }
            }
            emailCheckReturned(emailCheck)
        }
    }
    
    static func writeGroupToFirestoreAndAddToUsers(db: Firestore, emails: [String]) {
        #warning("NEED TO CHECK EACH USER AGAIN BEFORE FINALLY WRITING, THEY COULD BE ADDED INTO A GROUP AT THE SAME TIME FROM TWO DIFFERENT DEVICES, OR WRITE A PLACEHOLDER GROUPID VALUE IN THEIR FILE")
        // write the group to firestore first
        let groupRef = db.collection("groups").document()
        let groupDocID = groupRef.documentID
        groupRef.setData([
            "dateCreated": Date().timeIntervalSince1970,
            "ownID": groupDocID,
            "emails": emails
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written")
            }
        }
        
        
        
        // change the user data to add their id to their group
        emails.forEach { (email) in
            db.collection("users").whereField("email", isEqualTo: email).getDocuments(completion: { (querySnapshot, error) in
                if let doc = querySnapshot?.documents.first {
                    let uid: String = doc.get("uid") as! String
                    db.collection("users").document(uid).setData(["groupID": groupDocID], merge: true)
                }
            })
        }
        
    }
    
    // has listeners, so will only need to pull group data from shared values
    static func setAndPersistGroupDataInSharedValues(db: Firestore) {
        let docRef = db.collection("users").document(Auth.auth().currentUser?.uid ?? " ")
        docRef.addSnapshotListener { (docSnapshot, error) in
            if let docSnapshot = docSnapshot {
                if let groupID = docSnapshot.get("groupID") as? String {
                    SharedValues.shared.groupID = groupID
                    if groupID != "" {
                        db.collection("groups").document(groupID).addSnapshotListener({ (snapshot, error) in
                            if let snapshot = snapshot {
                                SharedValues.shared.groupEmails = snapshot.get("emails") as? [String]
                                SharedValues.shared.groupDate = snapshot.get("dateCreated") as? TimeInterval
                            }
                        })
                    } else {
                        SharedValues.shared.groupEmails = nil
                        SharedValues.shared.groupDate = nil
                    }
                    
                } else {
                    SharedValues.shared.groupID = nil
                    SharedValues.shared.groupEmails = nil
                    SharedValues.shared.groupDate = nil
                }
                if let storageID = docSnapshot.get("storageID") as? String {
                    SharedValues.shared.foodStorageID = storageID
                } else {
                    SharedValues.shared.foodStorageID = nil
                }
            }
        }
        
        
    }
    static func getGroupInfo(db: Firestore!, dataReturned: @escaping (_ email: [String], _ date: String) -> Void) {
        var emails: [String] = []
        var date: String = ""
        db.collection("groups").document(SharedValues.shared.groupID ?? " ").getDocument { (documentSnapshot, error) in
            if let doc = documentSnapshot {
                date = (doc.get("dateCreated") as! TimeInterval).dateFormatted(style: .short)
                emails = doc.get("emails") as! [String]
            }
            dataReturned(emails, date)
        }
    }
    
    static func leaveGroupUser(db: Firestore, groupID: String) {
        let reference = db.collection("groups").document(groupID)
        var newEmails = SharedValues.shared.groupEmails
        let storageID = SharedValues.shared.foodStorageID
        
        newEmails = newEmails?.filter({$0 != Auth.auth().currentUser?.email ?? ""})
        reference.updateData([
            "emails": newEmails as Any
        ])
        db.collection("users").document(Auth.auth().currentUser?.uid ?? " ").updateData([
            "groupID": FieldValue.delete()
        ])
        db.collection("storages").document(storageID ?? " ").getDocument { (docSnapshot, error) in
            if let doc = docSnapshot {
                let isGroup = doc.get("isGroup") as? Bool
                if isGroup == true {
                    let previousEmails = doc.get("emails") as? [String]
                    let previousShared = doc.get("shared") as? [String]
                    
                    let newEmails = previousEmails?.filter({$0 != Auth.auth().currentUser?.email ?? ""})
                    let newShared = previousShared?.filter({$0 != Auth.auth().currentUser?.uid})
                    
                    print("Need to remove the information from the deleted user from the storage (email and uid)")
                    db.collection("storages").document(storageID ?? " ").updateData([
                        "emails": newEmails as Any,
                        "shared": newShared as Any
                    ])
                    db.collection("users").document(Auth.auth().currentUser?.uid ?? " ").updateData([
                        "storageID": FieldValue.delete()
                    ])
                }
            }
        }
    }
}
