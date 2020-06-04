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
import Firebase
import AVFoundation

class StorageHomeVC: UIViewController {
    
    @IBOutlet var optionButtons: [UIButton]!
    @IBOutlet var optionSingleItemButtons: [UIButton]!
    @IBOutlet weak var pickerView: UIDatePicker!
    @IBOutlet weak var searchOutlet: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var pickerPopUpView: UIView!
    @IBOutlet weak var expirationDateOutlet: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var helperView: UIView!
    @IBOutlet weak var popUpViewWidth: NSLayoutConstraint!
    
    var db: Firestore!
    private var foodStorage: FoodStorage? {
        didSet {
            self.foodStorage?.delegate = self
        }
    }
    lazy private var emptyCells: [UITableViewCell] = []
    private var searchActive = false
    private var currentlySelectedItems: [Item] = [] {
        didSet {
            handlePopUpView()
        }
    }
    

    
    private var sortedItems: [Item] = [] {
        didSet {
            tableView.reloadData()
            handlePopUpView()
        }
    }
    
    // MARK: override funcs
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        
        createObserver()
        
        if let id = SharedValues.shared.foodStorageID {
            foodStorage = FoodStorage(isGroup: SharedValues.shared.isStorageWithGroup, groupID: id, peopleEmails: SharedValues.shared.groupEmails, items: nil, numberOfPeople: nil)
            foodStorage?.readItemsForStorage(db: db, storageID: id)
            
        } else {
            foodStorage = nil
        }
        
        popUpView.shadow()
        pickerPopUpView.shadow()
        
        searchBar.placeholder = ""
        searchBar.setTextProperties()
        searchOutlet.setImage(UIImage(named: "search-3-xl"), for: .normal)
        helperView.shadowAndRounded(cornerRadius: 10, border: false)
        
