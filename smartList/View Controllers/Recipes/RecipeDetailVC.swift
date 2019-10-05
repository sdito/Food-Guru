//
//  RecipeDetailVC.swift
//  smartList
//
//  Created by Steven Dito on 9/29/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth



class RecipeDetailVC: UIViewController {
    var db: Firestore!
    
    @IBOutlet weak var addAllToListOutlet: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var recipeName: UILabel!
    @IBOutlet weak var nameAndTitleView: UIView!
    @IBOutlet weak var author: UILabel!
    @IBOutlet weak var tagline: UILabel!
    @IBOutlet weak var prepTime: UILabel!
    @IBOutlet weak var cookTime: UILabel!
    @IBOutlet weak var servings: UILabel!
    @IBOutlet weak var calories: UILabel!
    @IBOutlet weak var ingredientsStackView: UIStackView!
    @IBOutlet weak var instructionsStackView: UIStackView!
    @IBOutlet weak var notes: UILabel!

    var data: (image: UIImage, recipe: Recipe)?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        //set the image twice so that there will be something there while the better quality picture is loading, rather than a loading circle
        if let data = data {
            setUI(recipe: data.recipe, image: data.image)
        }
        data?.recipe.getImageFromStorage(thumb: false, imageReturned: { (img) in
            self.imageView.image = img
        })
        addAllToListOutlet.isUserInteractionEnabled = true
        createObserver()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func addAllToList(_ sender: Any) {
        print("Add all items to list")
        let uid = Auth.auth().currentUser?.uid ?? " "
        List.getUsersCurrentList(db: db, userID: uid) { (list) in
            if let list = list {
                if list.stores?.isEmpty == true && list.categories?.isEmpty == true {
                    for item in (self.data?.recipe.ingredients)! {
                        List.addItemToListFromRecipe(db: self.db, listID: list.ownID ?? " ", name: item, userID: uid, category: "", store: "")
                    }
                } else {
                    self.createPickerView(itemNames: self.data?.recipe.ingredients ?? [""], itemStores: list.stores, itemCategories: list.categories, itemListID: list.ownID ?? " ", singleItem: false, delegateVC: self)
                }
            } else {
                let alert = UIAlertController(title: "Error", message: "You first need to create a list before you can add items.", preferredStyle: .alert)
                alert.addAction(.init(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true)
                
            }
        }
    }
    
    private func setUI(recipe: Recipe, image: UIImage) {
        imageView.image = data?.image
        recipeName.text = recipe.name
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.nameAndTitleView.shadowAndRounded()
        }
        nameAndTitleView.alpha = 0.95
        tagline.text = recipe.tagline
        prepTime.text = "\(recipe.prepTime) m"
        cookTime.text = "\(recipe.cookTime) m"
        servings.text = "\(recipe.numServes)"
        calories.text = "\(recipe.calories!)"
        if let n = recipe.notes {
            notes.text = "Notes: \(n)"
        }
        if let uid = recipe.userID {
            User.getNameFromUid(db: db, uid: uid) { (name) in
                self.author.text = "By \(name ?? "unknown user")"
            }
        }
        recipe.addButtonIngredientViewsTo(stackView: ingredientsStackView, delegateVC: self)
        recipe.addInstructionsToInstructionStackView(stackView: instructionsStackView)
        
    }
    
    private func createObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(itemAddedSelector), name: .itemAddedFromRecipe, object: nil)
    }
    @objc func itemAddedSelector(_ notification: NSNotification) {
        if let dict = notification.userInfo as NSDictionary? {
            if let name = dict["itemName"] as? String {
                print("Name of the item: \(name)")
                for item in ingredientsStackView.subviews {
                    if type(of: item) == ButtonIngredientView.self {
                        let txt = (item as! ButtonIngredientView).label.text
                        if txt == name {
                            let itm = (item as! ButtonIngredientView)
                            if #available(iOS 13.0, *) {
                                itm.button.setImage(.strokedCheckmark, for: .normal)
                                itm.label.textColor = .systemGreen
                                itm.button.tintColor = .systemGreen
                                itm.button.isUserInteractionEnabled = false
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                    itm.label.textColor = .secondaryLabel
                                }
                            } else {
                                itm.label.textColor = .systemGreen
                                itm.button.tintColor = .systemGreen
                                itm.button.isUserInteractionEnabled = false
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                    itm.label.textColor = .lightGray
                                }
                            }
                        }
                    }
                }
            }
        }
    }

}

extension RecipeDetailVC: ButtonIngredientViewDelegate {
    func haveUserSortItem(addedItemName: [String], addedItemStores: [String]?, addedItemCategories: [String]?, addedItemListID: String) {
        print("picker view added here")
        self.createPickerView(itemNames: addedItemName, itemStores: addedItemStores, itemCategories: addedItemCategories, itemListID: addedItemListID, singleItem: true, delegateVC: self)
    }
}


extension RecipeDetailVC: DisableAddAllItemsDelegate {
    func disableButton() {
        addAllToListOutlet.removeFromSuperview()
        #error("need to do this for simple lists too, and then fix the issue where if the user stops half way through of adding the items")
    }
    
}
