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
    private var itemsAddedToList: Set<String>? = [""]
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var reviewRecipeOutlet: UIButton!
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
    @IBOutlet weak var reviewsStackView: UIStackView!
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
        //addAllToListOutlet.isUserInteractionEnabled = true
        createObserver()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    #warning("have a semi small not important bug, if user adds items one by one then adds all items to the list, the items that were added one by one will be added twice")
    @IBAction func addAllToList(_ sender: Any) {
        print("Add all items to list")
        let uid = Auth.auth().currentUser?.uid ?? " "
        List.getUsersCurrentList(db: db, userID: uid) { (list) in
            if let list = list {
                if list.stores?.isEmpty == true && list.categories?.isEmpty == true {
                    for item in (self.data?.recipe.ingredients)! {
                        List.addItemToListFromRecipe(db: self.db, listID: list.ownID ?? " ", name: item, userID: uid, category: "", store: "")
                    }
                    self.removeAddAllButton()
                } else {
                    var allItems = self.data?.recipe.ingredients ?? [""]
                    print(allItems)
                    allItems = allItems.filter({self.itemsAddedToList?.contains($0) == false})
                    print(allItems)
                    self.createPickerView(itemNames: allItems, itemStores: list.stores, itemCategories: list.categories, itemListID: list.ownID ?? " ", singleItem: false, delegateVC: self)
                }
            } else {
                let alert = UIAlertController(title: "Error", message: "You first need to create a list before you can add items.", preferredStyle: .alert)
                alert.addAction(.init(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true)
                
            }
        }
    }
    
    @IBAction func reviewRecipe(_ sender: Any) {
        self.createRatingView(delegateVC: self)
    }
    private func setUI(recipe: Recipe, image: UIImage) {
        imageView.image = data?.image
        recipeName.text = recipe.name
        addStarRatingViewIfApplicable(recipe: recipe)
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
        
        
        //#error("the recipe view header is not drawing properly if there are no reviews")
        Review.getReviewsFrom(recipe: recipe, db: db) { (rvws) in
            Review.getViewsFrom(reviews: rvws).forEach { (view) in
                self.reviewsStackView.insertArrangedSubview(view, at: 1)
            }
        }
        
    }
    private func addStarRatingViewIfApplicable(recipe: Recipe) {
        if let nr = recipe.numReviews, let ns = recipe.numStars {
            print("got to this point")
            let v = Bundle.main.loadNibNamed("StarRatingView", owner: nil, options: nil)?.first as! StarRatingView
            v.setUI(rating: Double(ns)/Double(nr), nReviews: nr)
            let sv = UIStackView()
            let view = UIView()
            view.backgroundColor = .clear
            view.translatesAutoresizingMaskIntoConstraints = false
            view.widthAnchor.constraint(equalToConstant: 10.0).isActive = true
            //view.heightAnchor.constraint(equalToConstant: v.frame.height).isActive = true
            sv.insertArrangedSubview(view, at: 0)
            sv.insertArrangedSubview(v, at: 1)
            mainStackView.insertArrangedSubview(sv, at: 2)
            let gr = UITapGestureRecognizer(target: self, action: #selector(ratingTapSelector))
            sv.addGestureRecognizer(gr)
            
        }
    }
    @objc private func ratingTapSelector() {
        let location = reviewsStackView.frame.minY
        scrollView.setContentOffset(CGPoint(x: 0, y: location), animated: true)
    }
    private func createObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(itemAddedSelector), name: .itemAddedFromRecipe, object: nil)
    }
    private func removeAddAllButton() {
        addAllToListOutlet.alpha = 0.4
        addAllToListOutlet.setTitleColor(.black, for: .normal)
        addAllToListOutlet.setTitle("✓ Add all to list", for: .normal)
        addAllToListOutlet.isUserInteractionEnabled = false
    }
    @objc func itemAddedSelector(_ notification: NSNotification) {
        if let dict = notification.userInfo as NSDictionary? {
            if let name = dict["itemName"] as? String {
                print("Name of the item: \(name)")
                itemsAddedToList?.insert(name)
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
        removeAddAllButton()
    }
    
}

extension RecipeDetailVC: GiveRatingViewDelegate {
    func publishRating(stars: Int, rating: String?) {
        reviewRecipeOutlet.isUserInteractionEnabled = false
        reviewRecipeOutlet.alpha = 0.4
        reviewRecipeOutlet.setTitleColor(.black, for: .normal)
        reviewRecipeOutlet.setTitle("✓ Review the recipe", for: .normal)
        let recipeID = data?.recipe.imagePath?.imagePathToDocID()
        
        let reference = db.collection("recipes").document(recipeID ?? " ").collection("reviews")
        reference.whereField("user", isEqualTo: Auth.auth().currentUser?.uid ?? " ").getDocuments { (querySnapshot, error) in
            if (querySnapshot?.documents.count) == nil || querySnapshot?.documents.count == 0 {
                self.data?.recipe.addReviewToRecipe(stars: stars, review: rating, db: self.db)
                self.dismiss(animated: false) {
                    self.createMessageView(color: Colors.messageGreen, text: "Review successfully written")
                }
            } else {
                if let doc = querySnapshot?.documents.first {
                    let starsToDelete = doc.get("stars") as? Int
                    if self.data?.recipe.numStars != nil && self.data?.recipe.numReviews != nil {
                        self.data?.recipe.numStars! -= starsToDelete ?? 0
                        self.data?.recipe.numReviews! -= 1
                    }
                    querySnapshot?.documents.first?.reference.delete()
                    
                    self.data?.recipe.addReviewToRecipe(stars: stars, review: rating, db: self.db)
                    self.dismiss(animated: false) {
                        self.createMessageView(color: Colors.messageGreen, text: "Wrote over your previous review")
                    }
                }
                
            }
        }
    }
}