        if SharedValues.shared.isPhone == false {
            // need to change the size of the pop up view if on iPad
            popUpViewWidth.isActive = false
            popUpView.widthAnchor.constraint(equalToConstant: 150.0).isActive = true
            
            let font = UIFont(name: "futura", size: 17)
            
            optionButtons.forEach { (button) in
                button.titleLabel?.font = font
            }
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        emptyCells = createEmptyStorageCells()
        tableView.reloadData()
        
        if SharedValues.shared.foodStorageID == nil {
            helperView.isHidden = true
        } else {
            helperView.isHidden = false
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        searchBar.isHidden = true
        segmentedControl.isHidden = false
        searchBar.placeholder = ""
        searchOutlet.setImage(UIImage(named: "search-3-xl"), for: .normal)
        searchBar.resignFirstResponder()
        searchBar.text = ""
        
        if let itms = foodStorage?.items {
            sortedItems = itms.sortItemsForTableView(segment: FoodStorageType.selectedSegment(segmentedControl: segmentedControl), searchText: "")
        } else {
            sortedItems = []
        }
        
        
        currentlySelectedItems.removeAll()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    // MARK: @IBAction funcs
    @IBAction func searchPressed(_ sender: Any) {
        
        searchActive = !searchActive
        switch searchActive {
        case true:
            searchBar.placeholder = "Search \(FoodStorageType.selectedSegment(segmentedControl: segmentedControl))"
            searchBar.isHidden = false
            searchOutlet.setImage(UIImage(named: "x-mark-4-xl"), for: .normal)
            searchBar.becomeFirstResponder()
            segmentedControl.isHidden = true
            
        case false:
            searchBar.isHidden = true
            searchBar.placeholder = ""
            searchOutlet.setImage(UIImage(named: "search-3-xl"), for: .normal)
            searchBar.resignFirstResponder()
            segmentedControl.isHidden = false
            
            if let itms = foodStorage?.items {
                sortedItems = itms.sortItemsForTableView(segment: FoodStorageType.selectedSegment(segmentedControl: segmentedControl), searchText: "")
            } else {
                sortedItems = []
            }
            
            searchBar.text = ""
        }
    }
    
    @IBAction func plusWasPressed(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "storageNewItem") as! StorageNewItemVC
        vc.foodStorage = foodStorage
        var idx: Int {
            switch segmentedControl.selectedSegmentIndex {
            case 0:
                return 0
            case 1:
                return 0
            case 2:
                return 1
            case 3:
                return 2
            default:
                return 0
            }
        }
        present(vc, animated: true, completion: nil)
        vc.segmentedControl.selectedSegmentIndex = idx
    }
    
    @IBAction func barcodeScanPressed(_ sender: Any) {
        let value = AVCaptureDevice.authorizationStatus(for: .video)
        
        let cameraPicker = UIImagePickerController()
        cameraPicker.sourceType = .camera
        cameraPicker.cameraCaptureMode = .photo
        cameraPicker.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
        present(cameraPicker, animated: true, completion: nil)
        
        
        if value == .denied || value == .restricted {
            let alert = UIAlertController(title: "Camera access was denied", message: "To enable access, go to Apple Settings > Privacy > Camera and turn on camera access for Food Guru", preferredStyle: .alert)
            alert.addAction(.init(title: "Ok", style: .default, handler: nil))
            present(alert, animated: true)
        }
    }
    
    @IBAction func segmentedControlPressed(_ sender: Any) {
        if let itms = foodStorage?.items {
            sortedItems = itms.sortItemsForTableView(segment: FoodStorageType.selectedSegment(segmentedControl: segmentedControl), searchText: searchBar.text ?? "")
        } else {
            sortedItems = []
        }
        
    }
    
    @IBAction func findRecipes(_ sender: Any) {
        
        let genericItemsFirst = currentlySelectedItems.map({$0.systemItem!.rawValue})
        let genericItems = genericItemsFirst.filter({$0 != "other"})
        
        if genericItems.count == 0 {
            let alert = UIAlertController(title: "Unable to find recipes with selected items", message: "These items do not match any records in the application, these items may be added in the future!", preferredStyle: .alert)
            alert.addAction(.init(title: "Ok", style: .default, handler: nil))
            present(alert, animated: true)
        }
        
        
        Search.getRecipesFromIngredients(db: db, ingredients: genericItems) { (rcps) in
            if let rcps = rcps {
                let genericSearches = genericItems.map({NetworkSearch(text: $0, type: .ingredient)})
                SharedValues.shared.sentRecipesInfo = (rcps, genericSearches)
                
                // to set the RecipeHomeVC to the correct current view controller
                self.tabBarController?.selectedIndex = 0
                (self.tabBarController?.viewControllers?[self.tabBarController!.selectedIndex] as? UITabBarController)?.selectedIndex = 0
                ((self.tabBarController?.viewControllers?[self.tabBarController!.selectedIndex] as? UITabBarController)?.viewControllers?[0] as? UINavigationController)?.popToRootViewController(animated: true)
                
                
                
                if (UserDefaults.standard.value(forKey: "doneSeeingNoIngredientView") as? Bool != true) && (genericItems.count != genericItemsFirst.count) {
                    print("Some items were deleted, have a little message or something")
                    self.tabBarController?.createIngredientsDidntShowInSearchView()
                }
                
            }
        }
        
    }
    
    // MARK: Pop up @IBAction funcs
    @IBAction func deleteCells(_ sender: Any) {
        let names = currentlySelectedItems.map({$0.name}).joined(separator: ", ")
        let alert = UIAlertController(title: nil, message: "Are you sure you want to delete \(names)?", preferredStyle: .alert)
        alert.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(.init(title: "Delete", style: .destructive, handler: { (alert) in
            for item in self.currentlySelectedItems {
                item.deleteItemFromStorage(db: self.db, storageID: SharedValues.shared.foodStorageID ?? " ")
            }
            self.currentlySelectedItems.removeAll()
        }))
        present(alert, animated: true)
    }
    
    @IBAction func addExpirationDateCells(_ sender: Any) {
        if pickerPopUpView.isHidden {
            pickerPopUpView.setIsHidden(false, animated: true)
            
            if currentlySelectedItems.count == 1 {
                let item = currentlySelectedItems.first!
                if let genericItem = item.systemItem {
                    if genericItem != .other {
                        let additionalTime = GenericItem.getSuggestedExpirationDate(item: genericItem, storageType: item.storageSection ?? .unsorted)
                        let date = Date(timeIntervalSince1970: Date().timeIntervalSince1970 + Double(additionalTime))
                        pickerView.setDate(date, animated: true)
                    }
                }
                
            }
            expirationDateOutlet.setTitleColor(Colors.main, for: .normal)
        } else {
            pickerPopUpView.setIsHidden(true, animated: true)
            expirationDateOutlet.setTitleColor(.lightGray, for: .normal)
        }
    }
    
    
    @IBAction func putInFridgeCells(_ sender: Any) {
        handleCellSortingTo(segment: "fridge")
    }
    @IBAction func putInFreezerCells(_ sender: Any) {
        handleCellSortingTo(segment: "freezer")
    }
    @IBAction func putInPantryCells(_ sender: Any) {
        handleCellSortingTo(segment: "pantry")
    }
    
    @IBAction func doneAddingExpirationDate(_ sender: Any) {
        for item in currentlySelectedItems {
            item.addExpirationDateToItem(db: db, timeIntervalSince1970: pickerView.date.timeIntervalSince1970)
        }
        currentlySelectedItems.removeAll()
    }
    
    @IBAction func editNamePressed(_ sender: Any) {
        if let itm = currentlySelectedItems.first {
            nameAlert(item: itm)
        }
        
    }
    @IBAction func editQuantityPressed(_ sender: Any) {
        if let itm = currentlySelectedItems.first {
            self.createEditQuantityView(item: itm)
        }
    }
    
    @IBAction func addToListPressed(_ sender: Any) {
        print("Add the items to the list")
        let ingredientsToAddToList = currentlySelectedItems.map({$0.name})
        guard let uid = Auth.auth().currentUser?.uid else { return }
        GroceryList.getUsersCurrentList(db: db, userID: uid) { (list) in
            if let list = list {
                if list.stores?.isEmpty == true {
                    for item in ingredientsToAddToList {
                        GroceryList.addItemToListFromRecipe(db: self.db, listID: list.ownID ?? " ", name: item, userID: uid, store: "")
                    }
                    self.createMessageView(color: Colors.messageGreen, text: "Items added to list!")
                } else if list.stores?.count == 1 {
                    for item in ingredientsToAddToList {
                        GroceryList.addItemToListFromRecipe(db: self.db, listID: list.ownID ?? " ", name: item, userID: uid, store: list.stores!.first!)
                    }
                    self.createMessageView(color: Colors.messageGreen, text: "Items added to list!")
                } else {
                    
                    
                    self.createPickerView(itemNames: ingredientsToAddToList, itemStores: list.stores, itemListID: list.ownID ?? " ", singleItem: (ingredientsToAddToList.count == 1), delegateVC: self)
                }
            } else {
                GroceryList.handleProcessForAutomaticallyGeneratedListFromRecipe(db: self.db, items: ingredientsToAddToList)
                
                self.createMessageView(color: Colors.messageGreen, text: "List created and items added!")
            }
        }
        
        
        currentlySelectedItems.removeAll()
        tableView.reloadData()
    }
    
    
    // MARK: functions
    @objc private func createGroupSelector() {
        if SharedValues.shared.anonymousUser == false {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "createGroup") as! CreateGroupVC
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Error", message: "Create a free account in order to share your storage with other people.", preferredStyle: .alert)
            alert.addAction(.init(title: "Ok", style: .default, handler: nil))
            present(alert, animated: true)
        }
        
        
    }
    
