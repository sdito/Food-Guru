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
import FirebaseStorage
import RealmSwift
import SafariServices

class RecipeDetailVC: UIViewController {
    
    @IBOutlet weak var wholeSV: UIStackView!
    @IBOutlet weak var servingsFromSliderLabel: UILabel!
    @IBOutlet weak var servingSliderNumber: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var mainStackView: UIStackView!
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
    @IBOutlet weak var printRecipeOutlet: UIButton!
    @IBOutlet weak var downloadRecipeOutlet: UIButton!
    @IBOutlet weak var saveRecipeOutlet: UIButton!
    @IBOutlet weak var optionalInfoStackView: UIStackView!
    @IBOutlet weak var prepSV: UIStackView!
    @IBOutlet weak var cookSV: UIStackView!
    @IBOutlet weak var servingsSV: UIStackView!
    @IBOutlet weak var caloriesSV: UIStackView!
    @IBOutlet weak var scaleSV: UIStackView!
    @IBOutlet var      viewsToRemoveForCookbook: [UIView]!
    @IBOutlet weak var scaleSlider: UISlider!
    @IBOutlet weak var imageViewAspect: NSLayoutConstraint!
    @IBOutlet weak var authorButtonOutlet: UIButton!
    
    var db: Firestore!
    var data: (image: UIImage?, recipe: Recipe)?
    var cookbookRecipe: CookbookRecipe?
    private var itemsAddedToList: Set<String>? = [""]
    private var recipeSliderScaleMax = 4
    private var originalIngredients: [String]?
    private var originalServings: Int?
    private var newServingsValue: Int?
    
    // MARK: Override funcs
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        //set the image twice so that there will be something there while the better quality picture is loading, rather than a loading circle
        if let data = data {
            setUI(recipe: data.recipe, image: data.image)
        } else if let cookbook = cookbookRecipe {
            setUI(recipe: cookbook)
        }
        
        
        
        
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
        if segue.identifier == "viewPDF" {
            guard let vc = segue.destination as? RecipePDFVC else { return }
            let pdfCreator = PDFCreator(title: pdfData, ingredients: ingredients, instructions: instructions)
            vc.documentData = pdfCreator.createPDF()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: @IBAction funcs
    
    @IBAction func viewPDF(_ sender: Any) {
        if self.data?.recipe.djangoID == -1 || self.cookbookRecipe != nil {
            performSegue(withIdentifier: "viewPDF", sender: nil)
        } else {
            if let r = data?.recipe.djangoID {
                self.createLoadingView()
                Network.shared.openPDF(recipeID: r) { (docData) in
                    self.dismiss(animated: false, completion: nil)
                    switch docData {
                    case .success(let pdfData):
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "pdfVC") as! RecipePDFVC
                        vc.documentData = pdfData
                        self.navigationController?.pushViewController(vc, animated: true)
                    case .failure(_):
                        self.createMessageView(color: .red, text: "Unable to get PDF")
                    }
                    
                }
            }
            
        }
    }
    
    
    @IBAction func addAllToList(_ sender: Any) {
        var ingredientsToAddToList: [String] {
            if data?.recipe != nil {
                return data!.recipe.ingredients
            } else {
                return Array(cookbookRecipe!.ingredients)
            }
        }
        
        let uid = Auth.auth().currentUser?.uid ?? " "
        GroceryList.getUsersCurrentList(db: db, userID: uid) { (list) in
            if let list = list {
                if list.stores?.isEmpty == true {
                    for item in ingredientsToAddToList {
                        GroceryList.addItemToListFromRecipe(db: self.db, listID: list.ownID ?? " ", name: item, userID: uid, store: "")
                    }
                    self.removeAddAllButton()
                    self.createMessageView(color: Colors.messageGreen, text: "Items added to list!")
                } else if list.stores?.count == 1 {
                    for item in ingredientsToAddToList {
                        GroceryList.addItemToListFromRecipe(db: self.db, listID: list.ownID ?? " ", name: item, userID: uid, store: list.stores!.first!)
                    }
                    self.removeAddAllButton()
                    self.createMessageView(color: Colors.messageGreen, text: "Items added to list!")
                } else {
                    var allItems = ingredientsToAddToList
                    allItems = allItems.filter({self.itemsAddedToList?.contains($0) == false})
                    self.createPickerView(itemNames: allItems, itemStores: list.stores, itemListID: list.ownID ?? " ", singleItem: false, delegateVC: self)
                }
            } else {
                GroceryList.handleProcessForAutomaticallyGeneratedListFromRecipe(db: self.db, items: ingredientsToAddToList)
                
                self.createMessageView(color: Colors.messageGreen, text: "List created and items added!")
            }
        }
        
    }

    
    @IBAction func scaleSlider(_ sender: Any) {
        newServingsValue = Int(scaleSlider.value.rounded())
        if let value = newServingsValue {
            UIView.performWithoutAnimation {
                self.servingSliderNumber.setTitle("\(value)", for: .normal)
                self.servingSliderNumber.layoutIfNeeded()
            }
            
        }
        
    }
    
