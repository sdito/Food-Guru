//
//  RecipeHomeVC.swift
//  smartList
//
//  Created by Steven Dito on 9/5/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import UIKit
import FirebaseFirestore
import AVFoundation



class RecipeHomeVC: UIViewController {
    
    @IBOutlet weak var savedAndAllRecipesOutlet: UIButton!
    @IBOutlet weak var backUpOutlet: UIButton!
    @IBOutlet weak var wholeStackView: UIStackView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchHelperView: UIView!
    @IBOutlet weak var searchButtonStackView: UIStackView!
    @IBOutlet weak var scrollBackUpView: UIView!
    @IBOutlet weak var moreRecipesView: UIView!
    @IBOutlet weak var searchBarHeight: NSLayoutConstraint!
    
    var db: Firestore!
    var imageCache = NSCache<NSString, UIImage>()
    private var userWantsMoreRecipes = false
    private var lastContentOffset: CGFloat = 0
    private var allowButtonToBeShowed = true
    private let currentSearchesView = Bundle.main.loadNibNamed("CurrentSearchesView", owner: nil, options: nil)?.first as! CurrentSearchesView
    private var expiringItems: [String] = []
    private var previousContentOffset: CGPoint?
    private var timer: Timer?
    private var savedRecipesActive = false {
        didSet {
            imageCache.removeAllObjects()
            collectionView?.collectionViewLayout.invalidateLayout()
            collectionView?.reloadData()
            
            switch self.savedRecipesActive {
            case true:
                searchBar.placeholder = "Filter saved recipes"
                savedAndAllRecipesOutlet.setTitle("All recipes", for: .normal)
                currentSearchesView.isHidden = true
                searchHelperView.isHidden = true
            case false:
                searchBar.placeholder = "Search all recipes"
                savedAndAllRecipesOutlet.setTitle("Saved", for: .normal)
                currentSearchesView.isHidden = false
            }
        }
    }
    
    private var contentSizeHeight: CGFloat {
        return collectionView.contentSize.height
    }
    
    
    private var activeSearches: [(String, SearchType)] = [] {
        didSet {
            if SharedValues.shared.sentRecipesInfo == nil {
                Search.find(from: self.activeSearches, db: db) { (rcps) in
                    if let rcps = rcps {
                        self.recipes = rcps
                    } else {
                        for _ in 1...10 {
                            print("Recipes not found")
                        }
                    }
                }
                
            }
            if wholeStackView.subviews.contains(currentSearchesView) {
                currentSearchesView.setUI(searches: self.activeSearches)
            } else {
                wholeStackView.insertArrangedSubview(currentSearchesView, at: 1)
                currentSearchesView.setUI(searches: self.activeSearches)
            }
            if self.activeSearches.isEmpty {
                searchBar.placeholder = "Search recipes"
            } else {
                searchBar.placeholder = "Add another search"
            }
            
        }
    }
    
    var recipes: [Recipe] = [] {
        didSet {
            imageCache.removeAllObjects()
            collectionView?.collectionViewLayout.invalidateLayout()
            collectionView?.reloadData()
            
            if self.recipes.isEmpty {
                self.createMessageView(color: .red, text: "No recipes found")
                handleNeedingMoreRecipes()
            }
            
            if self.recipes.count < 2 {
                moreRecipesView.isHidden = false
            }
        }
    }
    
    private var savedRecipes: [Recipe] = [] {
        didSet {
            filteredSavedRecipes = self.savedRecipes
        }
    }
    
    private var filteredSavedRecipes: [Recipe] = [] {
        didSet {
            imageCache.removeAllObjects()
            collectionView?.collectionViewLayout.invalidateLayout()
            collectionView?.reloadData()
        }
    }
    // MARK: override funcs
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        searchBar.delegate = self
        searchBar.setTextProperties()
        searchBar.setUpToolBar(action: #selector(keyboardDismissed))
        
        db = Firestore.firestore()
        
        currentSearchesView.delegate = self
        let layout = collectionView.collectionViewLayout as! DynamicHeightLayout
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            layout.numberOfColumns = 3
        } else {
            layout.numberOfColumns = 2
        }
        
