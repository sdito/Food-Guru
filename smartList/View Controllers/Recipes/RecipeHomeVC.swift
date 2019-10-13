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
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchHelperView: UIView!
    
    var imageCache = NSCache<NSString, UIImage>()
    
    var db: Firestore!
    
    var recipes: [Recipe] = [] {
        didSet {
            collectionView.reloadData()
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
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
        Recipe.readUserRecipes(db: db) { (recipesReturned) in
            self.recipes = recipesReturned
        }
        let layout = collectionView.collectionViewLayout as! DynamicHeightLayout
        layout.numberOfColumns = 2
        layout.delegate = self
        
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showRecipeDetail" {
            let destVC = segue.destination as! RecipeDetailVC
            destVC.data = sender as? (UIImage, Recipe)
        }
    }
}


extension RecipeHomeVC: DynamicHeightLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForTextAtIndexPath indexPath: IndexPath, withWidth width: CGFloat) -> CGFloat {
        let textData = recipes[indexPath.item]
        let title = heightForText(textData.name, width: width - 8, font: UIFont(name: "futura", size: 20)!)
        let cuisine = heightForText(textData.cuisineType, width: width - 8, font: UIFont(name: "futura", size: 17)!)
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
}