    @IBAction func editingOnSliderDone(_ sender: Any) {
        print("Editing on slider done")
        editingOnSliderDoneHelper()
    }
    
    
    
    @IBAction func downloadRecipe(_ sender: Any) {
        print("Add to cookbook")
        let cbr = data?.recipe.turnRecipeIntoCookbookRecipe()
        cbr?.write()
        self.createMessageView(color: Colors.messageGreen, text: "Recipe downloaded to cookbook")
        downloadRecipeOutlet.isUserInteractionEnabled = false
        downloadRecipeOutlet.alpha = 0.5
        downloadRecipeOutlet.setTitle("✓ Cookbook", for: .normal)
    }
    
    @IBAction func viewAuthorPage(_ sender: Any) {
        if let stringUrl = data?.recipe.authorURL, let url = URL(string: stringUrl) {
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = true
            let vc = SFSafariViewController(url: url, configuration: config)
            present(vc, animated: true)
        }
    }
    
    
    @IBAction func saveRecipe(_ sender: Any) {
        print("Save recipe")
        if let recipe = data?.recipe {
            let db = Firestore.firestore()
            if SharedValues.shared.savedRecipes?.contains("\(recipe.djangoID)") ?? false {
                Recipe.removeRecipeFromSavedRecipes(db: db, recipe: recipe)
                recipe.removeRecipeDocumentFromUserProfile(db: db)
            } else {
                Recipe.addRecipeToSavedRecipes(db: db, recipe: recipe)
                recipe.addRecipeDocumentToUserProfile(db: db)
                self.createMessageView(color: Colors.messageGreen, text: "Recipe saved")
            }
        }
        
        saveRecipeOutlet.isUserInteractionEnabled = false
        saveRecipeOutlet.alpha = 0.5
        saveRecipeOutlet.setTitle("✓ Save", for: .normal)
        
    }
    
