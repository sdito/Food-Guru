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
//    var email: String
//    var uid: String
//    var nickname: String
//
//    init(email: String, uid: String, nickname: String) {
//        self.email = email
//        self.uid = uid
//        self.nickname = nickname
//    }
    
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
}
