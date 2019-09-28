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
    }
    
    @IBAction func switchAction(_ sender: Any) {
        switch switchOutlet.isOn {
        case true:
            datePicker.isHidden = false
        case false:
            datePicker.isHidden = true
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
        print(foodCategory)
        let item = Item(name: nameTextField.text ?? "Item", selected: false, category: "none", store: "none", user: Auth.auth().currentUser?.uid, ownID: nil, storageSection: foodCategory, timeAdded: Date().timeIntervalSince1970, timeExpires: timeExpires)
        item.writeToFirestoreForStorage(db: db, docID: SharedValues.shared.foodStorageID ?? " ")
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @objc func doneAction() {
        nameTextField.resignFirstResponder()
    }

}

extension StorageNewItemVC: UITextFieldDelegate {}
