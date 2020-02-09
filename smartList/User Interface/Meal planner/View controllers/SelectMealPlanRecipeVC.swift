//
//  SelectMealPlanRecipeVC.swift
//  smartList
//
//  Created by Steven Dito on 2/7/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit
import RealmSwift
import FirebaseFirestore

class SelectMealPlanRecipeVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var recipes: [Any] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    var db: Firestore!
    var recipeSelection: (RecipeSelection?, String?)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        tableView.delegate = self
        tableView.dataSource = self
        setRecipesForCells(recipeSelection: recipeSelection.0 ?? .all)
        
        if let date = recipeSelection.1?.shortDateToDisplay() {
            self.navigationItem.prompt = date
        }
    }
    
    private func setRecipesForCells(recipeSelection: RecipeSelection) {
        switch recipeSelection {
        case .cookbook:
            if let realm = try? Realm() {
                recipes = Array(realm.objects(CookbookRecipe.self))
            }
        case .saved:
            Recipe.readUserSavedRecipes(db: db) { (rcps) in
                self.recipes = rcps
            }
        case .all:
            #warning("need to do")
            return
        }
    }
}

// MARK: SelectRecipeCellDelegate
extension SelectMealPlanRecipeVC: SelectRecipeCellDelegate {
    func presentRecipeDetail(cookbookRecipe: CookbookRecipe?, recipe: Recipe?) {
        let sb = UIStoryboard(name: "Recipes", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "recipeDetailVC") as! RecipeDetailVC
        
        if let cbr = cookbookRecipe {
            vc.cookbookRecipe = cbr
        } else if let r = recipe {
            vc.data = (nil, r)
        }
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
}




// MARK: Table view
extension SelectMealPlanRecipeVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "selectRecipeCell") as! SelectRecipeCell
        let recipe = recipes[indexPath.row]
        cell.delegate = self
        cell.setUI(recipe: recipe)
        return cell
    }
    
    
}