    @IBAction func addToMealPlanner(_ sender: Any) {
        print("Need to add the recipe to the meal planner")
        if SharedValues.shared.mealPlannerID != nil {
            var recipeTitle: String {
                if let cbr = cookbookRecipe {
                    return cbr.name
                } else if let recipe = data?.recipe {
                    return recipe.name
                } else {
                    return "recipe"
                }
            }
            self.createDatePickerView(delegateVC: self, recipe: MealPlanner.RecipeTransfer(date: "date", id: "id", name: recipeTitle), copyRecipe: false, forRecipeDetail: true)
        } else {
            let alert = UIAlertController(title: "No meal planner", message: "Go to the planner tab to get started and create one. You can use your meal planner to track all the recipes and food you plan to have.", preferredStyle: .alert)
            alert.addAction(.init(title: "Ok", style: .default, handler: nil))
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self.present(alert, animated: true)
            }
            
            
        }
        
    }
    
    @IBAction func changeServingsButton(_ sender: Any) {
        print("Change to specific number of servings")
        var recipeTitle: String {
            if let cbr = cookbookRecipe {
                return cbr.name
            } else if let r = data?.recipe {
                return r.name
            } else {
                return "recipe"
            }
        }
        let alert = UIAlertController(title: "Change servings number for \(recipeTitle)", message: nil, preferredStyle: .alert)
        alert.addTextField { (txtField) in
            txtField.keyboardType = .numberPad
            txtField.textColor = Colors.main
        }
        alert.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(.init(title: "Done", style: .default, handler: { (action) in
            guard let text = alert.textFields?.first?.text else { return }
            if text != "", let num = Int(text) {
                self.scaleSlider.maximumValue = Float(num * 2)
                self.scaleSlider.value = Float(num)
                
                UIView.performWithoutAnimation {
                    self.servingSliderNumber.setTitle("\(num)", for: .normal)
                    self.servingSliderNumber.layoutIfNeeded()
                }
                self.newServingsValue = num
                self.editingOnSliderDoneHelper()
            } 
            
        }))
        present(alert, animated: true)
        
    }
    
    
    // MARK: functions
    
    
    private func setUI(recipe: CookbookRecipe) {
        viewsToRemoveForCookbook.forEach { (v) in
            v.removeFromSuperview()
        }
        
        self.title = recipe.name
        
        let v = UIView()
        v.heightAnchor.constraint(equalToConstant: 10).isActive = true
        wholeSV.insertArrangedSubview(v, at: 0)
        
        
        
        recipe.addButtonIngredientViewsTo(stackView: ingredientsStackView, delegateVC: self)
        recipe.addInstructionsToInstructionStackView(stackView: instructionsStackView)
        
        
        if let ct = recipe.cookTime.value {
            cookTime.text = ct.getDisplayHoursAndMinutes()
        } else {
            cookSV.removeFromSuperview()
        }
        
        if let pt = recipe.prepTime.value {
            prepTime.text = pt.getDisplayHoursAndMinutes()
        } else {
            prepSV.removeFromSuperview()
        }
        
        if let s = recipe.servings.value {
            servings.text = "\(s)"
            scaleSlider.minimumValue = 1.0
            scaleSlider.maximumValue = Float(max(20, (s * 4)))
            scaleSlider.value = Float(s)
            
            originalServings = s
            originalIngredients = Array(recipe.ingredients)
            
            UIView.performWithoutAnimation {
                self.servingSliderNumber.setTitle("\(s)", for: .normal)
                self.servingSliderNumber.layoutIfNeeded()
            }
            
        } else {
            servingsSV.removeFromSuperview()
            scaleSV.removeFromSuperview()
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
    
    private func setUI(recipe: Recipe, image: UIImage?) {
        if let img = image {
            imageView.image = img
        }
        
        if let mainImageUrl = data?.recipe.mainImage {
            Network.shared.getImage(url: mainImageUrl) { (image) in
                let aspect = image.size.height / image.size.width
                if aspect != 1.0 {
                    self.imageViewAspect.isActive = false
                    self.imageView.translatesAutoresizingMaskIntoConstraints = false
                    let imageViewWidth = self.imageView.bounds.width
                    self.imageView.image = image
                    self.imageView.heightAnchor.constraint(equalToConstant: imageViewWidth * aspect).isActive = true
                } else {
                    self.imageView.image = image
                }
            }
        } else {
            print("Doesn't have mainImageURL")
            imageViewAspect.isActive = false
            imageView.translatesAutoresizingMaskIntoConstraints = false
            //imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 1.0/3.0).isActive = true
            imageView.heightAnchor.constraint(equalToConstant: 70.0).isActive = true

        }
        
        recipeName.text = recipe.name
        if let authorName = recipe.authorName {
            self.author.text = "By \(authorName)"
        } else {
            self.author.removeFromSuperview()
        }
        nameAndTitleView.layoutIfNeeded()
        self.nameAndTitleView.shadowAndRounded(cornerRadius: 25.0, border: true)
        
        nameAndTitleView.alpha = 0.95
        tagline.text = recipe.tagline
        
        if let pTime = recipe.prepTime {
            prepTime.text = pTime.getDisplayHoursAndMinutes()
        } else {
            prepSV.removeFromSuperview()
        }
        
        if let cTime = recipe.cookTime {
            cookTime.text = cTime.getDisplayHoursAndMinutes()
        } else {
            cookSV.removeFromSuperview()
        }
        
        if let cals = recipe.calories {
            calories.text = "\(cals)"
        } else {
            caloriesSV.removeFromSuperview()
        }
        
        if recipe.authorURL == nil {
            authorButtonOutlet.removeFromSuperview()
        }
        
        servings.text = "\(recipe.numServes)"
        
        
        scaleSlider.minimumValue = 1
        scaleSlider.maximumValue = Float(max(20, (recipe.numServes * 4)))
        scaleSlider.value = Float(recipe.numServes)
        
        originalServings = recipe.numServes
        originalIngredients = recipe.ingredients
        
        UIView.performWithoutAnimation {
            self.servingSliderNumber.setTitle("\(recipe.numServes)", for: .normal)
            self.servingSliderNumber.layoutIfNeeded()
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
        
        
        
        recipe.addButtonIngredientViewsTo(stackView: ingredientsStackView, delegateVC: self)
        recipe.addInstructionsToInstructionStackView(stackView: instructionsStackView)
        
        
        
        if SharedValues.shared.savedRecipes?.contains("\(recipe.djangoID)") ?? false {
            saveRecipeOutlet.isUserInteractionEnabled = false
            saveRecipeOutlet.alpha = 0.5
            saveRecipeOutlet.setTitle("✓ Save", for: .normal)
        }
        
        recipe.addRecipeToRecentlyViewedRecipes(db: db)
        
    }
    
    private func editingOnSliderDoneHelper() {
        if let i = originalIngredients, let os = originalServings, let ns = newServingsValue {
            let newIngredients = i.changeRecipeIngredientScale(ratio: (ns, os))
            ingredientsStackView.subviews.forEach { (view) in
                if type(of: view) == ButtonIngredientView.self {
                    view.removeFromSuperview()
                }
            }
            
            if cookbookRecipe != nil {
                let realmIngredients = List<String>()
                newIngredients.forEach({realmIngredients.append($0)})
                let realmServings = RealmOptional(ns)
                
                cookbookRecipe?.ingredients = realmIngredients
                cookbookRecipe?.servings = realmServings
                cookbookRecipe?.addButtonIngredientViewsTo(stackView: ingredientsStackView, delegateVC: self)
            } else {
                data?.recipe.ingredients = newIngredients
                data?.recipe.numServes = ns
                data?.recipe.addButtonIngredientViewsTo(stackView: ingredientsStackView, delegateVC: self)
            }
            
            
        }
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
    
    
    @objc private func itemAddedSelector(_ notification: NSNotification) {
        if let dict = notification.userInfo as NSDictionary? {
            if let name = dict["itemName"] as? String {
                print("Name of the item: \(name)")
                itemsAddedToList?.insert(name)
                for item in ingredientsStackView.subviews {
                    if type(of: item) == ButtonIngredientView.self {
                        let txt = (item as! ButtonIngredientView).label.text
                        if txt == name {
                            let itm = (item as! ButtonIngredientView)
                            itm.label.textColor = .systemGreen
                            itm.button.tintColor = .systemGreen
                            itm.button.isUserInteractionEnabled = false
                            if #available(iOS 13.0, *) {
                                itm.button.setImage(.strokedCheckmark, for: .normal)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                    itm.label.textColor = .secondaryLabel
                                }
                            } else {
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
// MARK: ButtonIngredientViewDelegate
extension RecipeDetailVC: ButtonIngredientViewDelegate {
    func haveUserSortItem(addedItemName: [String], addedItemStores: [String]?, addedItemListID: String) {
        print("picker view added here")
        self.createPickerView(itemNames: addedItemName, itemStores: addedItemStores, itemListID: addedItemListID, singleItem: true, delegateVC: self)
    }
}

// MARK: DisableAllItemsDelegate
extension RecipeDetailVC: DisableAddAllItemsDelegate {
    func disableButton() {
        removeAddAllButton()
    }
}



// MARK: SelectDateViewDelegate
extension RecipeDetailVC: SelectDateViewDelegate {
    func dateSelected(date: Date, recipe: MealPlanner.RecipeTransfer?, copyRecipe: Bool) {
        let formattedDate = date.dbFormat()
        
        if SharedValues.shared.mealPlannerID != nil {
            // can add the recipe to the meal planner
            var mpCookbookRecipe: MPCookbookRecipe {
                let mpcbr = MPCookbookRecipe()
                if let cbr = cookbookRecipe {
                    mpcbr.set(cookbookRecipe: cbr, date: formattedDate)
                    return mpcbr
                } else {
                    let cbr = (data?.recipe.turnRecipeIntoCookbookRecipe())!
                    mpcbr.set(cookbookRecipe: cbr, date: formattedDate)
                    return mpcbr
                }
            }
            MealPlanner.addRecipeToPlanner(db: db, recipe: mpCookbookRecipe, shortDate: formattedDate, mealType: .none, previousID: nil)
        }
        
    }
    
}