    @objc private func createIndividualStorage() {
        print("create individual storage")
        let foodStorage = FoodStorage(isGroup: false, groupID: nil, peopleEmails: [Auth.auth().currentUser?.email ?? "no email"], items: nil, numberOfPeople: 1)
        FoodStorage.createStorageToFirestoreWithPeople(db: db, foodStorage: foodStorage)
        tableView.reloadData()
        helperView.isHidden = false
    }
    
    
    private func nameAlert(item: Item) {
        let alert = UIAlertController(title: nil, message: "Edit name for \(item.name)", preferredStyle: .alert)
        alert.addTextField { (txtField) in
            txtField.textColor = Colors.main
        }
        alert.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(.init(title: "Done", style: .default, handler: { action in
            if let storageID = SharedValues.shared.foodStorageID, let itemID = item.ownID, let name = alert.textFields?.first?.text {
                if name != "" {
                    Item.updateItemForStorageName(name: name, itemID: itemID, storageID: storageID, db: self.db)
                    self.currentlySelectedItems.removeAll()
                    
                }
            }
        }))
        present(alert, animated: true)
    }
    
    
    private func handleCellSortingTo(segment: String) {
        
        for item in currentlySelectedItems {
            item.switchItemToSegment(named: segment, db: db/*, storageID: SharedValues.shared.foodStorageID ?? " "*/)
        }
        currentlySelectedItems.removeAll()
    }
    