        layout.delegate = self
        
        
        searchButtonStackView.setUpQuickSearchButtons()
        createObserver()
        scrollBackUpView.shadowAndRounded(cornerRadius: 10, border: false)
        moreRecipesView.shadowAndRounded(cornerRadius: 10, border: false)
        backUpOutlet.alpha = 0
        
        
        FoodStorage.readAndPersistSystemItemsFromStorageWithListener(db: db, storageID: SharedValues.shared.foodStorageID ?? " ")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        handleRecipesToShow()
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in self.handleTimer()}
        timer?.tolerance = 0.2
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        timer?.invalidate()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
           if segue.identifier == "showRecipeDetail" {
               let destVC = segue.destination as! RecipeDetailVC
               destVC.data = sender as? (UIImage?, Recipe)
           }
       }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
   
    // MARK: @IBAction funcs
    @IBAction func createRecipePressed(_ sender: Any) {
        if SharedValues.shared.anonymousUser == false {
            performSegue(withIdentifier: "toCreateRecipe", sender: nil)
        } else {
            let alert = UIAlertController(title: "Error", message: "Create a free account in order to publish recipes.", preferredStyle: .alert)
            alert.addAction(.init(title: "Ok", style: .default, handler: nil))
            present(alert, animated: true)
        }
    }
    
    @IBAction func scrollBackUp(_ sender: Any) {
        allowButtonToBeShowed = false
        collectionView.setContentOffset(.init(x: 0, y: 0), animated: true)
        lastContentOffset = 0
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.allowButtonToBeShowed = true
        }
    }
    @IBAction func savedRecipes(_ sender: Any) {
        savedRecipesActive = !savedRecipesActive
        print("SavedRecipesActive?: \(savedRecipesActive)")
        if savedRecipesActive == true {
            Recipe.readUserSavedRecipes(db: db) { (rcps) in
                self.savedRecipes = rcps
            }
        }
    }
    
    
    @IBAction func moreRecipesPressed(_ sender: Any) {
        userWantsMoreRecipes = true
        handleNeedingMoreRecipes()
        
    }
    
    @IBAction func goToCookbook(_ sender: Any) {
        tabBarController?.selectedIndex = 1
    }
    // MARK: functions
    private func handleNeedingMoreRecipes() {
        
        Recipe.getPuppyRecipesFromSearches(activeSearches: self.activeSearches, expiringItems: expiringItems) { (puppyRecipes) in
            
            DispatchQueue.main.async {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "outsideRecipesVC") as! OutsideRecipesVC
                vc.puppyRecipes = puppyRecipes
                if vc.puppyRecipes?.isEmpty == false {
                    
                    self.present(vc, animated: true, completion: nil)
                } else {
                    // to only allow this messageview if the user specifically pressed the more recipes button
                    if self.userWantsMoreRecipes == true {
                        self.createMessageView(color: .red, text: "Couldn't find more recipes")
                        self.userWantsMoreRecipes = false
                    }
                    
                }
            }
            
            
        
        }
        
        
        
    }
    
    private func createObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(recipeButtonPressed), name: .recipeSearchButtonPressed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadCollectionView), name: .savedRecipesChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(haveSavedRecipesShow), name: .haveSavedRecipesAppear, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadCollectionView), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(expiringIngredientsReceived), name: .expiringItemsFromFoodStorage, object: nil)
    }
    
    @objc func expiringIngredientsReceived(_ notification: NSNotification) {
        if let dict = notification.userInfo as NSDictionary? {
            if let items = dict["items"] as? [String] {
                let displayItems = items.map { (str) -> String in
                    (GenericItem.init(rawValue: str)?.description ?? "")
                }.filter({$0 != ""})
                expiringItems = displayItems
            }
        }
    }
    
    
    
    @objc func recipeButtonPressed(_ notification: NSNotification) {
        handleSuggestedSearchButtonBeingPressed()
        if let dict = notification.userInfo as NSDictionary? {
            if let buttonName = dict["buttonName"] as? (String, SearchType) {
                if buttonName.0 != "Select Ingredients" {
                    handleDuplicateSearchesAndAddNew(newSearches: [buttonName])
                } else {
                    print("Got to this point")
                    let sb = UIStoryboard(name: "Recipes", bundle: nil)
                    let vc = sb.instantiateViewController(withIdentifier: "searchByIngredient") as! SearchByIngredientVC
                    vc.recipesFoundDelegate = self
                    self.present(vc, animated: true, completion: nil)
                }
            }
        }
    }
    @objc func haveSavedRecipesShow() {
        savedRecipesActive = true
        Recipe.readUserSavedRecipes(db: db) { (rcps) in
            self.savedRecipes = rcps
        }
    }
    @objc func reloadCollectionView() {
        print("Collection view should be reloaded")
        collectionView.reloadData()
    }
    
    private func handleSuggestedSearchButtonBeingPressed() {
        wholeStackView.insertArrangedSubview(currentSearchesView, at: 1)
        searchBar.endEditing(true)
        searchHelperView.isHidden = true
    }
    
    private func handleRecipesToShow() {
        if SharedValues.shared.sentRecipesInfo == nil {
            if recipes.isEmpty {
                Search.find(from: activeSearches, db: db) { (rcps) in
                    if let rs = rcps {
                        self.recipes = rs
                    }
                }
            }
        } else {
            recipes = SharedValues.shared.sentRecipesInfo!.recipes
            activeSearches = SharedValues.shared.sentRecipesInfo!.ingredients.map({($0, .ingredient)})
            imageCache.removeAllObjects()
            SharedValues.shared.sentRecipesInfo = nil
        }
    }
    private func handleTimer() {
        let currentContentOffset = collectionView.contentOffset
        if currentContentOffset == previousContentOffset {
            if scrollBackUpView.isHidden {
                scrollBackUpView.setIsHidden(false, animated: true)
            }
        }
        previousContentOffset = currentContentOffset
    }
    
    private func handleDuplicateSearchesAndAddNew(newSearches: [(String, SearchType)]) {
        var temp: [(String, SearchType)] = activeSearches
        print("\(newSearches) are the newSearches")
        for newSearch in newSearches {
            switch newSearch.1 {
            case .cuisine:
                temp = temp.filter({$0.1 != .cuisine})
                temp = temp.filter({$0.1 != .other})
                temp += newSearches
                activeSearches = temp
            case .recipe:
                temp = temp.filter({$0.1 != .recipe})
                temp = temp.filter({$0.1 != .other})
                temp += newSearches
                activeSearches = temp
            case .ingredient:
                temp = temp.filter({$0.1 != .other})
                temp += newSearches
                activeSearches = temp
            case .other:
                activeSearches = newSearches
            }
        }
    }
}


