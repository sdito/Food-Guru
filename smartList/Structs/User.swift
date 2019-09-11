//
//  User.swift
//  smartList
//
//  Created by Steven Dito on 8/17/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import Foundation
import FirebaseFirestore

struct User {
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
}
