//
//  EditItemInfoView.swift
//  smartList
//
//  Created by Steven Dito on 12/23/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import UIKit
import FirebaseFirestore

class EditItemInfoView: UIView {
    private var item: Item?
    private var allCategories = Category.allCases.map({$0.textDescription})
    private var stores: [String] = []
    private var listID: String?
    var db: Firestore!
    var forCategory: Bool = false
    var forStore: Bool = false
    
    override func awakeFromNib() {
        pickerView.delegate = self
        pickerView.dataSource = self
        db = Firestore.firestore()
    }
    
    @IBOutlet weak var header: UILabel!
    @IBOutlet weak var pickerView: UIPickerView!
    
    
    func setUI(forCategory: Bool, stores: [String]?, item: Item, listID: String?) {
        self.forCategory = forCategory
        self.forStore = !forCategory
        self.listID = listID
        self.item = item
        if forCategory == true {
            header.text = "Choose new category"
        } else {
            if let s = stores {
                self.stores = s
            }
            header.text = "Choose new store"
        }
    }
    
    // MARK: @IBAction funcs
    @IBAction func donePressed(_ sender: Any) {
        if forCategory == true {
//            #error("need to get this to the enum text representation")
            
            let t = Category.allCases.map({$0.rawValue})
            let title = t[pickerView.selectedRow(inComponent: 0)]
            if let itemID = item?.ownID, let listID = listID {
                Item.updateItemForListCategory(category: title, itemID: itemID, listID: listID, db: db)
            }
            
        } else {
            let title = stores[pickerView.selectedRow(inComponent: 0)]
            if let itemID = item?.ownID, let listID = listID {
                Item.updateItemForListStore(store: title, itemID: itemID, listID: listID, db: db)
            }
            
        }
        self.findViewController()?.dismiss(animated: false, completion: nil)
    }
    
    
}


// MARK: Picker view
extension EditItemInfoView: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if forStore == true {
            return stores.count
        } else {
            return allCategories.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if forStore == true {
            return stores[row]
        } else {
            return allCategories[row]
        }
    }
}
