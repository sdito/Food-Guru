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
    private let v = Bundle.main.loadNibNamed("CurrentSearchesView", owner: nil, options: nil)?.first as! CurrentSearchesView
    private var activeSearches: [(String, SearchType)] = [] {
        didSet {
            Search.find(from: self.activeSearches, db: db) { (rcps) in
                if let rcps = rcps {
                    print(rcps.map({$0.name}))
                }
            }
            let strings = self.activeSearches.map({$0.0})
            if wholeStackView.subviews.contains(v) {
                v.setUI(searches: strings)
            } else {
                wholeStackView.insertArrangedSubview(v, at: 1)
                v.setUI(searches: strings)
            }
            
        }
    }
    
    @IBOutlet weak var wholeStackView: UIStackView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchHelperView: UIView!
    @IBOutlet weak var searchButtonStackView: UIStackView!
    @IBOutlet weak var scrollBackUpView: UIView!
    private var lastContentOffset: CGFloat = 0
    private var allowButtonToBeShowed = true
    var imageCache = NSCache<NSString, UIImage>()
    
    var db: Firestore!
    
    var recipes: [Recipe] = [] {
        didSet {
            collectionView?.reloadData()
            collectionView?.collectionViewLayout.invalidateLayout()
            
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        handleRecipesToShow()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        searchBar.delegate = self
        searchBar.setTextProperties()
        searchBar.setUpToolBar(action: #selector(keyboardDismissed))
        
        db = Firestore.firestore()
        
        
        let layout = collectionView.collectionViewLayout as! DynamicHeightLayout
        layout.numberOfColumns = 2
        layout.delegate = self
        
        searchButtonStackView.setUpQuickSearchButtons()
        createObserver()
        scrollBackUpView.shadowAndRounded(cornerRadius: 10)
        
    }
    
    @IBAction func scrollBackUp(_ sender: Any) {
        allowButtonToBeShowed = false
        collectionView.setContentOffset(.init(x: 0, y: 0), animated: true)
        lastContentOffset = 0
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.allowButtonToBeShowed = true
        }
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showRecipeDetail" {
            let destVC = segue.destination as! RecipeDetailVC
            destVC.data = sender as? (UIImage, Recipe)
        }
    }
    
    private func createObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(recipeButtonPressed), name: .recipeSearchButtonPressed, object: nil)
    }
    
    @objc func recipeButtonPressed(_ notification: NSNotification) {
        handleSuggestedSearchButtonBeingPressed()
        if let dict = notification.userInfo as NSDictionary? {
            if let buttonName = dict["buttonName"] as? (String, SearchType) {
                if buttonName.0 != "Select ingredients" {activeSearches.append(buttonName)}
                Search.recipeSearchSuggested(buttonName: buttonName.0, db: db, calledFromVC: self) { (searchRecipes) in
                    if let searchRecipes = searchRecipes {
                        self.imageCache.removeAllObjects()
                        self.recipes = searchRecipes
                    }
                }
            }
        }
    }
    private func handleSuggestedSearchButtonBeingPressed() {
        
        //v.heightAnchor.constraint(equalToConstant: (searchBar.bounds.height * 0.8)).isActive = true
        wholeStackView.insertArrangedSubview(v, at: 1)
        searchBar.endEditing(true)
        searchHelperView.isHidden = true
    }
    
    private func handleRecipesToShow() {
        if SharedValues.shared.sentRecipesInto == nil {
            if recipes.isEmpty {
                Recipe.readUserRecipes(db: db) { (recipesReturned) in
                    self.recipes = recipesReturned
                }
            }
        } else {
            recipes = SharedValues.shared.sentRecipesInto!.recipes
            activeSearches = SharedValues.shared.sentRecipesInto!.ingredients.map({($0, .ingredient)})
            imageCache.removeAllObjects()
            SharedValues.shared.sentRecipesInto = nil
            //#error("first search after getting recipes and info from storage does not show properly on RecipeHomeScreen")
        }
    }
    
}



extension RecipeHomeVC: RecipesFoundFromSearchingDelegate {
    func recipesFound(recipes: [Recipe], ingredients: [String]) {
        self.imageCache.removeAllObjects()
        self.recipes = recipes
        self.dismiss(animated: true, completion: nil)
        let displayIngredients = ingredients.map { (ing) -> GenericItem in GenericItem.init(rawValue: ing)!}.map { (gi) -> String in gi.description}
        activeSearches += displayIngredients.map({($0, .ingredient)})
    }
}

extension RecipeHomeVC: DynamicHeightLayoutDelegate {
    #warning("issue with how much to subtract from the text labels, was 8 previously for title and cuisine and changed it to 10")
    func collectionView(_ collectionView: UICollectionView, heightForTextAtIndexPath indexPath: IndexPath, withWidth width: CGFloat) -> CGFloat {
        let textData = recipes[indexPath.item]
        let title = heightForText(textData.name, width: width - 10, font: UIFont(name: "futura", size: 20)!)
        let cuisine = heightForText(textData.cuisineType, width: width - 10, font: UIFont(name: "futura", size: 17)!)
        let description = heightForText(textData.recipeType.joined(separator: ", "), width: width - 10, font: UIFont(name: "futura", size: 15)!)
        return title + cuisine + description + 8
        
    }
    func heightForText(_ text: String, width: CGFloat, font: UIFont) -> CGFloat {
        let rect = NSString(string: text).boundingRect(with: CGSize(width: width, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return ceil(rect.height)
    }
}


extension RecipeHomeVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recipes.count
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selected = recipes[indexPath.item]
        print(selected.name)
        performSegue(withIdentifier: "showRecipeDetail", sender: (imageCache.object(forKey: "\(indexPath.row)" as NSString), selected))
        
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let recipe = recipes[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "recipeCell", for: indexPath) as! RecipeCell
        cell.setUI(recipe: recipe)
        
        // pull the image from the cache if possible, if not pull from cloud storage
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (self.lastContentOffset > scrollView.contentOffset.y + 10) {
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

extension RecipeHomeVC: UISearchBarDelegate {
    @objc func keyboardDismissed() {
        searchBar.endEditing(true)
        searchHelperView.isHidden = true
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        print("searchBartextDidBeginEditing")
        searchHelperView.isHidden = false
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let s = Search.searchFromSearchBar(string: searchBar.text!)
        activeSearches += s
    }
}
