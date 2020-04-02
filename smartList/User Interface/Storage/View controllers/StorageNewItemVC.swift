//
//  StorageNewItemVC.swift
//  smartList
//
//  Created by Steven Dito on 9/22/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class StorageNewItemVC: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var switchOutlet: UISwitch!
    
    var db: Firestore!
    
    var foodStorage: FoodStorage?
    private var newItemVC: CreateNewItemVC?
    private var keyboardHeight: CGFloat?
    private var delegate: SearchAssistantDelegate!
    private var textAssistantViewActive = false
    private var foodCategory: FoodStorageType {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            return .fridge
        case 1:
            return .freezer
        case 2:
            return .pantry
        default:
            return .unsorted
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        nameTextField.delegate = self
        nameTextField.becomeFirstResponder()
        nameTextField.setUpDoneToolbar(action: #selector(doneAction), style: .done)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
    }
    
    // MARK: @IBAction funcs
    @IBAction func switchAction(_ sender: Any) {
        switch switchOutlet.isOn {
        case true:
            datePicker.isHidden = false
        case false:
            datePicker.isHidden = true
        }
    }
    
    @IBAction func textDidChange(_ sender: Any) {
        if textAssistantViewActive == false {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "createNewItemVC") as! CreateNewItemVC
            self.newItemVC = vc
            vc.isForList = false
            if let itms = foodStorage?.items {
                vc.itemsFromList = itms.map({$0.name})
            }
        
            self.addChild(vc)
            self.view.addSubview(vc.tableView)
            vc.didMove(toParent: self)
            vc.tableView.translatesAutoresizingMaskIntoConstraints = false
            vc.tableView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
            
            let distance = (view.frame.height) - (keyboardHeight ?? 0.0) - 50.0 - (nameTextField.frame.height)
            vc.tableView.heightAnchor.constraint(equalToConstant: distance).isActive = true
            vc.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
            vc.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
            vc.delegate = self as CreateNewItemDelegate
            delegate = vc
            
            delegate.searchTextChanged(text: nameTextField.text!)
            textAssistantViewActive = true
        } else {
            delegate.searchTextChanged(text: nameTextField.text!)
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func itemCreated(_ sender: Any) {
        var timeExpires: TimeInterval? {
            if switchOutlet.isOn {
                return datePicker.date.timeIntervalSince1970
            } else {
                return nil
            }
        }
        
        let text = nameTextField.text ?? ""
        let words = text.split{ !$0.isLetter }.map { (sStr) -> String in
            String(sStr.lowercased())
        }
        let genericItem = Search.turnIntoSystemItem(string: text)
        let category = GenericItem.getCategory(item: genericItem, words: words)
        
        let item = Item(name: text, selected: false, category: "none", store: "none", user: Auth.auth().currentUser?.uid, ownID: nil, storageSection: foodCategory, timeAdded: Date().timeIntervalSince1970, timeExpires: timeExpires, systemItem: genericItem, systemCategory: category, quantity: nil)
        item.writeToFirestoreForStorage(db: db, docID: SharedValues.shared.foodStorageID ?? " ")
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: functions
    @objc private func doneAction() {
        nameTextField.text = ""
        delegate.searchTextChanged(text: "")
        nameTextField.resignFirstResponder()
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            keyboardHeight = keyboardRectangle.height
        }
    }
    
}
// MARK: CreateNewItemDelegate
extension StorageNewItemVC: CreateNewItemDelegate {
    func itemCreated(item: Item) {
        print("Item to add to storage: \(item.name)")
        nameTextField.text = item.name
        textAssistantViewActive = false
        
        if let itemType = item.systemItem {
            let expiration = GenericItem.getSuggestedExpirationDate(item: itemType, storageType: foodCategory)
            datePicker.date = Date(timeIntervalSince1970: Date().timeIntervalSince1970 + Double(expiration))
        }
        print("could set the suggested expiration date here")
        
    }
}

extension StorageNewItemVC: UITextFieldDelegate {}
