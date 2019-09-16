//
//  AddItemsVC.swift
//  smartList
//
//  Created by Steven Dito on 8/8/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore


class AddItemsVC: UIViewController {
    private var storeText: String = "none"
    
    private var currentStore: String {
        if segmentedControl.numberOfSegments == 0 {
            return ""
        } else {
            return segmentedControl.titleForSegment(at: segmentedControl.selectedSegmentIndex) ?? ""
        }
        
    }
    
    private var arrayArrayItems: [[Item]] = []
    private var sortedCategories: [String] = []
    
    
    
    // check if this variable is being used for anything
    private var sendHome = true
    
    var db: Firestore!
    
    var list: List? {
        didSet {
            if list?.items?.isEmpty == false {
                //print(storeText)
                (sortedCategories, arrayArrayItems) = (list?.sortForTableView(from: currentStore))! as! ([String], [[Item]])
                tableView.reloadData()
            }
        }
    }
    @IBOutlet weak var topView: UIView!
    
    @IBOutlet weak var storesView: UIView!
    @IBOutlet weak var categoriesView: UIView!
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillAppear(animated)
        topView.setGradientBackground(colorOne: Colors.main, colorTwo: Colors.mainGradient)
        tableView.delegate = self
        tableView.dataSource = self
        textField.delegate = self
//        if list?.stores?.isEmpty == false {
//            storeText = segmentedControl.titleForSegment(at: segmentedControl.selectedSegmentIndex)!
//        }
        setUIfrom(list: list!)
        
        view.setGradientBackground(colorOne: .lightGray, colorTwo: .gray)
        Item.readItemsForList(db: db, docID: SharedValues.shared.listIdentifier!.documentID) { (itm) in
            self.list?.items = itm
            
        }
        if let first = stackView.subviews.last as! UIButton? {
            SharedValues.shared.currentCategory = first.titleLabel?.text ?? "none"
        }
        
        //sendHome = true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillDisappear(animated)
        SharedValues.shared.listIdentifier?.updateData([
            "numItems": list?.items?.count as Any
        ])
        if sendHome == true {
            navigationController?.popToRootViewController(animated: true)
        }
        
    }

    
    @IBAction func addItem(_ sender: Any) {
        if textField.text != "" {toAddItem()}
    }
    
    @IBAction func segmentedControlPressed(_ sender: Any) {
        (sortedCategories, arrayArrayItems) = (list?.sortForTableView(from: currentStore))! as! ([String], [[Item]])
        tableView.reloadData()
    }
    
    private func setUIfrom(list: List) {
        //segmented control set up
        segmentedControl.removeAllSegments()
        
        list.stores?.forEach({ (store) in
            segmentedControl.insertSegment(withTitle: store, at: 0, animated: false)
        })
        
        segmentedControl.selectedSegmentIndex = 0
        
        //buttons set up
        stackView.subviews.forEach({$0.removeFromSuperview()})
        list.categories?.forEach({ (category) in
            let button = UIButton()
            button.createCategoryButton(with: category)
            stackView.insertArrangedSubview(button, at: 0)
        })
        if list.categories?.isEmpty == true {
            scrollView.isHidden = true
            
        }
        if list.stores?.isEmpty == true {
            segmentedControl.isHidden = true
        }
    }
    @IBAction func editList(_ sender: Any) {
        sendHome = false
        let vc = storyboard?.instantiateViewController(withIdentifier: "setUpList") as! SetUpListVC
        if list?.docID == nil {
            list?.docID = SharedValues.shared.listIdentifier?.documentID
        }
        vc.listToEdit = list
        
        self.present(vc, animated: true, completion: nil)
        
    }
    @IBAction func deleteList(_ sender: Any) {
        let alert = UIAlertController(title: "Delete list", message: "Are you sure you want to delete this list? This action can't be undone.", preferredStyle: .alert)
    
        alert.addAction(.init(title: "Delete", style: .destructive, handler: {action in
            self.list?.deleteListToFirestore(db: self.db)
            self.navigationController?.popToRootViewController(animated: true)
        }))
        
        alert.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
    }
    
    @IBAction func doneWithList(_ sender: Any) {
        
        
        
        if SharedValues.shared.foodStorageID != nil {
            var gottenEmails: [String]?
            FoodStorage.getEmailsfromStorageID(storageID: SharedValues.shared.foodStorageID ?? " ", db: db) { (emails) in
                gottenEmails = emails
            }
            let alert = UIAlertController(title: "Are you done with the list?", message: "The selected items from this list will be added to your storage, where you can keep track of your items.", preferredStyle: .actionSheet)
            alert.addAction(.init(title: "Add items to storage", style: .default, handler: {(alert: UIAlertAction!) in self.addItemsToStorageIfPossible(sendList: self.list!, foodStorageEmails: gottenEmails)}))
            alert.addAction(.init(title: "Back", style: .default, handler: nil))
            present(alert, animated: true)
        } else {
            let userFS = FoodStorage(isGroup: false, groupID: nil, peopleEmails: [Auth.auth().currentUser?.email ?? ""], items: nil, numberOfPeople: 1)
            if SharedValues.shared.groupID == nil {
                let alert = UIAlertController(title: "Error - can't add items to storage", message: "In order to have a shared storage where multiple people can view the items, first create a group.", preferredStyle: .actionSheet)
                alert.addAction(.init(title: "Create group", style: .default, handler: {(alert: UIAlertAction!) in self.pushToCreateGroupVC()}))
                alert.addAction(.init(title: "Create own storage without group", style: .default, handler: {(alert: UIAlertAction!) in FoodStorage.createStorageToFirestoreWithPeople(db: self.db, foodStorage: userFS)}))
                alert.addAction(.init(title: "Back", style: .default, handler: nil))
                present(alert, animated: true)
            } else {
                let groupFS = FoodStorage(isGroup: true, groupID: SharedValues.shared.groupID, peopleEmails: SharedValues.shared.groupEmails, items: nil, numberOfPeople: SharedValues.shared.groupEmails?.count)
                let alert = UIAlertController(title: "Error - can't add items to storage", message: "Create a storage to be able to view the current food items you have in stock.", preferredStyle: .actionSheet)
                alert.addAction(.init(title: "Create storage with group (recommended)", style: .default, handler: {(alert: UIAlertAction!) in FoodStorage.createStorageToFirestoreWithPeople(db: self.db, foodStorage: groupFS)}))
                alert.addAction(.init(title: "Create own storage without group", style: .default, handler: {(alert: UIAlertAction!) in FoodStorage.createStorageToFirestoreWithPeople(db: self.db, foodStorage: userFS)}))
                alert.addAction(.init(title: "Back", style: .default, handler: nil))
                present(alert, animated: true)
                
                
            }
            
        }
        
        
    }
    
    
    private func toAddItem() {
        
        var item = Item(name: textField.text!, selected: false, category: SharedValues.shared.currentCategory, store: currentStore, user: nil, ownID: nil, storageSection: nil, timeAdded: nil, timeExpires: nil)
        item.writeToFirestore(db: db)
        //NEED TO HAVE THE OWNID FOR THE ITEM IN ORDER TO WRITE TO DB IN THE FUTURE ABOUT ITEM EVENTS
        
        //print("\(item.ownID) is the item id")
        if list?.items?.isEmpty == false {
            list?.items!.append(item)
        } else {
            list?.items = [item]
        }
        
        textField.text = ""
    }
}

