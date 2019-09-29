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
        db = Firestore.firestore()
        Recipe.readUserRecipes(db: db) { (recipesReturned) in
            self.recipes = recipesReturned
        }
        let layout = collectionView.collectionViewLayout as! DynamicHeightLayout
        layout.numberOfColumns = 2
        layout.delegate = self
    }
    
}


extension RecipeHomeVC: DynamicHeightLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForTextAtIndexPath indexPath: IndexPath, withWidth width: CGFloat) -> CGFloat {
        //let random = arc4random_uniform(4) + 1
        let textData = recipes[indexPath.item]
        let title = heightForText(textData.name, width: width, font: UIFont(name: "futura", size: 20)!, oneSidePadding: 4)
        let cuisine = heightForText(textData.cuisineType, width: width, font: UIFont(name: "futura", size: 17)!, oneSidePadding: 4)
        let description = heightForText(textData.recipeType.joined(separator: ", "), width: width, font: UIFont(name: "futura", size: 15)!, oneSidePadding: 4)
        return title + cuisine + description + 8
        
    }
    func heightForText(_ text: String, width: CGFloat, font: UIFont, oneSidePadding: Int) -> CGFloat {
        let rect = NSString(string: text).boundingRect(with: CGSize(width: width, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return ceil(rect.height)
    }
}


extension RecipeHomeVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recipes.count
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
            recipe.getImageFromStorage { (img) in
                cell.recipeImage.image = img
                self.imageCache.setObject(img!, forKey: "\(indexPath.row)" as NSString)
                print("Read for \(indexPath.row)")
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let v = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "reusableView", for: indexPath) as! RecipeReusableView
        return v
        
    }
}
