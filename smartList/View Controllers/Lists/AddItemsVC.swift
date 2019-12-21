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
    private var arrayArrayItems: [[Item]] = []
    private var sortedCategories: [String] = []
    private var delegate: SearchAssistantDelegate!
    private var storeText: String = "none"
    private var textAssistantViewActive = false
    private var keyboardHeight: CGFloat?
    private var currentStore: String {
        if segmentedControl.numberOfSegments == 0 {
            return ""
        } else {
            return segmentedControl.titleForSegment(at: segmentedControl.selectedSegmentIndex) ?? ""
        }
        
    }
    
    
    var db: Firestore!
    var list: GroceryList? {
        didSet {
            if list?.items?.isEmpty == false {
                //print(storeText)
                (sortedCategories, arrayArrayItems) = (list?.sortForTableView(from: currentStore))!
                tableView.reloadData()
            }
        }
    }
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var storesView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillAppear(animated)
        topView.setGradientBackground(colorOne: Colors.main, colorTwo: Colors.mainGradient)
        tableView.delegate = self
        tableView.dataSource = self
        textField.delegate = self
        
        setUIfrom(list: list!)
        
        view.setGradientBackground(colorOne: .lightGray, colorTwo: .gray)
        GroceryList.listenerOnListWithDocID(db: db, docID: SharedValues.shared.listIdentifier!.documentID) { (lst) in
            //self.list = lst
            self.list?.name = lst?.name ?? "No name"
            self.list?.people = lst?.people
            self.list?.stores = lst?.stores
            
            let listForChanging = self.list
            self.list?.items = listForChanging?.removeItemsThatNoLongerBelong()
            
            self.setUIfrom(list: self.list!)
        }
        Item.readItemsForList(db: db, docID: SharedValues.shared.listIdentifier!.documentID) { (itm) in
            self.list?.items = itm
            
        }
        
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        textField.setUpDoneToolbar(action: #selector(dismissKeyboardPressed), style: .cancel)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            keyboardHeight = keyboardRectangle.height
            print("KeyboardHeight is \(keyboardHeight)")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillDisappear(animated)
        SharedValues.shared.listIdentifier?.updateData([
            "numItems": list?.items?.count as Any
        ])
        
    }

    
    @IBAction func addItem(_ sender: Any) {
        if textField.text != "" {
            toAddItem(text: textField.text!)
            delegate.searchTextChanged(text: "")
        }
    }
    
    @IBAction func segmentedControlPressed(_ sender: Any) {
        (sortedCategories, arrayArrayItems) = (list?.sortForTableView(from: currentStore))!
        tableView.reloadData()
    }
    
    private func setUIfrom(list: GroceryList) {
        //segmented control set up
        segmentedControl.removeAllSegments()
        
        list.stores?.forEach({ (store) in
            segmentedControl.insertSegment(withTitle: store, at: 0, animated: false)
        })
        
        segmentedControl.selectedSegmentIndex = 0
        if list.stores?.isEmpty == true {
            segmentedControl.isHidden = true
        } else {
            segmentedControl.isHidden = false
        }
    }
    @IBAction func editList(_ sender: Any) {
        //sendHome = false
        let vc = storyboard?.instantiateViewController(withIdentifier: "setUpList") as! SetUpListVC
        if list?.docID == nil {
            list?.docID = SharedValues.shared.listIdentifier?.documentID
        }
        vc.listToEdit = list
        vc.modalPresentationStyle = .fullScreen
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
            let userFS = FoodStorage(isGroup: false, groupID: nil, peopleEmails: [Auth.auth().currentUser?.email ?? "no email"], items: nil, numberOfPeople: 1)
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
    
    
    private func toAddItem(text: String) {
        let words = text.split{ !$0.isLetter }.map { (sStr) -> String in
            String(sStr)
        }
        let genericItem = Search.turnIntoSystemItem(string: text)
        let category = GenericItem.getCategory(item: genericItem, words: words)
        var item = Item(name: text, selected: false, category: category.rawValue, store: currentStore, user: nil, ownID: nil, storageSection: nil, timeAdded: nil, timeExpires: nil, systemItem: genericItem, systemCategory: category)
        item.writeToFirestoreForList(db: db)
        
        if list?.items?.isEmpty == false {
            list?.items!.append(item)
        } else {
            list?.items = [item]
        }
        
        textField.text = ""
    }
    
    @IBAction func textDidChange(_ sender: Any) {
        if textAssistantViewActive == false {
            // add the view here
            let vc = storyboard?.instantiateViewController(withIdentifier: "createNewItemVC") as! CreateNewItemVC
            self.addChild(vc)
            self.view.addSubview(vc.tableView)
            vc.didMove(toParent: self)
            vc.tableView.translatesAutoresizingMaskIntoConstraints = false
            vc.tableView.topAnchor.constraint(equalTo: textField.bottomAnchor).isActive = true
            
            
            #error("amount on keyboard is a little off first time opened for some reason")
            vc.tableView.topAnchor.constraint(equalTo: textField.bottomAnchor).isActive = true
            vc.tableView.heightAnchor.constraint(equalToConstant: (self.view.bounds.height - textField.bounds.height - (keyboardHeight ?? 0.0))).isActive = true
            vc.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
            vc.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
            vc.delegate = self as CreateNewItemDelegate
            delegate = vc
            
            delegate.searchTextChanged(text: textField.text!)
            textAssistantViewActive = true
            vc.tableView.reloadData()
        } else {
            delegate.searchTextChanged(text: textField.text!)
        }
    }
    
    @objc func dismissKeyboardPressed() {
        textField.resignFirstResponder()
        textField.text = ""
        delegate.searchTextChanged(text: "")
    }
}


