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
    @IBOutlet weak var tableView: UITableView!
    
    var db: Firestore!
    
    var recipes: [Recipe] = [] {
        didSet {
            tableView.reloadData()
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        db = Firestore.firestore()
        Recipe.readUserRecipes(db: db) { (recipesReturned) in
            self.recipes = recipesReturned
        }
    }
    
}

extension RecipeHomeVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let recipe = recipes[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "recipeShowCell", for: indexPath) as! RecipeShowCell
        cell.setUI(recipe: recipe)
        return cell
    }
    
    
}
