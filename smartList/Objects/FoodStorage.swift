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




protocol FoodStorageDelegate: class {
    func itemsUpdated()
}



class FoodStorage {
    
    var isGroup: Bool?
    var groupID: String?
    var peopleEmails: [String]?
    var items: [Item]? = []
    var numberOfPeople: Int?
    var itemListener: ListenerRegistration?
    
    weak var delegate: FoodStorageDelegate!
    
    init(isGroup: Bool?, groupID: String?, peopleEmails: [String]?, items: [Item]?, numberOfPeople: Int?) {
        self.isGroup = isGroup
        self.groupID = groupID
        self.peopleEmails = peopleEmails
        self.items = items
        self.numberOfPeople = numberOfPeople
    }
    
    // MARK: General
    
    /*
    Used to create a storage for both an individual storage and one with the group, the FoodStorage that is passed through will contain the emails already in the value, so will just need to use
    those emails. Need to update/write both the storage document and information in each user's own profile
    */
    static func createStorageToFirestoreWithPeople(db: Firestore!, foodStorage: FoodStorage) {
        // need to check that no users already have a storage, need to write the storage to the individuals in people, create the storage
        checkForUsersAlreadyInStorage(db: db, groupID: SharedValues.shared.groupID ?? " ") { (boolean, inStorageEmails) in
            if boolean == true || foodStorage.isGroup == false {
                // need to if somone has their own storage already in the group
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
    
    static func deleteStorage(db: Firestore, storageID: String) {
       // need to delete the storage and also the foodStorageID from user's document, if not deleted from user's document then theyll have a permanently broken storage
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
    
    // MARK: Items
    
    func readItemsForStorage(db: Firestore!, storageID: String) {
        self.items = []
        
        itemListener = db.collection("storages").document(storageID).collection("items").addSnapshotListener { (querySnapshot, error) in
            guard let documents = querySnapshot?.documentChanges else {
                print("Error fetching documents: \(String(describing: error))")
                return
            }
            for d in documents {
                let doc = d.document
                switch d.type {
                case .added, .modified:
                    let systemItem = GenericItem(rawValue: doc.get("systemItem") as? String ?? "other")
                    let systemCategory = Category(rawValue: doc.get("systemCategory") as? String ?? "other")
                    let i = Item(name: doc.get("name") as! String, selected: doc.get("selected")! as! Bool, category: (doc.get("category") as! String), store: (doc.get("store") as! String), user: (doc.get("user") as? String), ownID: doc.documentID, storageSection: FoodStorageType.stringToFoodStorageType(string: (doc.get("storageSection") as? String ?? " ")), timeAdded: doc.get("timeAdded") as? TimeInterval, timeExpires: doc.get("timeExpires") as? TimeInterval, systemItem: systemItem, systemCategory: systemCategory, quantity: doc.get("quantity") as? String)
                    
                    if d.type == .modified {
                        self.items?.removeAll(where: {$0.ownID == i.ownID})
                    }
                    
                    self.items?.append(i)
                    
                case .removed:
                    self.items = self.items?.filter({$0.ownID != doc.documentID})
                }
            }
            self.delegate.itemsUpdated()
        }
    }
    
    
    static func addItemsFromListintoFoodStorage(sendList: GroceryList, storageID: String, db: Firestore) {
        for item in sendList.items ?? [] {
            if item.selected == true {
                var newItemWithStorage = item
                let words = item.name.split{ !$0.isLetter }.map { (sStr) -> String in
                    String(sStr.lowercased())
                }
                let storageSection = GenericItem.getStorageType(item: newItemWithStorage.systemItem ?? .other, words: words)
                
                newItemWithStorage.storageSection = storageSection
                
                if let genericItem = newItemWithStorage.systemItem {
                    newItemWithStorage.timeExpires = Date().timeIntervalSince1970 + Double(GenericItem.getSuggestedExpirationDate(item: genericItem, storageType: newItemWithStorage.storageSection ?? .unsorted))
                }
                
                newItemWithStorage.writeToFirestoreForStorage(db: db, docID: storageID)
            }
        }
    }
    
    // used to have real-time updates for the items that are in the user's storage, either individual or shared storage
    
    
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
    
        /*
        used (from settings) for combining multiple individual storages into a group storage, this will edit each individual's profile if necessary throghh addForStorageInformationToGroupMembersProfile
        this will also update the storage information
    
       */
       static func mergeItemsTogetherInStorage(db: Firestore, newStorageID: String, newEmails: [String]) {
           
           for email in newEmails {
               User.turnEmailToUid(db: db, email: email) { (uid) in
                   // get storageID
                   if let uid = uid {
                       let reference = db.collection("users").document(uid)
                       reference.getDocument { (documentSnapshot, error) in
                           guard let doc = documentSnapshot else { return }
                           
                           if let sid = doc.get("storageID") as? String {
                               if sid != newStorageID {
                                   let storageRef = db.collection("storages").document(sid).collection("items")
                                   storageRef.getDocuments { (querySnapshot, error) in
                                       // storageID is the NEW storage identifier that everything needs to be merged into
                                       guard let itemDocuments = querySnapshot?.documents else {
                                           FoodStorage.addForStorageInformationToGroupMembersProfile(db: db, foodStorageID: newStorageID, email: email)
                                           return
                                       }
                                       for itemDoc in itemDocuments {
                                           let item = itemDoc.getItem()
                                           // if this process doesnt work, maybe these storage IDs are wrong
                                           print("item being moved: \(item)")
                                           item.writeToFirestoreForStorage(db: db, docID: newStorageID)
                                           item.deleteItemFromStorageFromSpecificStorageID(db: db, storageID: sid)
                                           
                                       }
                                       FoodStorage.addForStorageInformationToGroupMembersProfile(db: db, foodStorageID: newStorageID, email: email)
                                   }
                               }
                           } else {
                               FoodStorage.addForStorageInformationToGroupMembersProfile(db: db, foodStorageID: newStorageID, email: email)
                           }
                           
                           
                       }
                   }
               }
           }
       }
    
    static func addAllItemsFromListintoFoodStorage(sendList: GroceryList, storageID: String, db: Firestore) {
        for item in sendList.items ?? [] {
            var newItemWithStorage = item
            let words = item.name.split{ !$0.isLetter }.map { (sStr) -> String in
                String(sStr.lowercased())
            }
            let storageSection = GenericItem.getStorageType(item: newItemWithStorage.systemItem ?? .other, words: words)
            
            newItemWithStorage.storageSection = storageSection
            
            if let genericItem = newItemWithStorage.systemItem {
                newItemWithStorage.timeExpires = Date().timeIntervalSince1970 + Double(GenericItem.getSuggestedExpirationDate(item: genericItem, storageType: newItemWithStorage.storageSection ?? .unsorted))
            }
            
            newItemWithStorage.writeToFirestoreForStorage(db: db, docID: storageID)
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
    
    // MARK: Users
    
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
    
    // called from mergeItemsTogetherInStorage only
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
    
    
}