// have the cells organized by
extension AddItemsVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sortedCategories.count
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let l = UILabel()
        l.text = sortedCategories[section]
        l.font = UIFont(name: "futura", size: 15)
        l.textColor = .white
        l.backgroundColor = .lightGray
        l.alpha = 0.9
        l.textAlignment = .center
        return l
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayArrayItems[section].count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //guard let item = list?.items?[indexPath.row] else { return UITableViewCell() }
        let item = arrayArrayItems[indexPath.section][indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell") as! ItemCell
        cell.setUI(item: item)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print(list?.items.map({$0.map({$0.name})}))
        
        arrayArrayItems[indexPath.section][indexPath.row].selected = !arrayArrayItems[indexPath.section][indexPath.row].selected
        arrayArrayItems[indexPath.section][indexPath.row].selectedItem(db: db)
        tableView.reloadData()
    }
}

extension AddItemsVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        toAddItem()
        return true
    }
}




// handlers
extension AddItemsVC {
    func pushToCreateGroupVC() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "createGroup") as! CreateGroupVC
        present(vc, animated: true, completion: nil)
    }
    func addItemsToStorageIfPossible(sendList: List, foodStorageEmails: [String]?) {
        
        var isEqual: Bool = false
        var difference: [String]?
        (isEqual, difference) = User.comparePeopleIn(list: sendList, foodStorageEmails: foodStorageEmails)
        
        if isEqual == true {
            
            if list != nil && list?.items?.isEmpty == false {
                if let id = SharedValues.shared.foodStorageID {
                    
                    
                    //successfully gotten to this point
                    FoodStorage.addItemsFromListintoFoodStorage(sendList: list!, storageID: id, db: db)
                    
                    // to set all the items in the list to not selected
                    for index in (list?.items!.indices)! {
                        list?.items?[index].selected = false
                    }
                }
            } else {
                let alert = UIAlertController(title: "Error - there are no items in your list", message: nil, preferredStyle: .alert)
                alert.addAction(.init(title: "Ok", style: .default, handler: nil))
                present(alert, animated: true)
            }
        } else {
            let alert = UIAlertController(title: "Error - users in your list do not match the users in your storage", message: "Emails not in both your list and storage are: \(difference?.joined(separator: ", ") ?? ""), unable to add to your storage", preferredStyle: .alert)
            alert.addAction(.init(title: "Ok", style: .default, handler: nil))
            present(alert, animated: true)
        }
    }
}
