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
    
    var mealPlanner: MealPlanner?
    
    @IBOutlet weak var tableView: UITableView!
    
    private var recipes: [Any] = [] {
        didSet {
            tableView.reloadData()
            if self.recipes.isEmpty {
                var txt: String {
                    if let rs = recipeSelection.0 {
                        switch rs {
                        case .cookbook:
                            return "No recipes in your cookbook. To add recipes to your coobook select 'download' from a recipe or create your own recipe. Cookbook recipes are saved on your device."
                        case .saved:
                            return "You don't have any saved recipes. To save a recipe, press the heart on the top of a recipe in the recipes feed!"
                        }
                    } else {
                        return "Couldn't find your recipes."
                    }
                }
                let alert = UIAlertController(title: txt, message: nil, preferredStyle: .alert)
                alert.addAction(.init(title: "Ok", style: .default, handler: { (alert) in
                    self.navigationController?.popViewController(animated: true)
                }))
                self.present(alert, animated: true)
            }
        }
    }
    
    var db: Firestore!
    var recipeSelection: (RecipeSelection?, String?)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        tableView.delegate = self
        tableView.dataSource = self
        setRecipesForCells(recipeSelection: recipeSelection.0 ?? .cookbook)
        
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
        }
    }
}

// MARK: SelectRecipeCellDelegate
extension SelectMealPlanRecipeVC: SelectRecipeCellDelegate {
    func recipeToAdd(recipe: Any) {
        if let r = recipe as? CookbookRecipe {
            let mpr = MPCookbookRecipe()
            mpr.setUp(name: r.name, servings: r.servings, cookTime: r.cookTime, prepTime: r.prepTime, calories: r.calories, ingredients: r.ingredients, instructions: r.instructions, notes: r.notes)
            
            
            if let date = recipeSelection.1 {
                mpr.date = date
            }
            if let shortDate = recipeSelection.1 {
                mealPlanner?.addRecipeToPlanner(recipe: mpr, shortDate: shortDate, mealType: .none)
            }
            
            self.navigationController?.createMessageView(color: Colors.messageGreen, text: "Recipe added to planner!")
        } else if let r = recipe as? Recipe {
//            #error("need to complete this now")
            let cbr = r.turnRecipeIntoCookbookRecipe()
            let mpr = MPCookbookRecipe()
            mpr.setUp(name: cbr.name, servings: cbr.servings, cookTime: cbr.cookTime, prepTime: cbr.prepTime, calories: cbr.calories, ingredients: cbr.ingredients, instructions: cbr.instructions, notes: cbr.notes)
            if let date = recipeSelection.1 {
                mpr.date = date
            }
            if let shortDate = recipeSelection.1 {
                mealPlanner?.addRecipeToPlanner(recipe: mpr, shortDate: shortDate, mealType: .none)
            }
            print("Normal Recipe type, need to add: \(r.name) to stuff here")
            self.navigationController?.createMessageView(color: Colors.messageGreen, text: "Recipe added to planner!")
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
