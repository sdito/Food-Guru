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
    @IBOutlet weak var footerChangeHeight: UIView!
    @IBOutlet weak var topViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var tableViewToStoresView: NSLayoutConstraint?
    @IBOutlet weak var tableViewToTopView: NSLayoutConstraint?
    @IBOutlet weak var tableViewBottom: NSLayoutConstraint?
    private var keyboardTableViewBottom: NSLayoutConstraint?
    
    var db: Firestore!
    
    private var newItemVC: CreateNewItemVC?
    private var initialItemsAdded = false
    private var ran = false
    private var arrayArrayItems: [[Item]] = []
    private var sortedCategories: [String] = []
    private var delegate: SearchAssistantDelegate!
    private var storeText: String = "none"
    private var textAssistantViewActive = false
    private var keyboardHeight: CGFloat?
    private var animateIndexPath: IndexPath?
    private var currentStore: String {
        if segmentedControl.numberOfSegments == 0 {
            return ""
        } else {
            return segmentedControl.titleForSegment(at: segmentedControl.selectedSegmentIndex) ?? ""
        }
        
    }
    var list: GroceryList? {
        didSet {
            self.list?.delegate = self
        }
    }
    
    // MARK: override funcs
    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Firestore.firestore()
        tableView.delegate = self
        tableView.dataSource = self
        textField.delegate = self
        
        textField.setUpCancelAndAddToolbar(cancelAction: #selector(dismissKeyboardPressed), addAction: #selector(addItemAction))
        
        footerChangeHeight.translatesAutoresizingMaskIntoConstraints = false
        footerChangeHeight.heightAnchor.constraint(equalToConstant: 1).isActive = true
        if SharedValues.shared.isPhone == false {
            topViewHeight.isActive = false
            topView.heightAnchor.constraint(equalToConstant: 55).isActive = true
            textField.font = UIFont(name: "futura", size: 27)
            plusButton.titleLabel?.font = UIFont(name: "futura", size: 55)
        }
    }
    
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        initialItemsAdded = false
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillAppear(animated)
        addObservers()
        list?.listenerOnListWithDocID(db: db, docID: SharedValues.shared.listIdentifier!.documentID)
        list?.readItemsForList(db: db, docID: SharedValues.shared.listIdentifier!.documentID)
        
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        
        SharedValues.shared.listIdentifier?.updateData([
            "numItems": list?.items?.count as Any
        ])
        
        list?.itemListener?.remove()
        list?.items = nil
        list?.listListener?.remove()
        
    }
    
   
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: @IBAction funcs
    @IBAction func addItem(_ sender: Any) {
        addItemAction()
    }
    
    @IBAction func segmentedControlPressed(_ sender: Any) {
        (sortedCategories, arrayArrayItems) = (list?.sortForTableView(from: currentStore))!
        tableView.reloadData()
    }
    
    @IBAction func editList(_ sender: Any) {
        dismissKeyboardPressed()
        let vc = storyboard?.instantiateViewController(withIdentifier: "setUpList") as! SetUpListVC
        if list?.docID == nil {
            list?.docID = SharedValues.shared.listIdentifier?.documentID
        }
        vc.listToEdit = list
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
        
        
    }
    
    @IBAction func deleteList(_ sender: Any) {
        dismissKeyboardPressed()
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(.init(title: "Delete list", style: .destructive, handler: { action in
            self.list?.deleteListToFirestore(db: self.db)
            self.navigationController?.popToRootViewController(animated: true)
        }))
        actionSheet.addAction(.init(title: "Delete items from list (and keep list)", style: .destructive, handler: { action in
            if let items = self.list?.items {
                for item in items {
                    if let listID = self.list?.ownID {
                        item.deleteItemFromList(db: self.db, listID: listID)
                    }
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
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "createNewItemVC") as! CreateNewItemVC
            self.newItemVC = vc
            self.addChild(vc)
            self.view.addSubview(vc.tableView)
            vc.didMove(toParent: self)
            
            if let listItems = self.list?.items {
                vc.itemsFromList = listItems.map({$0.name})
            } else {
                vc.itemsFromList = []
            }
            
            vc.tableView.translatesAutoresizingMaskIntoConstraints = false
            
            vc.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
            vc.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
            vc.tableView.topAnchor.constraint(equalTo: topView.bottomAnchor).isActive = true
            
            let tb = (tabBarController?.tabBar.frame.height ?? 0.0)
            let distance = (backView.frame.height) - (keyboardHeight ?? 0.0) - (topView.frame.height) + tb
            
            vc.maximumAllowedHeight = distance
            vc.heightConstraint = vc.tableView.heightAnchor.constraint(equalToConstant: distance)
            vc.heightConstraint!.isActive = true
            
            vc.delegate = self as CreateNewItemDelegate
            delegate = vc
            delegate.searchTextChanged(text: textField.text!)
            textAssistantViewActive = true
        } else {
            delegate.searchTextChanged(text: textField.text!)
        }
    }
    
    @IBAction func doneWithList(_ sender: Any) {
        dismissKeyboardPressed()
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
    // MARK: functions
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        print("Keyboard will show is being called")
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            keyboardHeight = keyboardRectangle.height
            tableViewBottom?.isActive = false
            keyboardTableViewBottom = tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -(keyboardHeight ?? 0.0))
            keyboardTableViewBottom?.isActive = true
            
        }
    }
    @objc private func keyboardWillHide(_ notification: Notification) {
        kbwh()
    }
    
    private func kbwh() {
        print("Keyboard will hide is being called")
        keyboardTableViewBottom?.isActive = false
        tableViewBottom = tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -(self.tabBarController?.tabBar.bounds.height ?? 0.0))
        tableViewBottom!.isActive = true
        
    }
    

    func setUIfrom(list: GroceryList) {
        //segmented control set up, only update the segmented controls if the stores changed
        
        var prevStores: [String] = []
        let numOfSegments = segmentedControl.numberOfSegments
        if numOfSegments > 0 {
            for i in 0..<numOfSegments {
                prevStores.append(segmentedControl.titleForSegment(at: i)!)
            }
        }
        if prevStores.sorted() != list.stores?.sorted() ?? ["_"] {
            
            segmentedControl.removeAllSegments()
            
            list.stores?.forEach({ (store) in
                segmentedControl.insertSegment(withTitle: store, at: 0, animated: false)
            })
            
            segmentedControl.selectedSegmentIndex = 0
                
            tableViewToStoresView?.isActive = false
            tableViewToTopView?.isActive = false
            
            if list.stores?.isEmpty == true {
                segmentedControl.isHidden = true
                
                tableViewToTopView = tableView.topAnchor.constraint(equalTo: topView.bottomAnchor)
                tableViewToStoresView?.isActive = false
                tableViewToTopView!.isActive = true
                
            } else {
                segmentedControl.isHidden = false
                
                tableViewToStoresView = tableView.topAnchor.constraint(equalTo: storesView.bottomAnchor)
                tableViewToTopView?.isActive = false
                tableViewToStoresView!.isActive = true
                
            }
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
    
    private func animateNewCell(cell: UITableViewCell) {
        UIView.animate(withDuration: 0.6, animations: {
            cell.contentView.backgroundColor = Colors.secondary
        }) { (complete) in
            UIView.animate(withDuration: 0.3) {
                cell.contentView.backgroundColor = .clear
            }
        }
    }
    
    
    @objc func dismissKeyboardPressed() {
        textField.resignFirstResponder()
        if textField.text != "" {
            textField.text = ""
            delegate.searchTextChanged(text: "")
        }
        
    }
    

}


// MARK: Table view
// have the cells organized by
extension AddItemsVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        let completeCount = arrayArrayItems.joined().count
        if completeCount == 0 {
            return 1
        } else {
            return sortedCategories.count
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let completeCount = arrayArrayItems.joined().count
        
        
        var sectionTitle: String {
            if completeCount == 0 {
                return "Items"
            } else {
                return sortedCategories[section]
            }
        }
        
        let l = UILabel()
        l.text = sectionTitle
        
        if SharedValues.shared.isPhone == true {
            l.font = UIFont(name: "futura", size: 15)
        } else {
            l.font = UIFont(name: "futura", size: 22.5)
        }
        
        l.backgroundColor = Colors.secondarySystemBackground
        l.textColor = Colors.label
        l.alpha = 0.9
        l.textAlignment = .center
        return l
        
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let completeCount = arrayArrayItems.joined().count
        if completeCount == 0 {
            // Need to have something telling the user that there are no items for this store, if there are stores, etc
            return 1
        } else {
            return arrayArrayItems[section].count
        }
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let completeCount = arrayArrayItems.joined().count
        if completeCount != 0 {
            let item = arrayArrayItems[indexPath.section][indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell") as! ItemCell
            cell.setUI(item: item)
            cell.delegate = self
            return cell
        } else {
            var cellText: String {
                if currentStore == "" || list?.stores?.count == 1 || currentStore == "_Trader Joe's" {
                    return "No items in list yet!"
                } else {
                    return "\(currentStore) doesn't have any items yet!"
                }
            }
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.textLabel?.text = cellText
            cell.textLabel?.font = UIFont(name: "futura", size: 17)
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.numberOfLines = 0
            return cell
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print(list?.items.map({$0.map({$0.name})}))
        arrayArrayItems[indexPath.section][indexPath.row].selected = !arrayArrayItems[indexPath.section][indexPath.row].selected
        arrayArrayItems[indexPath.section][indexPath.row].selectedItem(db: db)
        tableView.reloadData()
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let completeCount = arrayArrayItems.joined().count
        if completeCount == 0 {
            return false
        } else {
            return true
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let item = arrayArrayItems[indexPath.section][indexPath.row]
        item.deleteItemFromList(db: db, listID: list?.docID ?? " ")
//        list?.items?.removeAll(where: { (itm) -> Bool in
//            itm.ownID == item.ownID
//        })
        tableView.reloadData()
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if let ip = animateIndexPath {
            if let cell = self.tableView.cellForRow(at: ip) {
                print("Cell visible")
                animateIndexPath = nil
                animateNewCell(cell: cell)
            }
        }
    }
}

// MARK: CreateNewItemDelegate
extension AddItemsVC: CreateNewItemDelegate {
    func searchCreated(search: NetworkSearch) {}
    
    func itemCreated(item: Item) {
        toAddItem(text: item.name)
        textField.text = ""
        textAssistantViewActive = false
    }
    
}

// MARK: ItemCellDelegate
extension AddItemsVC: ItemCellDelegate {
    func edit(item: Item, sender: UIView) {

        dismissKeyboardPressed()
        
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
//            self.quantityAlert(item: item)
            self.createEditQuantityView(item: item)
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
            actionSheet.popoverPresentationController?.sourceView = sender
            actionSheet.popoverPresentationController?.sourceRect = sender.bounds
            present(actionSheet, animated: true, completion: nil)
        }
    }
    
//    private func quantityAlert(item: Item) {
//        // could clean up string presenting format
//        let alert = UIAlertController(title: nil, message: "Add quantity for \(item.name)", preferredStyle: .alert)
//        alert.addTextField { (txtField) in
//            txtField.keyboardType = .numbersAndPunctuation
//            txtField.textColor = Colors.main
//        }
//        alert.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
//        alert.addAction(.init(title: "Done", style: .default, handler: { (action) in
//            if let itemID = item.ownID, let listID = self.list?.ownID, let quantity = alert.textFields?.first?.text {
//                Item.updateItemForListQuantity(quantity: quantity, itemID: itemID, listID: listID, db: self.db)
//            }
//        }))
//        present(alert, animated: true)
//    }
    
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

// MARK: GroceryListDelegate

extension AddItemsVC: GroceryListDelegate {
    // Scroll to the new item added (if not already visible), then highlight the cell momentarily/maybe do other ui stuff
    func potentialUiForRow(item: Item) {
        
        if initialItemsAdded == true {
            // need to momentarily highlight the row for the cell
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                print("Update row ui for: \(item.name)")
                if let ip = item.findIndexPathIn(self.arrayArrayItems) {
                    self.tableView.scrollToRow(at: ip, at: .none, animated: true)
                    if let cell = self.tableView.cellForRow(at: ip) {
                        self.animateNewCell(cell: cell)
                    } else {
                        self.animateIndexPath = ip
                    }
                }
            }
        }
    }
    
    func updateListUI() {
        setUIfrom(list: self.list!)
    }
    
    func itemsUpdated() {
        
        initialItemsAdded = true
        // have a boolean value, before the first run the individual rows will not update, after that, then they will, delegate in other function
        
        if list?.items?.isEmpty == false {
            (sortedCategories, arrayArrayItems) = (list?.sortForTableView(from: currentStore))!
            tableView.reloadData()
        } else {
            (sortedCategories, arrayArrayItems) = ([], [])
            tableView.reloadData()
        }
        
        if let listItems = list?.items {
            let nItems = listItems.map({$0.name})
            self.newItemVC?.itemsFromList = nItems
            self.newItemVC?.tableView.reloadData()
        } else {
            self.newItemVC?.itemsFromList = []
            self.newItemVC?.tableView.reloadData()
        }
    }
    
    func reloadTable() {
        tableView.reloadData()
    }
    
}


// MARK: EditQuantityViewDelegate
extension AddItemsVC: EditQuantityViewDelegate {
    func newQuantity(item: Item, quantity: String?) {
        var qua: String {
            if let q = quantity {
                return q
            } else {
                return ""
            }
        }
        
        print("\(item.name)'s new quantity is \(qua)")
        
        if let itemID = item.ownID, let listID = list?.ownID {
            Item.updateItemForListQuantity(quantity: qua, itemID: itemID, listID: listID, db: db)
        }
        
        
    }
    
}



// MARK: Text field delegate
extension AddItemsVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            toAddItem(text: textField.text!)
            delegate.searchTextChanged(text: "")
        }
        return true
    }
}




// MARK: Handlers
extension AddItemsVC {
    func pushToCreateGroupVC() {
        if SharedValues.shared.anonymousUser != true {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "createGroup") as! CreateGroupVC
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
