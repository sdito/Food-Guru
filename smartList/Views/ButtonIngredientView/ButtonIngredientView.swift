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

class ButtonIngredientView: UIView {
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
            List.addItemToListFromRecipe(db: db, listID: list ?? " ", name: name, userID: userID)
        }
        // need to add this item to the most current list
        
        // first from List, get the current list
        // from that list, then just add the item
    }
    
}
