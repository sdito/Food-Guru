//
//  ButtonIngredientView.swift
//  smartList
//
//  Created by Steven Dito on 9/30/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth



protocol ButtonIngredientViewDelegate {
    func haveUserSortItem(addedItemName: [String], addedItemStores: [String]?, addedItemListID: String)
}



class ButtonIngredientView: UIView {
    
    var delegate: ButtonIngredientViewDelegate!
    
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        let gestureRecognizer = UITapGestureRecognizer()
        gestureRecognizer.addTarget(self, action: #selector(bAction))
        self.addGestureRecognizer(gestureRecognizer)
    }
    
    func setUI(ingredient: String) {
        label.text = ingredient
        button.addTarget(self, action: #selector(bAction), for: .touchUpInside)
        let systemIngredient = "\(Search.turnIntoSystemItem(string: ingredient))"
        if SharedValues.shared.currentItemsInStorage?.contains(systemIngredient) ?? false {
            label.textColor = .systemGreen
        }
    }
    
    @objc private func bAction() {
        print("CALLED")
        let db = Firestore.firestore()
        let userID = Auth.auth().currentUser?.uid ?? " "
        guard let name = label.text else { return print("Name did not set property from ButtonIngredientView") }
        
        GroceryList.getUsersCurrentList(db: db, userID: userID) { (list) in
            if let list = list {
                if list.stores?.isEmpty == true {
                    GroceryList.addItemToListFromRecipe(db: db, listID: list.ownID ?? " ", name: name, userID: userID, store: "")
                } else if list.stores?.count == 1 {
                    GroceryList.addItemToListFromRecipe(db: db, listID: list.ownID ?? " ", name: name, userID: userID, store: list.stores!.first!)
                } else {
                    print("stores is not empty, have picker view for user to decide")
                    self.delegate.haveUserSortItem(addedItemName: [name], addedItemStores: list.stores, addedItemListID: list.ownID ?? " ")
                }
            } else {
                // To create and add the item to a list if the user does not currently have a list
                GroceryList.handleProcessForAutomaticallyGeneratedListFromRecipe(db: db, items: [name])
                self.findViewController()?.createMessageView(color: Colors.messageGreen, text: "List created and item added!")
                
            }
        }
    }
    
}


