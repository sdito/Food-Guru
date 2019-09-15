//
//  StorageHomeVC.swift
//  smartList
//
//  Created by Steven Dito on 9/5/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class StorageHomeVC: UIViewController {
    var db: Firestore!
    lazy private var emptyCells: [UITableViewCell] = []
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var items: [Item] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        db = Firestore.firestore()
        createObserver()
        
        
        Item.readItemsForStorage(db: db, docID: SharedValues.shared.foodStorageID ?? " ") { (itms) in
            self.items = itms
        }
        
    }
    override func viewDidAppear(_ animated: Bool) {
        emptyCells = createEmptyStorageCells()
        tableView.reloadData()
    }
    @IBAction func searchPressed(_ sender: Any) {
        tableView.reloadData()
    }
    
    
    @objc func createGroupSelector() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "createGroup") as! CreateGroupVC
        present(vc, animated: true, completion: nil)
        
    }
    @objc func createIndividualStorage() {
        print("create individual storage")
        let foodStorage = FoodStorage(isGroup: false, groupID: nil, peopleEmails: [Auth.auth().currentUser?.email ?? "no email"], items: nil, numberOfPeople: 1)
        FoodStorage.createStorageToFirestoreWithPeople(db: db, foodStorage: foodStorage)
        tableView.reloadData()
        
    }
    
    @objc func createGroupStorage() {
        print("create group storage")
        let foodStorage = FoodStorage(isGroup: true, groupID: SharedValues.shared.groupID, peopleEmails: SharedValues.shared.groupEmails ?? ["emails didnt work"], items: nil, numberOfPeople: SharedValues.shared.groupEmails?.count)
        FoodStorage.createStorageToFirestoreWithPeople(db: db, foodStorage: foodStorage)
        
        tableView.reloadData()
        
    }
    
    private func createObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(observerSelectorFoodStorageID), name: .foodStorageIDchanged, object: nil)
    }
    
    @objc func observerSelectorFoodStorageID() {
        tableView.reloadData()
    }
}


extension StorageHomeVC: UITableViewDataSource, UITableViewDelegate {
    func createEmptyStorageCells() -> [UITableViewCell] {
        var createGroup: Bool?
        let one = tableView.dequeueReusableCell(withIdentifier: "settingBasicCell") as! SettingBasicCell
        var oneText: String {
            if SharedValues.shared.groupID == nil {
                createGroup = true
                return " Create a group to share storage with other users, or start a storage with only yourself."
            } else {
                createGroup = false
                return ""
            }
        }
        one.setUI(str: "You do not yes have your storage set up. The storage will help you keep track of your purchased food, and can help you find recipes to cook.\(oneText)")
        
        let two = tableView.dequeueReusableCell(withIdentifier: "settingButtonCell") as! SettingButtonCell
        two.setUI(title: "Create a storage with group (recommended)")
        two.button.addTarget(self, action: #selector(createGroupStorage), for: .touchUpInside)
        let four = tableView.dequeueReusableCell(withIdentifier: "settingButtonCell") as! SettingButtonCell
        four.setUI(title: "Create your own storage without group")
        four.button.addTarget(self, action: #selector(createIndividualStorage), for: .touchUpInside)
        
        if createGroup == false {
            return [one, two, four]
        } else {
            let three = tableView.dequeueReusableCell(withIdentifier: "settingButtonCell") as! SettingButtonCell
            three.setUI(title: "Create a group")
            three.button.addTarget(self, action: #selector(createGroupSelector), for: .touchUpInside)
            
            
            return [one, three, four]
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if SharedValues.shared.foodStorageID != nil && items.isEmpty == false {
            tableView.backgroundColor = .white
            return nil
        } else {
            tableView.backgroundColor = .lightGray
            let v = UIView()
            v.backgroundColor = .lightGray
            return v
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if SharedValues.shared.foodStorageID != nil {
            if items.isEmpty == false {
                return items.count
            } else {
                return 1
            }
            
        } else {
            return emptyCells.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if SharedValues.shared.foodStorageID != nil {
            if items.isEmpty == false {
                let cell = tableView.dequeueReusableCell(withIdentifier: "storageCell") as! StorageCell
                let item = items[indexPath.row]
                cell.setUI(item: item)
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "settingBasicCell") as! SettingBasicCell
                cell.setUI(str: "Your storage is empty. To add and keep track of your items, select done after you are done using one of your lists or manually add the items.")
                return cell
            }
            
        } else {
            
            return emptyCells[indexPath.row]
        }
        
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if SharedValues.shared.foodStorageID != nil && items.isEmpty == false {
            tableView.backgroundColor = .white
            return UIView()
            
        } else {
            tableView.backgroundColor = .lightGray
            let v = UIView()
            v.backgroundColor = .lightGray
            return v
        }
    }
    
    
}
