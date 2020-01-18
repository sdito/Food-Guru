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
    
    #warning("make sure this is being used, left off wtih this, need to have the items stay selected between tabs, and then used for the action, rather than just taking the current selected rows")
    private var currentlySelectedItems: [Item] = [] {
        didSet {
            handlePopUpView()
        }
    }
    
//    private var indexes: [Int]? {
//        return tableView.indexPathsForSelectedRows?.map({$0.row})
//    }
    
    var db: Firestore!
    lazy private var emptyCells: [UITableViewCell] = []
    private var searchActive = false
    
    @IBOutlet weak var pickerView: UIDatePicker!
    
    @IBOutlet weak var searchOutlet: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var pickerPopUpView: UIView!
    @IBOutlet weak var expirationDateOutlet: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var helperView: UIView!
    
    @IBOutlet weak var popUpViewHeight: NSLayoutConstraint!
    @IBOutlet weak var popUpViewWidth: NSLayoutConstraint!
    
    @IBOutlet var optionButtons: [UIButton]!
    
    
    var items: [Item] = [] {
        didSet {
            segmentedControl.setTitle("None \(self.items.filter({$0.storageSection == .unsorted}).count)", forSegmentAt: 0)
            segmentedControl.setTitle("Fridge \(self.items.filter({$0.storageSection == .fridge}).count)", forSegmentAt: 1)
            segmentedControl.setTitle("Freezer \(self.items.filter({$0.storageSection == .freezer}).count)", forSegmentAt: 2)
            segmentedControl.setTitle("Pantry \(self.items.filter({$0.storageSection == .pantry}).count)", forSegmentAt: 3)
            let itms = self.items.map({$0.storageSection})
            let boolean = FoodStorageType.isUnsortedSegmentNeeded(types: itms as! [FoodStorageType])
            haveNeededSectionsInSegmentedControl(unsortedNeeded: boolean, segmentedControl: segmentedControl)
            sortedItems = self.items.sortItemsForTableView(segment: FoodStorageType.selectedSegment(segmentedControl: segmentedControl), searchText: searchBar.text ?? "")
        }
    }
    
    var sortedItems: [Item] = [] {
        didSet {
            tableView.reloadData()
            handlePopUpView()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        
        createObserver()
        
        if let id = SharedValues.shared.foodStorageID {
            Item.readItemsForStorage(db: db, storageID: id) { (itms) in
                self.items = itms
            }
        } else {
            self.items = []
        }
        
        popUpView.shadow()
        pickerPopUpView.shadow()
        
        searchBar.placeholder = ""
        searchBar.setTextProperties()
        searchOutlet.setImage(UIImage(named: "search-3-xl"), for: .normal)
        helperView.shadowAndRounded(cornerRadius: 10, border: false)
        
        if SharedValues.shared.isPhone == false {
            // need to change the size of the pop up view if on iPad
            popUpViewHeight.isActive = false
            popUpViewWidth.isActive = false
            popUpView.heightAnchor.constraint(equalToConstant: 300.0).isActive = true
            popUpView.widthAnchor.constraint(equalToConstant: 150.0).isActive = true
            
            let font = UIFont(name: "futura", size: 15)
            
            optionButtons.forEach { (button) in
                button.titleLabel?.font = font
            }
        }
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        emptyCells = createEmptyStorageCells()
        tableView.reloadData()
        
        if SharedValues.shared.foodStorageID == nil {
            helperView.isHidden = true
        } else {
            helperView.isHidden = false
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        searchBar.isHidden = true
        segmentedControl.isHidden = false
        searchBar.placeholder = ""
        searchOutlet.setImage(UIImage(named: "search-3-xl"), for: .normal)
        searchBar.resignFirstResponder()
        searchBar.text = ""
        sortedItems = items.sortItemsForTableView(segment: FoodStorageType.selectedSegment(segmentedControl: segmentedControl), searchText: "")
        
        currentlySelectedItems.removeAll()
    }
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
            sortedItems = items.sortItemsForTableView(segment: FoodStorageType.selectedSegment(segmentedControl: segmentedControl), searchText: "")
            searchBar.text = ""
        }
    }
    
    @IBAction func plusWasPressed(_ sender: Any) {
        print("Plus was pressed")
        let vc = storyboard?.instantiateViewController(withIdentifier: "storageNewItem") as! StorageNewItemVC
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
        print("barcode scanner pressed")
        
        
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
        sortedItems = self.items.sortItemsForTableView(segment: FoodStorageType.selectedSegment(segmentedControl: segmentedControl), searchText: searchBar.text ?? "")
    }
    
    @objc func createGroupSelector() {
        if SharedValues.shared.anonymousUser == false {
            let vc = storyboard?.instantiateViewController(withIdentifier: "createGroup") as! CreateGroupVC
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Error", message: "Create a free account in order to share your storage with other people.", preferredStyle: .alert)
            alert.addAction(.init(title: "Ok", style: .default, handler: nil))
            present(alert, animated: true)
        }
        
        
    }
    @objc func createIndividualStorage() {
        print("create individual storage")
        let foodStorage = FoodStorage(isGroup: false, groupID: nil, peopleEmails: [Auth.auth().currentUser?.email ?? "no email"], items: nil, numberOfPeople: 1)
        FoodStorage.createStorageToFirestoreWithPeople(db: db, foodStorage: foodStorage)
        tableView.reloadData()
        helperView.isHidden = false
    }
    
    
    @IBAction func findRecipes(_ sender: Any) {
        
        let genericItemsFirst = currentlySelectedItems.map({$0.systemItem!.rawValue})
        
        // new addition, need to handle errors associated with
        let genericItems = genericItemsFirst.filter({$0 != "other"})
        
//        #error("have a message or something saying why some certain items may not appear, and if there are no items enabled for searching, then have an alert, if there was only one item, then would be find to continue with search for recipe puppy searches")
        if genericItems.count == 0 {
            let alert = UIAlertController(title: "Unable to find recipes with selected items", message: "These items do not match any records in the application, these items may be added in the future!", preferredStyle: .alert)
            alert.addAction(.init(title: "Ok", style: .default, handler: nil))
            present(alert, animated: true)
        }
        
//        else if genericItems.count != genericItemsFirst.count {
//            print("Some items were deleted, have a little message or something")
//            self.tabBarController?.createMessageView(color: .systemRed, text: "Why don't all items appear in search?")
//        }
        
        
        
        
        Search.getRecipesFromIngredients(db: db, ingredients: genericItems) { (rcps) in
            if let rcps = rcps {
                SharedValues.shared.sentRecipesInfo = (rcps, genericItems)
                
                #warning("would need to change this if i move the recipe tab, also need to take this and make sure the correct recipe tab is visible, maybe not force unwrap these")
                // to set the RecipeHomeVC to the correct current view controller
                self.tabBarController?.selectedIndex = 1
                (self.tabBarController?.viewControllers?[self.tabBarController!.selectedIndex] as? UITabBarController)?.selectedIndex = 0
                ((self.tabBarController?.viewControllers?[self.tabBarController!.selectedIndex] as? UITabBarController)?.viewControllers?[0] as? UINavigationController)?.popToRootViewController(animated: true)
                
                
                
                if (UserDefaults.standard.value(forKey: "doneSeeingNoIngredientView") as? Bool != true) && (genericItems.count != genericItemsFirst.count) {
                    print("Some items were deleted, have a little message or something")
                    self.tabBarController?.createIngredientsDidntShowInSearchView()
                }
                
            }
        }
        
    }
    
    
    @IBAction func deleteCells(_ sender: Any) {
        //let indexes = tableView.indexPathsForSelectedRows?.map({$0.row})
        for item in currentlySelectedItems {
            item.deleteItemFromStorage(db: db, storageID: SharedValues.shared.foodStorageID ?? " ")
        }
        
        currentlySelectedItems.removeAll()
    }
    
    @IBAction func addExpirationDateCells(_ sender: Any) {
        if pickerPopUpView.isHidden {
            pickerPopUpView.setIsHidden(false, animated: true)
            #warning("could set the suggested expiration date here, ONLY if one item is currently selected: MAKE SURE THIS IS WORKING")
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
    
    @objc func createGroupStorage() {
        print("create group storage")
        let foodStorage = FoodStorage(isGroup: true, groupID: SharedValues.shared.groupID, peopleEmails: SharedValues.shared.groupEmails ?? ["emails didnt work"], items: nil, numberOfPeople: SharedValues.shared.groupEmails?.count)
        FoodStorage.createStorageToFirestoreWithPeople(db: db, foodStorage: foodStorage)
        
        tableView.reloadData()
        helperView.isHidden = false
    }
    
    private func createObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(observerSelectorFoodStorageID), name: .foodStorageIDchanged, object: nil)
    }
    
    @objc func observerSelectorFoodStorageID() {
        print("FOOD STORAGE ID CHANGED")
        Item.readItemsForStorage(db: db, storageID: SharedValues.shared.foodStorageID ?? " ") { (itms) in
            self.items = itms
        }
        tableView.reloadData()
    }
}