    private func haveNeededSectionsInSegmentedControl(unsortedNeeded: Bool, segmentedControl: UISegmentedControl) {
        switch unsortedNeeded {
        case true:
            segmentedControl.setWidth(segmentedControl.widthForSegment(at: 1), forSegmentAt: 0)
            
        case false:
            segmentedControl.setWidth(0.1, forSegmentAt: 0)
            if segmentedControl.selectedSegmentIndex == 0 {
                segmentedControl.selectedSegmentIndex = 1
            }
        }
    }
    
    @objc private func createGroupStorage() {
        let foodStorage = FoodStorage(isGroup: true, groupID: SharedValues.shared.groupID, peopleEmails: SharedValues.shared.groupEmails ?? ["emails didnt work"], items: nil, numberOfPeople: SharedValues.shared.groupEmails?.count)
        FoodStorage.createStorageToFirestoreWithPeople(db: db, foodStorage: foodStorage)
        
        tableView.reloadData()
        helperView.isHidden = false
    }
    
    private func createObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(observerSelectorFoodStorageID), name: .foodStorageIDchanged, object: nil)
    }
    
    @objc private func observerSelectorFoodStorageID() {
        // food storage id changed
        foodStorage?.itemListener?.remove()
        foodStorage?.items = []
        
        if let id = SharedValues.shared.foodStorageID {
            foodStorage = FoodStorage(isGroup: SharedValues.shared.isStorageWithGroup, groupID: id, peopleEmails: SharedValues.shared.groupEmails, items: nil, numberOfPeople: nil)
            foodStorage?.readItemsForStorage(db: db, storageID: id)
        }
        
        tableView.reloadData()
    }
}

// MARK: FoodStorageDelegate

extension StorageHomeVC: FoodStorageDelegate {
    func itemsUpdated() {
        
        segmentedControl.setTitle("None \(foodStorage?.items?.filter({$0.storageSection == .unsorted}).count ?? 0)", forSegmentAt: 0)
        segmentedControl.setTitle("Fridge \(foodStorage?.items?.filter({$0.storageSection == .fridge}).count ?? 0)", forSegmentAt: 1)
        segmentedControl.setTitle("Freezer \(foodStorage?.items?.filter({$0.storageSection == .freezer}).count ?? 0)", forSegmentAt: 2)
        segmentedControl.setTitle("Pantry \(foodStorage?.items?.filter({$0.storageSection == .pantry}).count ?? 0)", forSegmentAt: 3)
//        let itms = foodStorage?.items.map({$0.storageSection})
        
        var itms: [FoodStorageType] {
            if let i = foodStorage?.items {
                return i.map({($0.storageSection ?? .unsorted)})
            } else {
                return []
            }
        }
        
        let boolean = FoodStorageType.isUnsortedSegmentNeeded(types: itms)
        haveNeededSectionsInSegmentedControl(unsortedNeeded: boolean, segmentedControl: segmentedControl)
        
        if let itms = foodStorage?.items {
            sortedItems = itms.sortItemsForTableView(segment: FoodStorageType.selectedSegment(segmentedControl: segmentedControl), searchText: searchBar.text ?? "")
        } else {
            sortedItems = []
        }
        
        
    }
}


// MARK: Search bar
extension StorageHomeVC: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let itms = foodStorage?.items {
            sortedItems = itms.sortItemsForTableView(segment: FoodStorageType.selectedSegment(segmentedControl: segmentedControl), searchText: searchBar.text ?? "")
        } else {
            sortedItems = []
        }
        
    }
}

