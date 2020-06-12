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
import SkeletonView


class RecipeHomeVC: UIViewController {
    
    @IBOutlet weak var spinnerHolder: UIView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    @IBOutlet weak var homeRecipesOutlet: UIButton!
    @IBOutlet weak var savedRecipesOutlet: UIButton!
    
    @IBOutlet weak var wholeStackView: UIStackView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var scrollBackUpView: UIView!
    @IBOutlet weak var searchBarHeight: NSLayoutConstraint!
    
    var db: Firestore!
    var imageCache = NSCache<NSString, UIImage>()
    private var skeletonViewActive = false
    private var nextUrl: String?
    private var loadingMoreRecipes = false
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
                if skeletonViewActive {
                    stopSkeleton()
                }
            case false:
                searchBar.placeholder = "Search all recipes"
                currentSearchesView.isHidden = false
            }
        }
    }
    
    private var contentSizeHeight: CGFloat {
        return collectionView.contentSize.height
    }
    
    
    private var activeSearches: [NetworkSearch] = [] {
        didSet {
            if SharedValues.shared.sentRecipesInfo == nil {
                startSkeleton()
                Network.shared.getRecipes(searches: self.activeSearches) { (response) in
                    switch response {
                    case .success((let rcps, let nxtUrl)):
                        if let rcps = rcps {
                            self.recipes = rcps
                            self.collectionViewReloadReset()
                        }
                        self.nextUrl = nxtUrl
                    case .failure(_):
                        #warning("probably create no connection view here")
                        self.stopSkeleton()
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
    
    var recipes: [Recipe] = []
    
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
        homeRecipesOutlet.handleSelectedForBottomTab(selected: true)
        spinnerHolder.layer.cornerRadius = spinnerHolder.frame.height / 2
        spinnerHolder.isHidden = true
        collectionView.refreshControl = UIRefreshControl()
        collectionView.refreshControl?.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
        collectionView.refreshControl?.tintColor = Colors.main
        scrollBackUpView.layoutIfNeeded()
        scrollBackUpView.shadowAndRounded(cornerRadius: 10, border: false)
        skeletonViewActive = true
        collectionView.showAnimatedGradientSkeleton()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        handleRecipesToShow()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in self.handleTimer()}
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

    @IBAction func startAdvancedSearch(_ sender: Any) {
        self.createAdvancedSearchView()
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
    
    
    @objc func haveSavedRecipesShow(_ notification: NSNotification) {
        
        if let dict = notification.userInfo as NSDictionary? {
            if let haveSavedRecipesShow = dict["haveSavedRecipesShow"] as? Bool {
                if haveSavedRecipesShow != savedRecipesActive {
                    savedRecipesActive = haveSavedRecipesShow
                    
                    if savedRecipesActive {
                        Recipe.readUserSavedRecipes(db: db) { (rcps) in
                            self.savedRecipes = rcps
                        }
                    }
                    
                }
            }
        }
    }
    
    @objc func reloadCollectionView() {
        collectionView.reloadData()
    }
    
    private func handleSuggestedSearchButtonBeingPressed() {
        wholeStackView.insertArrangedSubview(currentSearchesView, at: 1)
        searchBar.endEditing(true)
    }
    
    private func handleRecipesToShow() {
        if SharedValues.shared.sentRecipesInfo == nil {
            if recipes.isEmpty {
                Network.shared.getRecipes(searches: nil) { (response) in
                    switch response {
                    case .success((let rcps, let next)):
                        if let rs = rcps {
                            self.recipes = rs
                            self.collectionViewReloadReset()
                        }
                        self.nextUrl = next
                    case .failure(_):
                        #warning("actually create the noConnectionView here")
                    }
                }
                
            }
        } else {
            if let newSearches = SharedValues.shared.sentRecipesInfo, newSearches.count > 0 {
                SharedValues.shared.sentRecipesInfo = nil
                activeSearches = newSearches
            }
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
        let minForTitle = heightForText("str", width: CGFloat(MAXFLOAT), font: UIFont(name: "futura", size: 20)!) * 2.0
        
        var textData: Recipe {
            if skeletonViewActive {
                return Recipe.randomRecipeForSkeletonView()
            } else {
                switch savedRecipesActive {
                case true:
                    return filteredSavedRecipes[indexPath.item]
                case false:
                    return recipes[indexPath.item]
                }
            }
            
            
        }
        let title = heightForText(textData.name, width: width - 8, font: UIFont(name: "futura", size: 20)!)
        let description = heightForText(textData.tagline ?? "", width: width - 8, font: UIFont(name: "futura", size: 13)!)
        let actualTitle = min(minForTitle, title)
        let actualDescription = min(minForDescription, description)
        return actualTitle + actualDescription + 8
        
        
    }
    func heightForText(_ text: String, width: CGFloat, font: UIFont) -> CGFloat {
        let rect = NSString(string: text).boundingRect(with: CGSize(width: width, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return ceil(rect.height)
    }
}

// MARK: Collection view
extension RecipeHomeVC: UICollectionViewDelegate, UICollectionViewDataSource {
    @objc private func handleRefreshControl(sender: UIRefreshControl) {
        
        if savedRecipesActive {
            // want to use this to not update the data right away, since the animation doesn't look good when that happens
            // shouldn't add a delay if it already takes some time, thus using a startingTime
            let startingTime = Date().timeIntervalSince1970
            Recipe.readUserSavedRecipes(db: db) { (rcps) in
                let secondsElapsed = Date().timeIntervalSince1970 - startingTime
                if secondsElapsed >= 1.5 {
                    self.savedRecipes = rcps
                    self.searchBar.text = ""
                    self.filteredSavedRecipes = self.savedRecipes
                    self.collectionView.refreshControl?.endRefreshing()
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5-secondsElapsed) {
                        self.savedRecipes = rcps
                        self.searchBar.text = ""
                        self.filteredSavedRecipes = self.savedRecipes
                        self.collectionView.refreshControl?.endRefreshing()
                    }
                }
            }
        } else {
            if let nextUrl = nextUrl {
                
                Network.shared.getRecipes(url: nextUrl) { (response) in
                    self.collectionView.refreshControl?.endRefreshing()
                    switch response {
                    case .success((let rcps, let nxtUrl)):
                        if let rcps = rcps {
                            self.recipes = rcps
                            self.collectionViewReloadReset()
                        }
                        self.nextUrl = nxtUrl
                    case .failure(_):
                        break
                    }
                }
                
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    // Pauses or else its a sudden drop off and doesn't look good
                    self.collectionView.refreshControl?.endRefreshing()
                    self.createMessageView(color: Colors.messageGreen, text: "No recipes to refresh")
                }
            }
        }
    }
    
    private func collectionViewReloadReset() {
        // used when completely new recipes, not when recipes are added
        stopSkeleton()
        skeletonViewActive = false
        imageCache.removeAllObjects()
        collectionView?.collectionViewLayout.invalidateLayout()
        collectionView?.reloadData()
        
    }
    
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
        
        var recipe: Recipe {
            switch savedRecipesActive {
            case true:
                return filteredSavedRecipes[indexPath.row]
            case false:
                return recipes[indexPath.row]
            }
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "recipeCell", for: indexPath) as! RecipeCell
        cell.setUI(recipe: recipe)
        //cell.delegate = self as RecipeCellDelegate
        if let cachedImage = imageCache.object(forKey: "\(indexPath.row)" as NSString) {
            cell.recipeImage.image = cachedImage
            print("Cache for \(indexPath.row)")
        } else {
            if let thumbImageUrl = recipe.thumbImage {
                Network.shared.getImage(url: thumbImageUrl) { (image) in
                    cell.recipeImage.image = image
                    self.imageCache.setObject(image, forKey: "\(indexPath.row)" as NSString)
                }
            } else {
                cell.recipeImage.image = UIImage(named: "no_image")
            }
            
        }
        
        return cell
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
        
        let collectionViewHeight = scrollView.contentSize.height - collectionView.frame.height
        
        // load the next page of recipes
        // Need to be at the bottom of collection view, not already loading more recipes, on the home tab, and a nextUrl has to exist to load more
        if lastContentOffset >= collectionViewHeight - 50 && !loadingMoreRecipes && !savedRecipesActive, let nextUrl = nextUrl {
            loadingMoreRecipes = true
            spinner.startAnimating()
            spinnerHolder.isHidden = false
            print("Need to load the new recipes, if there are any: \(nextUrl)")
            
            Network.shared.getRecipes(url: nextUrl) { (response) in
                switch response {
                case .success((let rcps, let nxtUrl)):
                    if let newRecipes = rcps {
                        var indexPaths: [IndexPath] = []
                        let prevLastIndex = self.recipes.count - 1
                        for i in 1...newRecipes.count {
                            let indexPath = IndexPath(item: prevLastIndex + i, section: 0)
                            indexPaths.append(indexPath)
                        }
                        self.recipes.append(contentsOf: newRecipes)
                        self.collectionView.insertItems(at: indexPaths)
                        
                        self.spinner.stopAnimating()
                        self.spinnerHolder.isHidden = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            // have to set this false after a second or sometimes two pages of data can be loaded at same time (not the same page twice, but still not ideal)
                            self.loadingMoreRecipes = false
                        }
                    }
                    self.nextUrl = nxtUrl
                case .failure(_):
                    self.spinner.stopAnimating()
                    self.spinnerHolder.isHidden = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        self.loadingMoreRecipes = false // see if there is a connection then
                    }
                }
            }
        }
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
            if delegate != nil {
                delegate.searchTextChanged(text: "")
            }
            
        } else {
            print("Need different search, saved recipes is active")
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if savedRecipesActive == true {
            filteredSavedRecipes = Recipe.filterSavedRecipesFrom(text: searchText, savedRecipes: savedRecipes)
        } else {
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

// MARK: CreateNewItemDelegate
extension RecipeHomeVC: CreateNewItemDelegate {
    func searchCreated(search: NetworkSearch) {
        
        searchQueue.insert(search, at: 0)
        searchBar.text = searchBar.text?.updateSearchText(newItem: search.text)
        searchQueue = Network.getSearchesFromText(text: searchBar.text ?? "", currSearches: searchQueue)
        textAssistantViewActive = false
        
    }
    func itemCreated(item: Item) {}
    
}


// MARK: AdvancedSearchViewDelegate {
extension RecipeHomeVC: AdvancedSearchViewDelegate {
    func searchesSent(searches: [NetworkSearch]) {
        searchBar.text = ""
        searchQueue = searches
        activeSearches = searchQueue
        searchQueue = []
        searchBar.text = ""
        if delegate != nil {
            delegate.searchTextChanged(text: "")
        }
        #warning("need to search like normal here")
    }
}

// MARK: SkeletonView
extension RecipeHomeVC: SkeletonCollectionViewDataSource {
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "recipeCell"
    }
    func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    private func stopSkeleton() {
        skeletonViewActive = false
        collectionView.hideSkeleton()
        collectionView.stopSkeletonAnimation()
    }
    
    private func startSkeleton() {
        collectionView.setContentOffset(CGPoint(x:0,y:0), animated: false)
        collectionView.showAnimatedGradientSkeleton()
        collectionView.startSkeletonAnimation()
        skeletonViewActive = true
    }
    
}

extension RecipeHomeVC: NoConnectionViewDelegate {
    func tryAgain() {
        // remove all the searches, remove the noConnectionView, reload a random page of recipes
        #warning("need to do this")
        
    }
}