extension AddItemsVC: CreateNewItemDelegate {
    func itemCreated(item: Item) {
        toAddItem(text: item.name)
        textField.text = ""
        textAssistantViewActive = false
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
        
        if #available(iOS 13.0, *) {
            l.backgroundColor = .secondarySystemBackground
            l.textColor = .label
        } else {
            l.backgroundColor = .lightGray
            l.textColor = .white
        }
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
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let item = arrayArrayItems[indexPath.section][indexPath.row]
        
        tableView.beginUpdates()
        self.tableView.deleteRows(at: [indexPath], with: .automatic)
        arrayArrayItems[indexPath.section].remove(at: indexPath.row)
        tableView.endUpdates()
        item.deleteItemFromList(db: db, listID: list?.docID ?? " ")
    }
}

extension AddItemsVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            toAddItem(text: textField.text!)
            delegate.searchTextChanged(text: "")
        }
        return true
    }
}




// handlers
extension AddItemsVC {
    func pushToCreateGroupVC() {
        if SharedValues.shared.anonymousUser != true {
            let vc = storyboard?.instantiateViewController(withIdentifier: "createGroup") as! CreateGroupVC
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Error", message: "Create a free account to be able to create groups.", preferredStyle: .alert)
            alert.addAction(.init(title: "Ok", style: .default, handler: nil))
            present(alert, animated: true)
        }
        
    }
    func addItemsToStorageIfPossible(sendList: GroceryList, foodStorageEmails: [String]?) {
        if list != nil && list?.items?.isEmpty == false {
            if let id = SharedValues.shared.foodStorageID {
                FoodStorage.addItemsFromListintoFoodStorage(sendList: list!, storageID: id, db: db)
                // to set all the items in the list to not selected
                for index in (list?.items!.indices)! {
                    list?.items?[index].selected = false
                }
                
                self.createMessageView(color: Colors.messageGreen, text: "Items added to storage")
            }
        } else {
            let alert = UIAlertController(title: "Error", message: "There are no selected from your list. Only selected items will be sent to your storage.", preferredStyle: .alert)
            alert.addAction(.init(title: "Ok", style: .default, handler: nil))
            present(alert, animated: true)
        }
    }
}
