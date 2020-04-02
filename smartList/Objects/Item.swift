//
//  Item.swift
//  smartList
//
//  Created by Steven Dito on 8/6/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

import UIKit
import Firebase

struct Item: Equatable {
    var name: String
    var selected: Bool
    var category: String?
    var store: String?
    var user: String?
    var ownID: String?
    var storageSection: FoodStorageType?
    var timeAdded: TimeInterval?
    var timeExpires: TimeInterval?
    var systemItem: GenericItem?
    var systemCategory: Category?
    var quantity: String?
    
    init(name: String, selected: Bool, category: String?, store: String?, user: String?, ownID: String?, storageSection: FoodStorageType?, timeAdded: TimeInterval?, timeExpires: TimeInterval?, systemItem: GenericItem?, systemCategory: Category?, quantity: String?) {
        self.name = name
        self.selected = selected
        self.category = category
        self.store = store
        self.user = user
        self.ownID = ownID
        self.storageSection = storageSection
        self.timeAdded = timeAdded
        self.timeExpires = timeExpires
        self.systemItem = systemItem
        self.systemCategory = systemCategory
        self.quantity = quantity
    }
    // MARK: Lists
    
    //correctly reads the ownID of the document of items
    
    
    static func updateItemForListQuantity(quantity: String, itemID: String, listID: String, db: Firestore) {
        let reference = db.collection("lists").document(listID).collection("items").document(itemID)
        reference.updateData([
            "quantity": quantity
        ])
    }
    static func updateItemForListName(name: String, itemID: String, listID: String, db: Firestore) {
        let reference = db.collection("lists").document(listID).collection("items").document(itemID)
        reference.updateData([
            "name": name
        ])
    }
    static func updateItemForListStore(store: String, itemID: String, listID: String, db: Firestore) {
        let reference = db.collection("lists").document(listID).collection("items").document(itemID)
        reference.updateData([
            "store": store
        ])
    }
    static func updateItemForListCategory(category: String, itemID: String, listID: String, db: Firestore) {
        let reference = db.collection("lists").document(listID).collection("items").document(itemID)
        reference.updateData([
            "category": category
        ])
    }
    
    mutating func writeToFirestoreForList(db: Firestore!) {
        let itemRef = db.collection("lists").document("\(SharedValues.shared.listIdentifier!.documentID)").collection("items").document()
        self.ownID = itemRef.documentID
        itemRef.setData([
            "name": self.name,
            "category": self.category!,
            "store": self.store!,
            "user": Auth.auth().currentUser?.displayName as Any,
            "selected": self.selected,
            "systemItem": "\(self.systemItem ?? .other)",
            "systemCategory": "\(self.systemCategory ?? .other)",
            "quantity": self.quantity as Any
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written")
            }
        }
    }
    
    func deleteItemFromList(db: Firestore, listID: String) {
        let documentRef = db.collection("lists").document(listID).collection("items").document(self.ownID ?? " ")
        documentRef.delete()
    }
    
    
    
    // MARK: Storage
    
