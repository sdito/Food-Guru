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
    
    /*
    struct Group {
        var groupID: String?
        var date: TimeInterval?
        var emails: [String]?
        
        init(groupID: String?, date: TimeInterval?, emails: [String]?) {
            self.groupID = groupID
            self.date = date
            self.emails = emails
        }
    }
    */
    
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
        
        
        
        
        
        
        
        
        
        
        
        
        //NEED TO CHECK EACH USER AGAIN BEFORE FINALLY WRITING, THEY COULD BE ADDED INTO A GROUP AT THE SAME TIME FROM TWO DIFFERENT DEVICES, OR WRITE A PLACEHOLDER GROUPID VALUE IN THEIR FILE
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        // write the group to firestore first
        let groupRef = db.collection("groups").document()
        let groupDocID = groupRef.documentID
        groupRef.setData([
            "dateCreated": Date().timeIntervalSince1970,
            "ownID": groupDocID,
            "emails": emails
        ])
        
        
        
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
        let docRef = db.collection("users").document(Auth.auth().currentUser?.uid ?? "")
        docRef.addSnapshotListener { (docSnapshot, error) in
            if let docSnapshot = docSnapshot {
                if let groupID = docSnapshot.get("groupID") as? String {
                    SharedValues.shared.groupID = groupID
                    db.collection("groups").document(groupID).addSnapshotListener({ (snapshot, error) in
                        if let snapshot = snapshot {
                            SharedValues.shared.groupEmails = snapshot.get("emails") as? [String]
                            SharedValues.shared.groupDate = snapshot.get("dateCreated") as? TimeInterval
                        }
                    })
                }
            }
        }
        
        
    }
    static func getGroupInfo(db: Firestore!, dataReturned: @escaping (_ email: [String], _ date: String) -> Void) {
        var emails: [String] = []
        var date: String = ""
        db.collection("groups").document(SharedValues.shared.groupID ?? "").getDocument { (documentSnapshot, error) in
            if let doc = documentSnapshot {
                date = (doc.get("dateCreated") as! TimeInterval).dateFormatted(style: .short)
                emails = doc.get("emails") as! [String]
            }
            dataReturned(emails, date)
        }
    }
}