// MARK: RecipesFoundFromSearchingDelegate
extension RecipeHomeVC: RecipesFoundFromSearchingDelegate {
    func recipesFound(ingredients: [String]) {
        self.imageCache.removeAllObjects()
        self.dismiss(animated: true, completion: nil)
        activeSearches += ingredients.map({($0, .ingredient)})
    }
}

// MARK: CurrentSearchesDelegate
extension RecipeHomeVC: CurrentSearchesViewDelegate {
    func buttonPressedToDeleteSearch(index: Int) {
        activeSearches.remove(at: index)
    }
}

// MARK: DynamicHeightLayoutDelegate
extension RecipeHomeVC: DynamicHeightLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForTextAtIndexPath indexPath: IndexPath, withWidth width: CGFloat) -> CGFloat {
        let minForDescription = heightForText("str", width: CGFloat(MAXFLOAT), font: UIFont(name: "futura", size: 13)!) * 5.0
        switch savedRecipesActive {
        case true:
            let textData = filteredSavedRecipes[indexPath.item]
            let title = heightForText(textData.name, width: width - 12, font: UIFont(name: "futura", size: 20)!)
            let description = heightForText(textData.tagline ?? "", width: width - 12, font: UIFont(name: "futura", size: 13)!)
            let actualDescription = min(minForDescription, description)
            return title + actualDescription + 8
        case false:
            let textData = recipes[indexPath.item]
            let title = heightForText(textData.name, width: width - 12, font: UIFont(name: "futura", size: 20)!)
            let description = heightForText(textData.tagline ?? "", width: width - 12, font: UIFont(name: "futura", size: 13)!)
            let actualDescription = min(minForDescription, description)
            return title + actualDescription + 8
        }
        
    }
    func heightForText(_ text: String, width: CGFloat, font: UIFont) -> CGFloat {
        let rect = NSString(string: text).boundingRect(with: CGSize(width: width, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return ceil(rect.height)
    }
}

// MARK: Collection view
extension RecipeHomeVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch savedRecipesActive {
        case true:
            return filteredSavedRecipes.count
        case false:
            return recipes.count
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch savedRecipesActive {
        case true:
            let selected = filteredSavedRecipes[indexPath.item]
            performSegue(withIdentifier: "showRecipeDetail", sender: (imageCache.object(forKey: "\(indexPath.row)" as NSString), selected))
        case false:
            let selected = recipes[indexPath.item]
            performSegue(withIdentifier: "showRecipeDetail", sender: (imageCache.object(forKey: "\(indexPath.row)" as NSString), selected))
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if savedRecipesActive == false {
            if indexPath.row == 1 {
                if collectionView.contentSize.height < collectionView.bounds.height {
                    print("Need to make the view visible")
                    moreRecipesView.isHidden = false
                } else {
                    print("Need to make the view hidden")
                    moreRecipesView.isHidden = true
                }
    //            print(collectionView.contentSize.height, collectionView.bounds.height)
            }
        } else {
            moreRecipesView.isHidden = true
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch savedRecipesActive {
        case true:
            let recipe = filteredSavedRecipes[indexPath.row]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "recipeCell", for: indexPath) as! RecipeCell
            cell.setUI(recipe: recipe)
            //cell.delegate = self as RecipeCellDelegate
            if let cachedImage = imageCache.object(forKey: "\(indexPath.row)" as NSString) {
                cell.recipeImage.image = cachedImage
                print("Cache for \(indexPath.row)")
            } else {
                recipe.getImageFromStorage(thumb: true) { (img) in
                    cell.recipeImage.image = img
                    self.imageCache.setObject(img!, forKey: "\(indexPath.row)" as NSString)
                    print("Read for \(indexPath.row)")
                }
            }
            
            return cell
        case false:
            let recipe = recipes[indexPath.row]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "recipeCell", for: indexPath) as! RecipeCell
            cell.setUI(recipe: recipe)
            //cell.delegate = self as RecipeCellDelegate
            if let cachedImage = imageCache.object(forKey: "\(indexPath.row)" as NSString) {
                cell.recipeImage.image = cachedImage
                print("Cache for \(indexPath.row)")
            } else {
                recipe.getImageFromStorage(thumb: true) { (img) in
                    cell.recipeImage.image = img
                    self.imageCache.setObject(img!, forKey: "\(indexPath.row)" as NSString)
                    print("Read for \(indexPath.row)")
                }
            }
            
            return cell
        }

    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if (self.lastContentOffset > scrollView.contentOffset.y) {
            if allowButtonToBeShowed == true && scrollView.contentOffset.y >= 0 {
                scrollBackUpView.setIsHidden(false, animated: true)
            }
            backUpOutlet.alpha = 1
        }
        else if scrollView.contentOffset.y <= 0 {
            backUpOutlet.alpha = 0
        }
        
        else if (self.lastContentOffset < scrollView.contentOffset.y) {
            scrollBackUpView.setIsHidden(true, animated: true)
        }
        
        self.lastContentOffset = scrollView.contentOffset.y
        
        if self.lastContentOffset < 400 {
            backUpOutlet.alpha = 0.0
        }
        
        if savedRecipesActive == false {
            let svContentOffset = scrollView.contentOffset.y
            let bottonOfSV = contentSizeHeight-scrollView.bounds.height
            
            if svContentOffset > bottonOfSV - 500 {
                if moreRecipesView.isHidden == true {
                    moreRecipesView.setIsHidden(false, animated: true)
                }
            } else {
                if moreRecipesView.isHidden == false {
                    moreRecipesView.setIsHidden(true, animated: true)
                }
            }
        } else {
            moreRecipesView.isHidden = true
        }
    }

    
}

// MARK: Search bar
extension RecipeHomeVC: UISearchBarDelegate {
    @objc func keyboardDismissed() {
        searchBar.endEditing(true)
        searchHelperView.isHidden = true
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if savedRecipesActive == false {
            searchHelperView.isHidden = false
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if savedRecipesActive == false {
            let s = Search.searchFromSearchBar(string: searchBar.text!)
            handleDuplicateSearchesAndAddNew(newSearches: s)
            searchBar.endEditing(true)
            searchHelperView.isHidden = true
            searchBar.text = ""
        } else {
            print("Need different search, saved recipes is active")
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if savedRecipesActive == true {
            filteredSavedRecipes = Recipe.filterSavedRecipesFrom(text: searchText, savedRecipes: savedRecipes)
        }
    }
}
