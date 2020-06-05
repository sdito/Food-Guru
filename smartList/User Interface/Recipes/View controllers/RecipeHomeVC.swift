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
    
    @IBOutlet weak var homeRecipesOutlet: UIButton!
    @IBOutlet weak var savedRecipesOutlet: UIButton!
    
    @IBOutlet weak var wholeStackView: UIStackView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var scrollBackUpView: UIView!
    @IBOutlet weak var searchBarHeight: NSLayoutConstraint!
    
    var db: Firestore!
    var imageCache = NSCache<NSString, UIImage>()
    private var searchQueue: [NetworkSearch] = []
    private var keyboardHeight: CGFloat?
    private var textAssistantViewActive = false
    private var newItemVC: CreateNewItemVC?
    private var userWantsMoreRecipes = false
    private var lastContentOffset: CGFloat = 0
    private var allowButtonToBeShowed = true
    private let currentSearchesView = Bundle.main.loadNibNamed("CurrentSearchesView", owner: nil, options: nil)?.first as! CurrentSearchesView
    private var expiringItems: [String] = []
    private var previousContentOffset: CGPoint?
    private var timer: Timer?
    private var delegate: SearchAssistantDelegate!
    private var savedRecipesActive = false {
        didSet {
            imageCache.removeAllObjects()
            collectionView?.collectionViewLayout.invalidateLayout()
            collectionView?.reloadData()
            
            switch self.savedRecipesActive {
            case true:
                searchBar.placeholder = "Filter saved recipes"
                currentSearchesView.isHidden = true
            case false:
                searchBar.placeholder = "Search all recipes"
                currentSearchesView.isHidden = false
            }
        }
    }
    
    private var contentSizeHeight: CGFloat {
        return collectionView.contentSize.height
    }
    
    #warning("Need to convert to NetworkSearch.NetworkSearchType")
    private var activeSearches: [NetworkSearch] = [] {
        didSet {
            if SharedValues.shared.sentRecipesInfo == nil {
                Network.shared.getRecipes(searches: self.activeSearches) { (rcps) in
                    
                    for _ in 1...20 {
                        print(self.recipes.count)
                    }
                    
                    if let rcps = rcps {
                        self.recipes = rcps
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
        
        
        createObserver()
        scrollBackUpView.shadowAndRounded(cornerRadius: 10, border: false)
        homeRecipesOutlet.handleSelectedForBottomTab(selected: true)
        
        FoodStorage.readAndPersistSystemItemsFromStorageWithListener(db: db, storageID: SharedValues.shared.foodStorageID ?? " ")
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        handleRecipesToShow()
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in self.handleTimer()}
        timer?.tolerance = 0.2
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        switch savedRecipesActive {
        case true:
            savedRecipesOutlet.handleSelectedForBottomTab(selected: true)
            homeRecipesOutlet.handleSelectedForBottomTab(selected: false)
        case false:
            savedRecipesOutlet.handleSelectedForBottomTab(selected: false)
            homeRecipesOutlet.handleSelectedForBottomTab(selected: true)
        }
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
    
    @IBAction func homeRecipes(_ sender: Any) {
        if savedRecipesActive {
            savedRecipesActive = false
            homeRecipesOutlet.handleSelectedForBottomTab(selected: true)
            savedRecipesOutlet.handleSelectedForBottomTab(selected: false)
        }
    }
    
    @IBAction func savedRecipes(_ sender: Any) {
        if !savedRecipesActive {
            savedRecipesActive = true
            homeRecipesOutlet.handleSelectedForBottomTab(selected: false)
            savedRecipesOutlet.handleSelectedForBottomTab(selected: true)
            Recipe.readUserSavedRecipes(db: db) { (rcps) in
                self.savedRecipes = rcps
            }
        }
        
    }

    
    @IBAction func goToCookbook(_ sender: Any) {
        tabBarController?.selectedIndex = 1
    }
    // MARK: functions
    
    
    func updateUiForNewDayChange() {
        for _ in 1...25 {
            print("Potentially need to update the UI on RecipeHomeVC")
        }
    }
    

    
    private func createObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
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
    }
    
    private func handleRecipesToShow() {
        if SharedValues.shared.sentRecipesInfo == nil {
            if recipes.isEmpty {
                
                /*
                Search.find(from: activeSearches, db: db) { (rcps) in
                    if let rs = rcps {
                        self.recipes = rs
                    }
                }
                */
                #warning("first use with API")
                Network.shared.getRecipes(searches: nil) { (rcps) in
                    if let rs = rcps {
                        self.recipes = rs
                    }
                }
                
            }
        } else {
            recipes = SharedValues.shared.sentRecipesInfo!.recipes
            //activeSearches = SharedValues.shared.sentRecipesInfo!.ingredients.map({NetworkSearch(text: $0, type: .ingredient)})
            activeSearches = SharedValues.shared.sentRecipesInfo?.1 ?? []
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
 
    
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        print("Keyboard will show is being called")
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            keyboardHeight = keyboardRectangle.height
            
        }
    }
}


// MARK: RecipesFoundFromSearchingDelegate
extension RecipeHomeVC: RecipesFoundFromSearchingDelegate {
    func recipesFound(ingredients: [String]) {
        self.imageCache.removeAllObjects()
        self.dismiss(animated: true, completion: nil)
        activeSearches += ingredients.map({(NetworkSearch(text: $0, type: .ingredient))})
    }
}

// MARK: CurrentSearchesDelegate
extension RecipeHomeVC: CurrentSearchesViewDelegate {
    func buttonPressedToDeleteSearch(search: NetworkSearch) {
        if activeSearches.contains(search) {
            activeSearches = activeSearches.filter({$0 != search})
        }
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
                
                #warning("need to implement the new image from url here")
                
                Network.shared.getImage(url: recipe.thumbImage) { (image) in
                    cell.recipeImage.image = image
                    self.imageCache.setObject(image, forKey: "\(indexPath.row)" as NSString)
                }
                
                /*
                recipe.getImageFromStorage(thumb: true) { (img) in
                    cell.recipeImage.image = img
                    self.imageCache.setObject(img!, forKey: "\(indexPath.row)" as NSString)
                    print("Read for \(indexPath.row)")
                }
                */
                
                
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
                /*
                recipe.getImageFromStorage(thumb: true) { (img) in
                    cell.recipeImage.image = img
                    self.imageCache.setObject(img!, forKey: "\(indexPath.row)" as NSString)
                    print("Read for \(indexPath.row)")
                }
                */
                Network.shared.getImage(url: recipe.thumbImage) { (image) in
                    cell.recipeImage.image = image
                    self.imageCache.setObject(image, forKey: "\(indexPath.row)" as NSString)
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
        }
        
        else if (self.lastContentOffset < scrollView.contentOffset.y) {
            scrollBackUpView.setIsHidden(true, animated: true)
        }
        
        self.lastContentOffset = scrollView.contentOffset.y
        
       
    }

    
}

// MARK: Search bar
extension RecipeHomeVC: UISearchBarDelegate {
    @objc func keyboardDismissed() {
        searchBar.endEditing(true)
    }
    
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if savedRecipesActive == false {
            activeSearches = searchQueue
            searchQueue = []
            searchBar.text = ""
            delegate.searchTextChanged(text: "")
        } else {
            print("Need different search, saved recipes is active")
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if savedRecipesActive == true {
            filteredSavedRecipes = Recipe.filterSavedRecipesFrom(text: searchText, savedRecipes: savedRecipes)
        } else {
            #warning("doesn't work properly")
            searchQueue = Network.getSearchesFromText(text: searchText, currSearches: searchQueue)
            
            if textAssistantViewActive == false {
                // add the view here
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "createNewItemVC") as! CreateNewItemVC
                self.newItemVC = vc
                self.addChild(vc)
                self.view.addSubview(vc.tableView)
                vc.didMove(toParent: self)
                vc.isForSearch = true
                
                vc.tableView.translatesAutoresizingMaskIntoConstraints = false
                
                vc.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
                vc.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
                vc.tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor).isActive = true
                
                let tb = (tabBarController?.tabBar.frame.height ?? 0.0)
                let distance = (wholeStackView.frame.height) - (keyboardHeight ?? 0.0) - (searchBar.frame.height) + tb
                
                vc.tableView.heightAnchor.constraint(equalToConstant: distance).isActive = true
                
                vc.delegate = self as CreateNewItemDelegate
                delegate = vc
                delegate.searchTextChanged(text: searchText)
                textAssistantViewActive = true
                
                
            } else {
                delegate.searchTextChanged(text: searchText)
            }
        }
    }
}


extension RecipeHomeVC: CreateNewItemDelegate {
    func searchCreated(search: NetworkSearch) {
        
        searchQueue.insert(search, at: 0)
        searchBar.text = searchBar.text?.updateSearchText(newItem: search.text)
        searchQueue = Network.getSearchesFromText(text: searchBar.text ?? "", currSearches: searchQueue)
        textAssistantViewActive = false
        
    }
    func itemCreated(item: Item) {}
    
}