extension StorageHomeVC: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        sortedItems = items.sortItemsForTableView(segment: FoodStorageType.selectedSegment(segmentedControl: segmentedControl), searchText: searchBar.text ?? "")
    }
}


extension StorageHomeVC: UITableViewDataSource, UITableViewDelegate {
    private func handlePopUpView() {
        print(currentlySelectedItems.map({$0.name}))
        
        if currentlySelectedItems.count > 0 {
            popUpView.setIsHidden(false, animated: true)
        } else {
            popUpView.setIsHidden(true, animated: true)
            pickerPopUpView.setIsHidden(true, animated: true)
            expirationDateOutlet.setTitleColor(.lightGray, for: .normal)
        }
        
//        if tableView.indexPathsForSelectedRows?.count ?? 0 >= 1 {
//            popUpView.setIsHidden(false, animated: true)
//        } else {
//            popUpView.setIsHidden(true, animated: true)
//            pickerPopUpView.setIsHidden(true, animated: true)
//            expirationDateOutlet.setTitleColor(.lightGray, for: .normal)
//        }
        
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
            if items.isEmpty == false {
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
            if items.isEmpty == false {
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
        if SharedValues.shared.foodStorageID != nil && !items.isEmpty {
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

extension StorageHomeVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
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
                    self.createMessageView(color: .red, text: "Unable to read barcode")
                    picker.dismiss(animated: true, completion: nil)
                    return
                }
            
                picker.dismiss(animated: true, completion: nil)
                guard let barcode = barcodeData.first?.displayValue else {
                    self.createMessageView(color: .red, text: "Barcode not found")
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
                                    self.createMessageView(color: Colors.messageGreen, text: "Added: \(name)")
//                                    #error("need to add the item to the storage here")
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
                                    item.writeToFirestoreForStorage(db: self.db, docID: SharedValues.shared.foodStorageID ?? " ")
                                } else {
                                    self.createMessageView(color: .red, text: "Item not found")
                                }
                                
                            } else {
                                self.createMessageView(color: .red, text: "Barcode '\(barcode)' not found")
                            }
                        } else {
                            self.createMessageView(color: .red, text: "Item not found")
                        }
                        
                        
                    }
                }
                task.resume()
            }
        }
    }
}
