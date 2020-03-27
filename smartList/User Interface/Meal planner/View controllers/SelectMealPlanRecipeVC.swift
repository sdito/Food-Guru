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
    private let pageCount = 25
    @IBOutlet weak var bottomViewChangeHeight: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    private var recipes: [Any] = [] {
        didSet {
            if self.recipes.count <= pageCount {
                tableView.reloadData()
            }
            if self.recipes.isEmpty {
                var txt: String {
                    if let rs = recipeSelection.0 {
                        switch rs {
                        case .cookbook:
                            return "No recipes in your cookbook. To add recipes to your coobook select 'download' from a recipe or create your own recipe. Cookbook recipes are saved on your device."
                        case .saved:
                            return "You don't have any saved recipes. To save a recipe, press the heart on the top of a recipe in the recipes feed!"
                        case .all:
                            return "Error finding recipes, please try again."
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
    private var lastDocument: QueryDocumentSnapshot?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        tableView.delegate = self
        tableView.dataSource = self
        setRecipesForCells(recipeSelection: recipeSelection.0 ?? .cookbook)
        bottomViewChangeHeight.translatesAutoresizingMaskIntoConstraints = false; bottomViewChangeHeight.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
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
            self.createLoadingView()
            Recipe.readUserSavedRecipes(db: db) { (rcps) in
                self.recipes = rcps
                self.dismiss(animated: false, completion: nil)
            }
        case .all:
            self.createLoadingView()
            Recipe.getNRecipes(num: pageCount, db: db, lastDoc: lastDocument) { (rcps, lastDocument)  in
                self.recipes = rcps
                self.lastDocument = lastDocument
                self.dismiss(animated: false, completion: nil)
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
                mealPlanner?.addRecipeToPlanner(recipe: mpr, shortDate: shortDate, mealType: .none, previousID: nil)
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
                mealPlanner?.addRecipeToPlanner(recipe: mpr, shortDate: shortDate, mealType: .none, previousID: r.imagePath?.imagePathToDocID())
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
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == recipes.count {
            print("load more recipes")
            
            Recipe.getNRecipes(num: pageCount, db: db, lastDoc: lastDocument) { (rcps, lastDocument) in
                
                if !rcps.isEmpty {
                    self.recipes += rcps
                    self.lastDocument = lastDocument
                    
                    self.tableView.beginUpdates()
                    
                    // get the index of the first newly added item, and the indexPath of the last item
                    let lastIdx = self.recipes.count
                    let prevIdx = lastIdx - rcps.count
                    
                    let indexPaths: [IndexPath] = (prevIdx..<lastIdx).map({IndexPath(row: $0, section: 0)})
                    self.tableView.insertRows(at: indexPaths, with: .automatic)
                    
                    self.tableView.endUpdates()
                    
                }
            }
        }
    }
}
