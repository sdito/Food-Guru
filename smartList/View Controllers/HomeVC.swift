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
    
    private var items: [Item] = []
    private var lists: [List]? {
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
        
        List.readAllUserLists(db: db, userID: SharedValues.shared.userID!) { (dbLists) in
            self.lists = dbLists
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillDisappear(animated)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "listSelected" {
            let destVC = segue.destination as! AddItemsVC
            destVC.list = sender as? List
        }
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
        let l = lists![indexPath.row]
//        Item.readItems(db: db, docID: l.docID!) { (itm) in
//            self.items = itm
//        }
        SharedValues.shared.listIdentifier = self.db.collection("lists").document("\(l.docID!)")
        self.performSegue(withIdentifier: "listSelected", sender: l)
    }
}
