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
    private var keyboardHeight: CGFloat?
    private var delegate: SearchAssistantDelegate!
    private var textAssistantViewActive = false
    var db: Firestore!
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
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var switchOutlet: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        nameTextField.delegate = self
        nameTextField.becomeFirstResponder()
        nameTextField.setUpDoneToolbar(action: #selector(doneAction), style: .done)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            keyboardHeight = keyboardRectangle.height
        }
    }
    
    @IBAction func switchAction(_ sender: Any) {
        switch switchOutlet.isOn {
        case true:
            datePicker.isHidden = false
        case false:
            datePicker.isHidden = true
        }
    }
    
    @IBAction func textDidChange(_ sender: Any) {
        print(nameTextField.text!)
        if textAssistantViewActive == false {
            let vc = storyboard?.instantiateViewController(withIdentifier: "createNewItemVC") as! CreateNewItemVC
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
            String(sStr)
        }
        let genericItem = Search.turnIntoSystemItem(string: text)
        let category = GenericItem.getCategory(item: genericItem, words: words)
        
        let item = Item(name: text, selected: false, category: "none", store: "none", user: Auth.auth().currentUser?.uid, ownID: nil, storageSection: foodCategory, timeAdded: Date().timeIntervalSince1970, timeExpires: timeExpires, systemItem: genericItem, systemCategory: category)
        item.writeToFirestoreForStorage(db: db, docID: SharedValues.shared.foodStorageID ?? " ")
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @objc func doneAction() {
        nameTextField.resignFirstResponder()
    }

}

extension StorageNewItemVC: CreateNewItemDelegate {
    func itemCreated(item: Item) {
        print("Item to add to storage: \(item.name)")
        nameTextField.text = item.name
        textAssistantViewActive = false
    }
}

extension StorageNewItemVC: UITextFieldDelegate {}
