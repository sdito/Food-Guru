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

class SortItemView: UIView {
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    
    private var listID: String?
    private var name: String?
    
    private var stores: [String]?
    private var categories: [String]?
    
    func setUI(name: String, stores: [String]?, categories: [String]?, listID: String) {
        pickerView.delegate = self
        pickerView.dataSource = self
        self.listID = listID
        nameLabel.text = "Sort \(name) for list"
        self.stores = stores
        self.categories = categories
        self.name = name
        doneButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        
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
