//
//  SortItemView.swift
//  smartList
//
//  Created by Steven Dito on 10/4/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth


protocol DisableAddAllItemsDelegate {
    func disableButton()
}


class SortItemView: UIView {
    var delegate: DisableAddAllItemsDelegate!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var multipleItemStackView: UIStackView!
    lazy private var uid = Auth.auth().currentUser?.uid ?? " "
    private var items: [String]? {
        didSet {
            if self.items?.count == 1 {
                doneButton.setTitle("Done", for: .normal)
            }
            
        }
    }
    
    private var listID: String?
    private var name: String? {
        didSet {
            nameLabel.text = "Sort \(name ?? "item") for list"
        }
    }
    
    private var stores: [String]?
    private var categories: [String]?
    // MARK: functions
    func setUIoneItem(name: String, stores: [String]?, listID: String) {
        pickerView.delegate = self
        pickerView.dataSource = self
        self.listID = listID
        self.stores = stores
        self.name = name
        doneButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        multipleItemStackView.subviews.forEach({$0.removeFromSuperview()})
    }
    
    func setUIallItems(items: [String], stores: [String]?, listID: String) {
        pickerView.delegate = self
        pickerView.dataSource = self
        multipleItemStackView.subviews.forEach({$0.removeFromSuperview()})
        self.listID = listID
        self.stores = stores
        self.name = items.first
        self.items = items
        doneButton.setTitle("Next", for: .normal)
        for item in items {
            let label = UILabel()
            label.text = item
            label.font = UIFont(name: "futura", size: 13)
            if #available(iOS 13.0, *) {
                label.textColor = .label
            } else {
                label.textColor = .black
            }
            if multipleItemStackView.subviews.isEmpty == true {
                label.alpha = 1.0
            } else {
                label.alpha = 0.4
            }
            multipleItemStackView.insertArrangedSubview(label, at: multipleItemStackView.subviews.count)
        }
        doneButton.addTarget(self, action: #selector(nextButtonAction), for: .touchUpInside)
        nameLabel.text = "Sort \(items.first ?? "item") for list"
    }
    
}
// MARK: Picker view
extension SortItemView: UIPickerViewDelegate, UIPickerViewDataSource {
    @objc func buttonAction() {
        let storesIndex = pickerView.selectedRow(inComponent: 0)
        
        GroceryList.addItemToListFromRecipe(db: Firestore.firestore(), listID: listID ?? " ", name: name ?? " ", userID: Auth.auth().currentUser?.uid ?? " ", store: stores?[storesIndex] ?? "")
        let vc = self.findViewController()
        vc?.dismiss(animated: true, completion: nil)
    }
    
    @objc func nextButtonAction() {
        let storesIndex = pickerView.selectedRow(inComponent: 0)
        switch items?.count {
        case 0:
            return
        case 1:
            print("Exit this pop up view and finish adding items")
            GroceryList.addItemToListFromRecipe(db: Firestore.firestore(), listID: listID ?? " ", name: items?.first ?? "Item", userID: uid, store: stores?[storesIndex] ?? "")
            let vc = self.findViewController()
            vc?.dismiss(animated: true, completion: nil)
            // do not let add all items to list be pressed again
            delegate.disableButton()
        default:
            GroceryList.addItemToListFromRecipe(db: Firestore.firestore(), listID: listID ?? " ", name: items?.first ?? "Item", userID: uid, store: stores?[storesIndex] ?? "")
            multipleItemStackView.subviews.first?.removeFromSuperview()
            multipleItemStackView.subviews.first?.alpha = 1.0
            items?.removeFirst()
            name = items?.first
        }
    }
    
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return stores?.count ?? 1
        
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return stores?[row]
    }
    
}
