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
    
    func setUIoneItem(name: String, stores: [String]?, categories: [String]?, listID: String) {
        pickerView.delegate = self
        pickerView.dataSource = self
        self.listID = listID
        self.stores = stores
        self.categories = categories
        self.name = name
        doneButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        multipleItemStackView.subviews.forEach({$0.removeFromSuperview()})
    }
    
    func setUIallItems(items: [String], stores: [String]?, cateogires: [String]?, listID: String) {
        pickerView.delegate = self
        pickerView.dataSource = self
        multipleItemStackView.subviews.forEach({$0.removeFromSuperview()})
        self.listID = listID
        self.stores = stores
        self.categories = cateogires
        self.name = items.first
        self.items = items
        doneButton.setTitle("Next", for: .normal)
        for item in items {
            let label = UILabel()
            label.text = item
            label.font = UIFont(name: "futura", size: 13)
            label.textColor = .black
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

extension SortItemView: UIPickerViewDelegate, UIPickerViewDataSource {
    @objc func buttonAction() {
        let storesIndex = pickerView.selectedRow(inComponent: 0)
        let categoriesIndex = pickerView.selectedRow(inComponent: 1)
        
        List.addItemToListFromRecipe(db: Firestore.firestore(), listID: listID ?? " ", name: name ?? " ", userID: Auth.auth().currentUser?.uid ?? " ", category: categories?[categoriesIndex] ?? "", store: stores?[storesIndex] ?? "")
        let vc = self.findViewController()
        vc?.dismiss(animated: true, completion: nil)
    }
    
    @objc func nextButtonAction() {
        let storesIndex = pickerView.selectedRow(inComponent: 0)
        let categoriesIndex = pickerView.selectedRow(inComponent: 1)
        switch items?.count {
        case 0:
            return
        case 1:
            print("Exit this pop up view and finish adding items")
            List.addItemToListFromRecipe(db: Firestore.firestore(), listID: listID ?? " ", name: items?.first ?? "Item", userID: uid, category: categories?[categoriesIndex] ?? "", store: stores?[storesIndex] ?? "")
            let vc = self.findViewController()
            vc?.dismiss(animated: true, completion: nil)
            // do not let add all items to list be pressed again
            delegate.disableButton()
        default:
            List.addItemToListFromRecipe(db: Firestore.firestore(), listID: listID ?? " ", name: items?.first ?? "Item", userID: uid, category: categories?[categoriesIndex] ?? "", store: stores?[storesIndex] ?? "")
            multipleItemStackView.subviews.first?.removeFromSuperview()
            multipleItemStackView.subviews.first?.alpha = 1.0
            items?.removeFirst()
            name = items?.first
        }
    }
    
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return stores?.count ?? 1
        default:
            return categories?.count ?? 1
        }
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            return stores?[row]
        default:
            return categories?[row]
        }
    }
    
}
