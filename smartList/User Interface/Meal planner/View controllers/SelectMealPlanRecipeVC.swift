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
    private var nextUrl: String?
    private var loadingMoreRecipes = false
    private var recipeSelectionUsed: RecipeSelection?
    @IBOutlet weak var bottomViewChangeHeight: UIView!
    @IBOutlet weak var tableView: UITableView!
    private let standardPageSize = 30
    
    private var recipes: [Any] = [] {
        didSet {
            if self.recipes.count <= standardPageSize {
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
        self.recipeSelectionUsed = recipeSelection
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
            Network.shared.getRecipes(searches: nil) { (response) in
                switch response {
                    
                case .success((let rcps, let nxtUrl, let numberRecipesFound)):
                    if let rcps = rcps {
                        self.recipes = rcps
                        self.dismiss(animated: false, completion: nil)
                        
                    }
                    self.nextUrl = nxtUrl
                case .failure(_):
                    self.dismiss(animated: false, completion: nil)
                }
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
                MealPlanner.addRecipeToPlanner(db: db, recipe: mpr, shortDate: shortDate, mealType: .none, previousID: nil)
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
                MealPlanner.addRecipeToPlanner(db: db, recipe: mpr, shortDate: shortDate, mealType: .none, previousID: r.mainImage?.imagePathToDocID())
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
        
        if let rs = recipeSelectionUsed {
            if rs == .all {
                if indexPath.row + 1 == recipes.count {
                    
                    if let nextUrl = nextUrl, !loadingMoreRecipes {
                        loadingMoreRecipes = true
                        Network.shared.getRecipes(url: nextUrl) { (response) in
                            switch response {
                            case .success((let rcps, let nextUrl, _)):
                                if let rcps = rcps {
                                    self.recipes += rcps
                                    self.tableView.beginUpdates()
                                    // get the index of the first newly added item, and the indexPath of the last item
                                    let lastIdx = self.recipes.count
                                    let prevIdx = lastIdx - rcps.count
                                    let indexPaths: [IndexPath] = (prevIdx..<lastIdx).map({IndexPath(row: $0, section: 0)})
                                    self.tableView.insertRows(at: indexPaths, with: .automatic)
                                    self.tableView.endUpdates()
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        self.loadingMoreRecipes = false
                                    }
                                }
                                self.nextUrl = nextUrl
                            case .failure(_):
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    self.loadingMoreRecipes = false
                                }
                                return
                            }
                        }
                    }
                }
            }
        }
    }
    
}
