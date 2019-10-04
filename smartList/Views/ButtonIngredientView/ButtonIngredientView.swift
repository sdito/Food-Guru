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
    func haveUserSortItem()
}



class ButtonIngredientView: UIView {
    
    var delegate: ButtonIngredientViewDelegate!
    
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var label: UILabel!
    
    func setUI(ingredient: String) {
        label.text = ingredient
        button.addTarget(self, action: #selector(bAction), for: .touchUpInside)
    }
    
    @objc private func bAction() {
        //print(self.label.text)
        let db = Firestore.firestore()
        let userID = Auth.auth().currentUser?.uid ?? " "
        guard let name = label.text else { return print("Name did not set property from ButtonIngredientView") }
        
        List.getUsersCurrentList(db: db, userID: userID) { (list) in
            //List.addItemToListFromRecipe(db: db, listID: list ?? " ", name: name, userID: userID)
            if let list = list {
                if list.stores?.isEmpty == true && list.categories?.isEmpty == true {
                    List.addItemToListFromRecipe(db: db, listID: list.ownID ?? " ", name: name, userID: userID)
                } else {
                    print("stores and or categories is not empty, have picker view")
                    self.delegate.haveUserSortItem()
                    
                }
            } else {
                let alert = UIAlertController(title: "Error", message: "You first need to create a list before you can add items.", preferredStyle: .alert)
                alert.addAction(.init(title: "Ok", style: .default, handler: nil))
                UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true)
            }
        }
        // need to add this item to the most current list
        
        // first from List, get the current list
        // from that list, then just add the item
    }
    
}


