//
//  HomeVC.swift
//  smartList
//
//  Created by Steven Dito on 8/3/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import UIKit
import FirebaseFirestore

class HomeVC: UIViewController {
    var db: Firestore!
//    var listsForTesting: [List] = [
//        List(name: "List 1", stores: ["Trader Joe's", "Whole Foods"], categories: ["Sweets", "Baking", "Fruit"], people: ["Steven"], items: nil),
//        List(name: "Sunday List", stores: ["Target", "Safeway", "Trader Joe's"], categories: ["Dairy", "Veggies", "Grains", "Fruit", "Other"], people: ["Nicole", "Steven", "Anthony"], items: nil),
//        List(name: "Steven's List", stores: [ "Safeway", "Trader Joe's"], categories: ["Dairy", "Veggies", "Grains", "Fruit", "Other"], people: ["Nicole", "Steven", "Anthony"], items: nil),
//        List(name: "Other List", stores: ["Target", "Safeway", "Trader Joe's"], categories: ["Dairy", "Veggies", "Grains", "Fruit", "Other"], people: ["Nicole", "Steven", "Anthony"], items: nil),
//        List(name: "Last List", stores: ["Target", "Safeway", "Trader Joe's"], categories: ["Dairy", "Veggies", "Grains", "Fruit"], people: ["Nicole", "Anthony"], items: nil)
//    ]
    var lists: [List]? {
        didSet {
            collectionView.reloadData()
        }
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        db = Firestore.firestore()
        
        lists = List.readAllUserLists(db: db, userID: SharedValues.shared.userID!)
//        db.collection("lists").whereField("user", isEqualTo: SharedValues.shared.userID!).addSnapshotListener { (querySnapshot, error) in
//            guard let documents = querySnapshot?.documents else {
//                print("Error fetching documents: \(error!)")
//                return
//            }
//            
//            self.lists?.removeAll()
//            for doc in documents {
//                let t = List(name: doc.get("name") as! String, stores: (doc.get("stores") as! [String]), categories: (doc.get("categories") as! [String]), people: (doc.get("people") as! [String]), items: nil, numItems: nil, docID: doc.documentID)
//                if self.lists != nil {
//                    self.lists!.append(t)
//                } else {
//                    self.lists = [t]
//                }
//                
//            }
////            let listsSnapshot = documents.map{$0["name"]!}
////            print(listsSnapshot)
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillDisappear(animated)
    }

}



extension HomeVC: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let n = lists?.count {
            return n
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = lists![indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "listCell", for: indexPath) as! ListCell
        cell.setUI(list: item)
        return cell
    }
    
    
    // CONTINUE HERE, HAVE THE CORRECT LIST BEING ABLE TO BE SELECTED, GO INTO THE EDIT LIST SCREEN
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let docID = lists![indexPath.row].docID
        let items = Item.readItems(db: db, docID: docID ?? "")
//        db.collection("lists").document(docID!).collection("items").addSnapshotListener { (querySnapshot, error) in
//            guard let documents = querySnapshot?.documents else {
//                print("Error fetching documents: \(String(describing: error))")
//                return
//            }
//            var listItems: [Item] = []
//            for doc in documents {
//                let i = Item(name: doc.get("name") as! String, category: (doc.get("category") as! String), store: (doc.get("store") as! String), user: (doc.get("user") as! String))
//                if listItems.isEmpty == false {
//                    listItems.append(i)
//                } else {
//                    listItems = [i]
//                }
//            }
//            print(listItems.map({$0.name}))
//        }
    }
}