// MARK: Table view
extension StorageHomeVC: UITableViewDataSource, UITableViewDelegate {
    private func handlePopUpView() {
        let count = currentlySelectedItems.count
        if count > 0 {
            popUpView.setIsHidden(false, animated: true)
        } else {
            popUpView.setIsHidden(true, animated: true)
            pickerPopUpView.setIsHidden(true, animated: true)
            expirationDateOutlet.setTitleColor(.lightGray, for: .normal)
        }
        
        
        if count == 1 || count == 0 {
            UIView.animate(withDuration: 0.2) {
                self.optionSingleItemButtons.forEach({$0.isHidden = false})
            }
            
        } else {
            UIView.animate(withDuration: 0.2) {
                self.optionSingleItemButtons.forEach({$0.isHidden = true})
            }
            
        }
    }
    
    private func createEmptyStorageCells() -> [UITableViewCell] {
        var createGroup: Bool?
        let one = tableView.dequeueReusableCell(withIdentifier: "settingBasicCell") as! SettingBasicCell
        var oneText: String {
            if SharedValues.shared.groupID == nil {
                createGroup = true
                return "Create a group to share storage with other users, or start a storage with only yourself."
            } else {
                createGroup = false
                return ""
            }
        }
        one.setUI(str: "You do not have your storage set up. The storage will help you keep track of your purchased food, and can help you find recipes to cook.\(oneText)")
        
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
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if SharedValues.shared.foodStorageID != nil {
            if foodStorage?.items?.isEmpty == false {
                return sortedItems.count
            } else {
                return 1
            }
            
        } else {
            return emptyCells.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if SharedValues.shared.foodStorageID != nil {
            if foodStorage?.items?.isEmpty == false {
                let cell = tableView.dequeueReusableCell(withIdentifier: "storageCell") as! StorageCell
                let item = sortedItems[indexPath.row]
                cell.setUI(item: item)
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "settingBasicCell") as! SettingBasicCell
                cell.setUI(str: "Your storage is empty. To add and keep track of your items, select done after you are done using one of your lists, manually add items, or scan the barcode of items you want to add.")
                return cell
            }
        } else {
            return emptyCells[indexPath.row]
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let item = sortedItems[indexPath.row]
            item.deleteItemFromStorage(db: db, storageID: SharedValues.shared.foodStorageID ?? " ")
            
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if SharedValues.shared.foodStorageID != nil && !(foodStorage?.items?.isEmpty ?? true) {
            return true
        } else {
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        if let cell = cell as? StorageCell {
            if let itm = cell.item {
                if currentlySelectedItems.contains(itm) {
                    cell.isHighlighted = true
                }
            }
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = sortedItems[indexPath.row]
        
        if currentlySelectedItems.contains(item) {
            currentlySelectedItems.removeAll(where: {$0 == item})
        } else {
            currentlySelectedItems.append(item)
        }
        if SharedValues.shared.foodStorageID != nil {
            handlePopUpView()
        }
        tableView.reloadData()
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let item = sortedItems[indexPath.row]
        if currentlySelectedItems.contains(item) {
            currentlySelectedItems.removeAll(where: {$0 == item})
        } else {
            currentlySelectedItems.append(item)
        }
        if SharedValues.shared.foodStorageID != nil {
            handlePopUpView()
        }
        tableView.reloadData()
    }
}

// MARK: Picker controller
extension StorageHomeVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            Item.getItemFromBarcode(image: image, vc: self, picker: picker, db: db)

        }
    }
}

// MARK: EditQuantityViewDelegate
extension StorageHomeVC: EditQuantityViewDelegate {
    func newQuantity(item: Item, quantity: String?) {
        
        var qua: String {
            if let q = quantity {
                return q
            } else {
                return ""
            }
        }
        
        if let storageID = SharedValues.shared.foodStorageID, let itemID = item.ownID {
            self.currentlySelectedItems.removeAll()
            Item.updateItemForStorageQuantity(quantity: qua, itemID: itemID, storageID: storageID, db: self.db)
        }
        
    }
}
