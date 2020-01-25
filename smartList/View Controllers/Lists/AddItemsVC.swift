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
    
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var storesView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var tableViewToStoresView: NSLayoutConstraint!
    @IBOutlet weak var tableViewToTopView: NSLayoutConstraint!
    
    
    var db: Firestore!
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
    
    
    var list: GroceryList? {
        didSet {
            if list?.items?.isEmpty == false {
                (sortedCategories, arrayArrayItems) = (list?.sortForTableView(from: currentStore))!
                tableView.reloadData()
            } else {
                arrayArrayItems = []
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        textField.setUpCancelAndAddToolbar(cancelAction: #selector(dismissKeyboardPressed), addAction: #selector(addItemAction))
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        if SharedValues.shared.isPhone == false {
            topViewHeight.isActive = false
            topView.heightAnchor.constraint(equalToConstant: 55).isActive = true
            textField.font = UIFont(name: "futura", size: 27)
            plusButton.titleLabel?.font = UIFont(name: "futura", size: 55)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillAppear(animated)
        tableView.delegate = self
        tableView.dataSource = self
        textField.delegate = self
        
        setUIfrom(list: list!)
        
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
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillDisappear(animated)
        SharedValues.shared.listIdentifier?.updateData([
            "numItems": list?.items?.count as Any
        ])
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func addItem(_ sender: Any) {
        addItemAction()
    }
    
    @IBAction func segmentedControlPressed(_ sender: Any) {
        (sortedCategories, arrayArrayItems) = (list?.sortForTableView(from: currentStore))!
        tableView.reloadData()
    }
    
    @IBAction func editList(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "setUpList") as! SetUpListVC
        if list?.docID == nil {
            list?.docID = SharedValues.shared.listIdentifier?.documentID
        }
        vc.listToEdit = list
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
        
    }
    
    @IBAction func deleteList(_ sender: Any) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(.init(title: "Delete list", style: .destructive, handler: { action in
            self.list?.deleteListToFirestore(db: self.db)
            self.navigationController?.popToRootViewController(animated: true)
        }))
        actionSheet.addAction(.init(title: "Delete items from list (and keep list)", style: .destructive, handler: { action in
            if let items = self.list?.items {
                for item in items {
                    item.deleteItemFromList(db: self.db, listID: self.list?.ownID ?? " ")
                }
            }
        }))
        actionSheet.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            present(actionSheet, animated: true)
        } else {
            // do other stuff for iPad
            guard let viewRect = sender as? UIView else { return }
            if let presenter = actionSheet.popoverPresentationController {
                presenter.sourceView = viewRect
                presenter.sourceRect = viewRect.bounds
            }
            present(actionSheet, animated: true, completion: nil)
        }
    }
    
    @IBAction func textDidChange(_ sender: Any) {
        if textAssistantViewActive == false {
            // add the view here
            let vc = storyboard?.instantiateViewController(withIdentifier: "createNewItemVC") as! CreateNewItemVC
            self.addChild(vc)
            self.view.addSubview(vc.tableView)
            vc.didMove(toParent: self)
            
            vc.tableView.translatesAutoresizingMaskIntoConstraints = false
            
            vc.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
            vc.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
            vc.tableView.topAnchor.constraint(equalTo: topView.bottomAnchor).isActive = true
            
            let tb = (tabBarController?.tabBar.frame.height ?? 0.0)
            let distance = (backView.frame.height) - (keyboardHeight ?? 0.0) - (topView.frame.height) + tb
            
            vc.tableView.heightAnchor.constraint(equalToConstant: distance).isActive = true
            
            vc.delegate = self as CreateNewItemDelegate
            delegate = vc
            delegate.searchTextChanged(text: textField.text!)
            textAssistantViewActive = true
        } else {
            delegate.searchTextChanged(text: textField.text!)
        }
    }
    
    @IBAction func doneWithList(_ sender: Any) {
        if SharedValues.shared.foodStorageID != nil {
            var gottenEmails: [String]?
            FoodStorage.getEmailsfromStorageID(storageID: SharedValues.shared.foodStorageID ?? " ", db: db) { (emails) in
                gottenEmails = emails
            }
            
            let alert = UIAlertController(title: "Are you done with the list?", message: "Items from this list will be added to your storage, where you can keep track of your items.", preferredStyle: .actionSheet)
            alert.addAction(.init(title: "Add selected items to storage", style: .default, handler: {(alert: UIAlertAction!) in self.addSelectedItemsToStorageIfPossible(sendList: self.list!, foodStorageEmails: gottenEmails)
            }))
            alert.addAction(.init(title: "Add all items to storage", style: .default, handler: { (alert: UIAlertAction!) in
                print("Add all items to storage")
                self.addAllItemsToStorage(sendList: self.list!, foodStorageEmails: gottenEmails)
            }))
            alert.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
            
            if UIDevice.current.userInterfaceIdiom == .phone {
                present(alert, animated: true)
            } else {
                guard let viewRect = sender as? UIView else { return }
                if let presenter = alert.popoverPresentationController {
                    presenter.sourceView = viewRect
                    presenter.sourceRect = viewRect.bounds
                }
                present(alert, animated: true)
            }
            
        } else {
            let userFS = FoodStorage(isGroup: false, groupID: nil, peopleEmails: [Auth.auth().currentUser?.email ?? "no email"], items: nil, numberOfPeople: 1)
            if SharedValues.shared.groupID == nil {
                let alert = UIAlertController(title: "Error - can't add items to storage", message: "In order to have a shared storage where multiple people can view the items, first create a group.", preferredStyle: .actionSheet)
                alert.addAction(.init(title: "Create group", style: .default, handler: {(alert: UIAlertAction!) in self.pushToCreateGroupVC()}))
                alert.addAction(.init(title: "Create own storage without group", style: .default, handler: {(alert: UIAlertAction!) in FoodStorage.createStorageToFirestoreWithPeople(db: self.db, foodStorage: userFS)}))
                alert.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
                
                
                if UIDevice.current.userInterfaceIdiom == .phone {
                    present(alert, animated: true)
                } else {
                    guard let viewRect = sender as? UIView else { return }
                    if let presenter = alert.popoverPresentationController {
                        presenter.sourceView = viewRect
                        presenter.sourceRect = viewRect.bounds
                    }
                    present(alert, animated: true)
                }
                
            } else {
                let groupFS = FoodStorage(isGroup: true, groupID: SharedValues.shared.groupID, peopleEmails: SharedValues.shared.groupEmails, items: nil, numberOfPeople: SharedValues.shared.groupEmails?.count)
                let alert = UIAlertController(title: "Error - can't add items to storage", message: "Create a storage to be able to view the current food items you have in stock.", preferredStyle: .actionSheet)
                alert.addAction(.init(title: "Create storage with group (recommended)", style: .default, handler: {(alert: UIAlertAction!) in FoodStorage.createStorageToFirestoreWithPeople(db: self.db, foodStorage: groupFS)}))
                alert.addAction(.init(title: "Create own storage without group", style: .default, handler: {(alert: UIAlertAction!) in FoodStorage.createStorageToFirestoreWithPeople(db: self.db, foodStorage: userFS)}))
                alert.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
                
                if UIDevice.current.userInterfaceIdiom == .phone {
                    present(alert, animated: true)
                } else {
                    guard let viewRect = sender as? UIView else { return }
                    if let presenter = alert.popoverPresentationController {
                        presenter.sourceView = viewRect
                        presenter.sourceRect = viewRect.bounds
                    }
                    present(alert, animated: true)
                }
            }
        }
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            keyboardHeight = keyboardRectangle.height
        }
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
            #warning("could do something to hide where the stores segmented control would be here")
            
            tableViewToTopView.priority = UILayoutPriority(rawValue: 1000)
            tableViewToStoresView.priority = UILayoutPriority(rawValue: 999)
        } else {
            segmentedControl.isHidden = false
            
            tableViewToTopView.priority = UILayoutPriority(rawValue: 999)
            tableViewToStoresView.priority = UILayoutPriority(rawValue: 1000)
        }
        
    }
    
    @objc private func addItemAction() {
        if textField.text != "" {
            toAddItem(text: textField.text!)
            delegate.searchTextChanged(text: "")
        }
    }
    
    private func toAddItem(text: String) {
        let words = text.split{ !$0.isLetter }.map { (sStr) -> String in
            String(sStr.lowercased())
        }
        let genericItem = Search.turnIntoSystemItem(string: text)
        let category = GenericItem.getCategory(item: genericItem, words: words)
        var item = Item(name: text, selected: false, category: category.rawValue, store: currentStore, user: nil, ownID: nil, storageSection: nil, timeAdded: nil, timeExpires: nil, systemItem: genericItem, systemCategory: category, quantity: nil)
        item.writeToFirestoreForList(db: db)
        
        list?.items?.append(item)
        
        if let id = list?.ownID {
            GroceryList.updateListTimeIntervalTime(db: db, listID: id, timeToSetTo: Date().timeIntervalSince1970)
        }
        
        textField.text = ""
    }
    
    
    
    @objc func dismissKeyboardPressed() {
        textField.resignFirstResponder()
        if textField.text != "" {
            textField.text = ""
            delegate.searchTextChanged(text: "")
        }
        
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
        
        if SharedValues.shared.isPhone == true {
            l.font = UIFont(name: "futura", size: 15)
        } else {
            l.font = UIFont(name: "futura", size: 22.5)
        }
        
        
        
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
        if arrayArrayItems.isEmpty == false {
            let item = arrayArrayItems[indexPath.section][indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell") as! ItemCell
            cell.setUI(item: item)
            cell.delegate = self
            return cell
        } else {
            return UITableViewCell()
        }
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

extension AddItemsVC: ItemCellDelegate {
    func edit(item: Item) {
        
        var text: String? {
            if item.user != nil {
                return "Item added by \(item.user!)"
            } else {
                return nil
            }
        }
        
        let actionSheet = UIAlertController(title: nil, message: text, preferredStyle: .actionSheet)
        
        
        actionSheet.addAction(.init(title: "Change quantity", style: .default, handler: { (alert) in
            print("Need to change quantity here")
            self.quantityAlert(item: item)
        }))
        
        actionSheet.addAction(.init(title: "Edit name", style: .default, handler: { alert in
            self.nameAlert(item: item)
        }))
        actionSheet.addAction(.init(title: "Edit category", style: .default, handler: { alert in
            self.createEditItemInfoView(forCategory: true, stores: nil, item: item, listID: self.list?.ownID)
        }))
        
        actionSheet.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
        
        if list?.stores?.count ?? 0 > 1 {
            actionSheet.addAction(.init(title: "Edit store", style: .default, handler: { alert in
                self.createEditItemInfoView(forCategory: false, stores: self.list?.stores, item: item, listID: self.list?.ownID)
            }))
        }
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            present(actionSheet, animated: true)
        } else {
            actionSheet.popoverPresentationController?.sourceView = self.view
            actionSheet.popoverPresentationController?.sourceRect = segmentedControl.frame
            present(actionSheet, animated: true, completion: nil)
        }
    }
    
    private func quantityAlert(item: Item) {
        // could clean up string presenting format
        let alert = UIAlertController(title: nil, message: "Add quantity for \(item.name)", preferredStyle: .alert)
        alert.addTextField { (txtField) in
            txtField.keyboardType = .numbersAndPunctuation
            txtField.textColor = Colors.main
        }
        alert.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(.init(title: "Done", style: .default, handler: { (action) in
            if let itemID = item.ownID, let listID = self.list?.ownID, let quantity = alert.textFields?.first?.text {
                Item.updateItemForListQuantity(quantity: quantity, itemID: itemID, listID: listID, db: self.db)
            }
        }))
        present(alert, animated: true)
    }
    
    private func nameAlert(item: Item) {
        let alert = UIAlertController(title: nil, message: "Edit name for \(item.name)", preferredStyle: .alert)
        alert.addTextField { (txtField) in
            txtField.textColor = Colors.main
        }
        alert.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(.init(title: "Done", style: .default, handler: { action in
            if let itemID = item.ownID, let listID = self.list?.ownID, let name = alert.textFields?.first?.text {
                if name != "" {
                    Item.updateItemForListName(name: name, itemID: itemID, listID: listID, db: self.db)
                }
            }
        }))
        present(alert, animated: true)
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
    func addSelectedItemsToStorageIfPossible(sendList: GroceryList, foodStorageEmails: [String]?) {
        if list != nil && list?.items?.isEmpty == false {
            if let id = SharedValues.shared.foodStorageID {
                FoodStorage.addItemsFromListintoFoodStorage(sendList: list!, storageID: id, db: db)
                var numItemsAdded = 0
                for index in (list?.items!.indices)! {
                    if list?.items?[index].selected == true {
                        numItemsAdded += 1
                        list?.items?[index].selected = false
                    }
                    
                }
                
                if numItemsAdded > 0 {
                    self.createMessageView(color: Colors.messageGreen, text: "Items added to storage")
                } else {
                    self.createMessageView(color: .red, text: "No items selected")
                }
                numItemsAdded = 0
            }
        } else {
            let alert = UIAlertController(title: "Error", message: "There are no items in your list Add items to be able to add them to your storage.", preferredStyle: .alert)
            alert.addAction(.init(title: "Ok", style: .default, handler: nil))
            present(alert, animated: true)
        }
    }
    
    func addAllItemsToStorage(sendList: GroceryList, foodStorageEmails: [String]?) {
        
        if list != nil && list?.items?.isEmpty == false {
            if let id = SharedValues.shared.foodStorageID {
                FoodStorage.addAllItemsFromListintoFoodStorage(sendList: list!, storageID: id, db: db)
                for index in (list?.items!.indices)! {
                    list?.items?[index].selected = false
                    
                }
                
                self.createMessageView(color: Colors.messageGreen, text: "Items added to storage")
                
            }
        } else {
            let alert = UIAlertController(title: "Error", message: "There are no items in your list Add items to be able to add them to your storage.", preferredStyle: .alert)
            alert.addAction(.init(title: "Ok", style: .default, handler: nil))
            present(alert, animated: true)
        }
        
        
    }
}
