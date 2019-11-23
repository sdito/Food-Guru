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
    @IBOutlet weak var wholeSV: UIStackView!
    
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
    
    @IBOutlet weak var printRecipeOutlet: UIButton!
    @IBOutlet weak var downloadRecipeOutlet: UIButton!
    @IBOutlet weak var saveRecipeOutlet: UIButton!
    
    
    @IBOutlet weak var optionalInfoStackView: UIStackView!
    @IBOutlet weak var prepSV: UIStackView!
    @IBOutlet weak var cookSV: UIStackView!
    @IBOutlet weak var servingsSV: UIStackView!
    @IBOutlet weak var caloriesSV: UIStackView!
    
    @IBOutlet var viewsToRemoveForCookbook: [UIView]!
    
    
    var data: (image: UIImage, recipe: Recipe)?
    var cookbookRecipe: CookbookRecipe?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        //set the image twice so that there will be something there while the better quality picture is loading, rather than a loading circle
        if let data = data {
            setUI(recipe: data.recipe, image: data.image)
        } else if let cookbook = cookbookRecipe {
            setUI(recipe: cookbook)
        }
        data?.recipe.getImageFromStorage(thumb: false, imageReturned: { (img) in
            self.imageView.image = img
        })
        //addAllToListOutlet.isUserInteractionEnabled = true
        createObserver()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var pdfData: String {
            if data?.recipe != nil {
                return data!.recipe.name
            } else {
                return cookbookRecipe?.name ?? ""
            }
        }
        var ingredients: [String] {
            if data?.recipe != nil {
                return data!.recipe.ingredients
            } else {
                return Array(cookbookRecipe!.ingredients)
            }
        }
        var instructions: [String] {
            if data?.recipe != nil {
                return data!.recipe.instructions
            } else {
                return Array(cookbookRecipe!.instructions)
            }
        }
        if segue.identifier == "viewPDV" {
            guard let vc = segue.destination as? RecipePDFVC else { return }
            let pdfCreator = PDFCreator(title: pdfData, ingredients: ingredients, instructions: instructions)
            vc.documentData = pdfCreator.createPDF()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    #warning("have a semi small not important bug, if user adds items one by one then adds all items to the list, the items that were added one by one will be added twice")
    @IBAction func addAllToList(_ sender: Any) {
        print("Add all items to list")        
        let uid = Auth.auth().currentUser?.uid ?? " "
        GroceryList.getUsersCurrentList(db: db, userID: uid) { (list) in
            if let list = list {
                if list.stores?.isEmpty == true {
                    for item in (self.data?.recipe.ingredients)! {
                        
                        GroceryList.addItemToListFromRecipe(db: self.db, listID: list.ownID ?? " ", name: item, userID: uid, store: "")
                    }
                    self.removeAddAllButton()
                } else {
                    var allItems = self.data?.recipe.ingredients ?? [""]
                    print(allItems)
                    allItems = allItems.filter({self.itemsAddedToList?.contains($0) == false})
                    print(allItems)
                    self.createPickerView(itemNames: allItems, itemStores: list.stores, itemListID: list.ownID ?? " ", singleItem: false, delegateVC: self)
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
    
    
    
    
    @IBAction func downloadRecipe(_ sender: Any) {
        print("Download recipe")
        
        let cbr = data?.recipe.turnRecipeIntoCookbookRecipe()
        cbr?.write()
        self.createMessageView(color: Colors.messageGreen, text: "Recipe added to cookbook")
        downloadRecipeOutlet.isUserInteractionEnabled = false
        downloadRecipeOutlet.alpha = 0.5
        downloadRecipeOutlet.setTitle("✓ Download", for: .normal)
        
    }
    @IBAction func saveRecipe(_ sender: Any) {
        print("Save recipe")
        if let recipe = data?.recipe {
            let db = Firestore.firestore()
            let path = recipe.imagePath ?? " "
            if SharedValues.shared.savedRecipes?.contains(path ) ?? false {
                Recipe.removeRecipeFromSavedRecipes(db: db, str: path)
                recipe.removeRecipeDocumentFromUserProfile(db: db)
            } else {
                Recipe.addRecipeToSavedRecipes(db: db, str: path)
                recipe.addRecipeDocumentToUserProfile(db: db)
                self.createMessageView(color: Colors.messageGreen, text: "Recipe saved")
            }
        }
        
        saveRecipeOutlet.isUserInteractionEnabled = false
        saveRecipeOutlet.alpha = 0.5
        saveRecipeOutlet.setTitle("✓ Save", for: .normal)
        
    }
    
    private func setUI(recipe: CookbookRecipe) {
        viewsToRemoveForCookbook.forEach { (v) in
            v.removeFromSuperview()
        }
        
        
        self.title = recipe.name
        
        let v = UIView()
        v.heightAnchor.constraint(equalToConstant: 10).isActive = true
        //wholeSV.insertArrangedSubview(label, at: 0)
        wholeSV.insertArrangedSubview(v, at: 0)
        
        
        
        recipe.addButtonIngredientViewsTo(stackView: ingredientsStackView, delegateVC: self)
        recipe.addInstructionsToInstructionStackView(stackView: instructionsStackView)
        
        
        if let ct = recipe.cookTime.value {
            cookTime.text = "\(ct) m"
        } else {
            cookSV.removeFromSuperview()
        }
        
        if let pt = recipe.prepTime.value {
            prepTime.text = "\(pt) m"
        } else {
            prepSV.removeFromSuperview()
        }
        
        if let s = recipe.servings.value {
            servings.text = "\(s)"
        } else {
            servingsSV.removeFromSuperview()
        }
        
        if let c = recipe.calories.value {
            calories.text = "\(c)"
        } else {
            caloriesSV.removeFromSuperview()
        }
        
        if optionalInfoStackView.subviews.count == 0 {
            optionalInfoStackView.removeFromSuperview()
        }
        
        if let n = recipe.notes {
            if n != "" {
                notes.text = "Notes: \(n)"
            } else {
                notes.removeFromSuperview()
            }
        } else {
            notes.removeFromSuperview()
        }
        
    }
    
    private func setUI(recipe: Recipe, image: UIImage) {
        imageView.image = data?.image
        recipeName.text = recipe.name
        addStarRatingViewIfApplicable(recipe: recipe)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.nameAndTitleView.shadowAndRounded(cornerRadius: 25.0, border: true)
        }
        nameAndTitleView.alpha = 0.95
        tagline.text = recipe.tagline
        prepTime.text = "\(recipe.prepTime) m"
        cookTime.text = "\(recipe.cookTime) m"
        servings.text = "\(recipe.numServes)"
        calories.text = "\(recipe.calories!)"
        if let n = recipe.notes {
            if n != "" {
                notes.text = "Notes: \(n)"
            } else {
                notes.removeFromSuperview()
            }
        } else {
            notes.removeFromSuperview()
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
        let path = recipe.imagePath ?? " "
        if SharedValues.shared.savedRecipes?.contains(path ) ?? false {
            saveRecipeOutlet.isUserInteractionEnabled = false
            saveRecipeOutlet.alpha = 0.5
            saveRecipeOutlet.setTitle("✓ Save", for: .normal)
        }
    }
    private func addStarRatingViewIfApplicable(recipe: Recipe) {
        if let nr = recipe.numReviews, let ns = recipe.numStars {
            let v = Bundle.main.loadNibNamed("StarRatingView", owner: nil, options: nil)?.first as! StarRatingView
            v.setUI(rating: Double(ns)/Double(nr), nReviews: nr)
            mainStackView.insertArrangedSubview(v, at: 2)
            let gr = UITapGestureRecognizer(target: self, action: #selector(ratingTapSelector))
            v.addGestureRecognizer(gr)
            
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
    func haveUserSortItem(addedItemName: [String], addedItemStores: [String]?, addedItemListID: String) {
        print("picker view added here")
        self.createPickerView(itemNames: addedItemName, itemStores: addedItemStores, itemListID: addedItemListID, singleItem: true, delegateVC: self)
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