    func writeToFirestoreForStorage(db: Firestore!, docID: String) {
       let reference = db.collection("storages").document(docID).collection("items").document()
        reference.setData([
            "name": self.name,
            "selected": false,
            "category": self.category!,
            "store": self.store as Any,
            "user": Auth.auth().currentUser?.displayName as Any,
            "ownID": reference.documentID,
            "storageSection": self.storageSection?.string ?? FoodStorageType.unsorted.string,
            "timeAdded": Date().timeIntervalSince1970,
            "timeExpires": self.timeExpires as Any,
            "systemItem": "\(self.systemItem ?? .other)",
            "systemCategory": "\(self.systemCategory ?? .other)",
            "quantity": self.quantity as Any
        ])
    }
    
    
    
    
    static func readItemsForStorageNoListener(db: Firestore, storageID: String, itemsReturned: @escaping (_ items: [Item]) -> Void) {
        var storageItems: [Item] = []
        db.collection("storages").document(storageID).collection("items").getDocuments { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(String(describing: error))")
                return
            }
            
            for doc in documents {
              let systemItem = GenericItem(rawValue: doc.get("systemItem") as? String ?? "other")
                let systemCategory = Category(rawValue: doc.get("systemCategory") as? String ?? "other")
                let i = Item(name: doc.get("name") as! String, selected: doc.get("selected")! as! Bool, category: (doc.get("category") as! String), store: (doc.get("store") as! String), user: (doc.get("user") as? String), ownID: doc.documentID, storageSection: FoodStorageType.stringToFoodStorageType(string: (doc.get("storageSection") as? String ?? " ")), timeAdded: doc.get("timeAdded") as? TimeInterval, timeExpires: doc.get("timeExpires") as? TimeInterval, systemItem: systemItem, systemCategory: systemCategory, quantity: doc.get("quantity") as? String)
                if storageItems.isEmpty == false {
                    storageItems.append(i)
                } else {
                    storageItems = [i]
                }
            }
            itemsReturned(storageItems)
        }
    }
    
    static func updateItemForStorageName(name: String, itemID: String, storageID: String, db: Firestore) {
        let reference = db.collection("storages").document(storageID).collection("items").document(itemID)
        reference.updateData([
            "name": name
        ])
    }
    static func updateItemForStorageQuantity(quantity: String, itemID: String, storageID: String, db: Firestore) {
        let reference = db.collection("storages").document(storageID).collection("items").document(itemID)
        reference.updateData([
            "quantity": quantity
        ])
    }
    
    func switchItemToSegment(named: String, db: Firestore/*, storageID: String*/) {
        let documentRef = db.collection("storages").document(SharedValues.shared.foodStorageID ?? " ").collection("items").document(self.ownID ?? " ")
        documentRef.updateData([
            "storageSection": named
        ])
    }
    func addExpirationDateToItem(db: Firestore, timeIntervalSince1970: TimeInterval) {
        let documentRef = db.collection("storages").document(SharedValues.shared.foodStorageID ?? " ").collection("items").document(self.ownID ?? " ")
        documentRef.updateData([
            "timeExpires": timeIntervalSince1970
        ])
    }
    
    
    
    func deleteItemFromStorage(db: Firestore, storageID: String) {
        print(storageID)
        let documentRef = db.collection("storages").document(SharedValues.shared.foodStorageID ?? " ").collection("items").document(self.ownID ?? " ")
        documentRef.delete()
    }
    
    func deleteItemFromStorageFromSpecificStorageID(db: Firestore, storageID: String) {
        let documentRef = db.collection("storages").document(storageID).collection("items").document(self.ownID ?? " ")
        documentRef.delete()
    }
    
    
    // MARK: General
    
    static func createItemFrom(text: String) -> Item {
        let systemItem = Search.turnIntoSystemItem(string: text)
        let words = text.split{ !$0.isLetter }.map { (sStr) -> String in
            String(sStr.lowercased())
        }
        let systemCategory = GenericItem.getCategory(item: systemItem, words: words)
        let item = Item(name: text, selected: false, category: systemCategory.rawValue, store: nil, user: Auth.auth().currentUser?.displayName, ownID: nil, storageSection: nil, timeAdded: nil, timeExpires: nil, systemItem: systemItem, systemCategory: systemCategory, quantity: nil)
        return item
    }
    
    func selectedItem(db: Firestore) { db.collection("lists").document("\(SharedValues.shared.listIdentifier!.documentID)").collection("items").document(self.ownID!).updateData([
            "selected": self.selected
        ])
    }
    
    
    func findIndexPathIn(_ items: [[Item]]) -> IndexPath? {
        for (a, array) in items.enumerated() {
            for (b, item) in array.enumerated() {
                if item == self {
                    return IndexPath(row: b, section: a)
                }
            }
        }
        return nil
    }
    
    
    // MARK: Open Food Facts API
    static func getItemFromBarcode(image: UIImage, vc: UIViewController, picker: UIImagePickerController, db: Firestore) {
        let format = VisionBarcodeFormat.all
        let barcodeOptions = VisionBarcodeDetectorOptions(formats: format)
        let vision = Vision.vision()
        let barcodeDetector = vision.barcodeDetector(options: barcodeOptions)
        let visionImage = VisionImage(image: image)
        
        let imageMetadata = VisionImageMetadata()
        imageMetadata.orientation = .topLeft
        visionImage.metadata = imageMetadata
        
        barcodeDetector.detect(in: visionImage) { (visionBarcode, error) in
            guard let barcodeData = visionBarcode else {
                vc.createMessageView(color: .red, text: "Unable to read barcode")
                picker.dismiss(animated: true, completion: nil)
                return
            }
        
            picker.dismiss(animated: true, completion: nil)
            guard let barcode = barcodeData.first?.displayValue else {
                vc.createMessageView(color: .red, text: "Barcode not found")
                return
            }
            
            
            guard let url = URL(string: "https://world.openfoodfacts.org/api/v0/product/\(barcode).json") else { return }
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                DispatchQueue.main.async {
                    guard let data = data else {
                        print("Data was nil")
                        return
                    }
                    
                    
                    let json = try? JSONSerialization.jsonObject(with: data, options: [])
                    if let dictionary = json as? [String:Any] {
                        if let nestedDict = dictionary["product"] as? [String:Any] {
                            if let name = nestedDict["product_name_en"] as? String {
                                vc.createMessageView(color: Colors.messageGreen, text: "Added: \(name)")
                                var item = Item.createItemFrom(text: name)
                                let words = name.split{ !$0.isLetter }.map { (sStr) -> String in
                                    String(sStr.lowercased())
                                }
                                
                                
                                if let genericItem = item.systemItem {
                                    if genericItem != .other {
                                        item.storageSection = GenericItem.getStorageType(item: genericItem, words: words)
                                        item.timeExpires = Date().timeIntervalSince1970 + Double(GenericItem.getSuggestedExpirationDate(item: genericItem, storageType: item.storageSection ?? .unsorted))
                                    }
                                }
                                
                                item.store = ""
                                item.writeToFirestoreForStorage(db: db, docID: SharedValues.shared.foodStorageID ?? " ")
                            } else {
                                vc.createMessageView(color: .red, text: "Item not found")
                            }
                            
                        } else {
                            vc.createMessageView(color: .red, text: "Barcode '\(barcode)' not found")
                        }
                    } else {
                        vc.createMessageView(color: .red, text: "Item not found")
                    }
                    
                    
                }
            }
            task.resume()
        }
    }
    
    
    
    
    
    
    
    
}


