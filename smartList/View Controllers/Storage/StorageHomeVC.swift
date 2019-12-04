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


class StorageHomeVC: UIViewController {
    //var delegate: IngredientsFromStorageDelegate!
    private var indexes: [Int]? {
        return tableView.indexPathsForSelectedRows?.map({$0.row})
    }
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
    
    var items: [Item] = [] {
        didSet {
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
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
        present(vc, animated: true, completion: nil)
        
    }
    
    @IBAction func barcodeScanPressed(_ sender: Any) {
        print("barcode scanner pressed")
        // not gonna work on the simulator
        let cameraPicker = UIImagePickerController()
        cameraPicker.sourceType = .camera
        cameraPicker.cameraCaptureMode = .photo
        cameraPicker.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
        present(cameraPicker, animated: true, completion: nil)
        
        
        
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
        print("find recipes with selected ingredients")
        let genericItems = sortedItems.filter{(indexes?.contains(sortedItems.firstIndex(of: $0)!) ?? false)}.map({$0.systemItem!.rawValue})
        for _ in 1...100 {
            print(genericItems)
        }
        Search.getRecipesFromIngredients(db: db, ingredients: genericItems) { (rcps) in
            if let rcps = rcps {
                SharedValues.shared.sentRecipesInfo = (rcps, genericItems)
                self.tabBarController?.selectedIndex = 1
                
                
                // to make sure that the recipe home page is visible when sent over there
                (self.tabBarController!.selectedViewController! as? UINavigationController)?.popToRootViewController(animated: true)
            }
        }
        
    }
    
    
    @IBAction func deleteCells(_ sender: Any) {
        //let indexes = tableView.indexPathsForSelectedRows?.map({$0.row})
        for item in sortedItems {
            if let idx = sortedItems.firstIndex(of: item) {
                if indexes?.contains(idx) ?? false {
                    item.deleteItemFromStorage(db: db, storageID: SharedValues.shared.foodStorageID ?? " ")
                }
            }
        }
    }
    @IBAction func addExpirationDateCells(_ sender: Any) {
        if pickerPopUpView.isHidden {
            pickerPopUpView.setIsHidden(false, animated: true)
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
        let indexes = tableView.indexPathsForSelectedRows?.map({$0.row})
        for item in sortedItems {
            if let idx = sortedItems.firstIndex(of: item) {
                if indexes?.contains(idx) ?? false {
                    item.addExpirationDateToItem(db: db, timeIntervalSince1970: pickerView.date.timeIntervalSince1970)
                }
            }
        }
        
    }
    
    private func handleCellSortingTo(segment: String) {
        let indexes = tableView.indexPathsForSelectedRows?.map({$0.row})
        for item in sortedItems {
            if let idx = sortedItems.firstIndex(of: item) {
                if indexes?.contains(idx) ?? false {
                    item.switchItemToSegment(named: segment, db: db/*, storageID: SharedValues.shared.foodStorageID ?? " "*/)
                }
            }
        }
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
        if tableView.indexPathsForSelectedRows?.count ?? 0 >= 1 {
            popUpView.setIsHidden(false, animated: true)
        } else {
            popUpView.setIsHidden(true, animated: true)
            pickerPopUpView.setIsHidden(true, animated: true)
            expirationDateOutlet.setTitleColor(.lightGray, for: .normal)
        }
    }
    func createEmptyStorageCells() -> [UITableViewCell] {
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
                cell.setUI(str: "Your storage is empty. To add and keep track of your items, select done after you are done using one of your lists or manually add the items.")
                return cell
            }
        } else {
            return emptyCells[indexPath.row]
        }
        
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        handlePopUpView()
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        handlePopUpView()
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
                    for _ in 1...100 {
                        print("Error retrieving data: \(String(describing: error))")
                    }
                    picker.dismiss(animated: true, completion: nil)
                    return
                }
            
                picker.dismiss(animated: true, completion: nil)
                
                let alert = UIAlertController(title: "Barcode returned", message: barcodeData.first?.displayValue, preferredStyle: .alert)
                alert.addAction(.init(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true)
                
                #warning("use the API here")
                
            }
        }
    }
}
