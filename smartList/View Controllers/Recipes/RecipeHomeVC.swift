//
//  RecipeHomeVC.swift
//  smartList
//
//  Created by Steven Dito on 9/5/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import UIKit
import FirebaseFirestore


class RecipeHomeVC: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    var db: Firestore!
    
    var recipes: [Recipe] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        db = Firestore.firestore()
        Recipe.readUserRecipes(db: db) { (recipesReturned) in
            self.recipes = recipesReturned
        }
        
    }
    
}

extension RecipeHomeVC: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recipes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "recipeShow", for: indexPath) as! RecipeShowCell
        let recipe = recipes[indexPath.row]
        cell.setUI(recipe: recipe)
        return cell
    }
    
}