// MARK: Sequence
extension Sequence where Element == Item {
    func sortItemsForTableView(segment: FoodStorageType, searchText: String) -> [Item] {
        var returnSorted = self.filter({$0.storageSection == segment})
        returnSorted.sort { (i1, i2) -> Bool in
            i1.timeExpires ?? 0 < i2.timeExpires ?? 0
        }
        if searchText != "" {
            returnSorted = returnSorted.filter({ (itm) -> Bool in
                //itm.name.lowercased().starts(with: searchText.lowercased())
                itm.name.lowercased().contains(searchText.lowercased())
            })
        }
        return returnSorted
    }
}


// MARK: QueryDocumentSnapshot
extension QueryDocumentSnapshot {
    func getItem() -> Item {
        let systemItem = GenericItem(rawValue: self.get("systemItem") as? String ?? "other")
        let systemCategory = Category(rawValue: self.get("systemCategory") as? String ?? "other")
        let i = Item(name: self.get("name") as! String, selected: self.get("selected")! as! Bool, category: (self.get("category") as! String), store: (self.get("store") as! String), user: (self.get("user") as? String), ownID: self.documentID, storageSection: FoodStorageType.stringToFoodStorageType(string: (self.get("storageSection") as? String ?? " ")), timeAdded: self.get("timeAdded") as? TimeInterval, timeExpires: self.get("timeExpires") as? TimeInterval, systemItem: systemItem, systemCategory: systemCategory, quantity: self.get("quantity") as? String)
        return i
    }
}
