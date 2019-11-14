//
//  CookbookVC.swift
//  smartList
//
//  Created by Steven Dito on 11/3/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import UIKit
import RealmSwift


class CookbookVC: UIViewController {
    
    private var lastContentOffset: CGFloat = 0
    private var recipes: [CookbookRecipe] = [] {
        didSet {
            print(self.recipes.map({$0.name}))
            tableView.reloadData()
        }
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var scrollBackUpView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let realm = try! Realm()
        searchBar.setTextProperties()
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        recipes = Array(realm.objects(CookbookRecipe.self))
        scrollBackUpView.shadowAndRounded(cornerRadius: 10)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        let realm = try! Realm()
        recipes = Array(realm.objects(CookbookRecipe.self))
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showFromCookbook" {
            let destVC = segue.destination as! RecipeDetailVC
            destVC.cookbookRecipe = sender as? CookbookRecipe
        }
    }
    
    @IBAction func savedRecipes(_ sender: Any) {
        print("Saved recipes")
        
    }
    
    
    @IBAction func allRecipes(_ sender: Any) {
        print("All recipes")
        self.dismiss(animated: false, completion: nil)
        
    }
    
}

extension CookbookVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if recipes.count != 0 {
            return recipes.count
        } else {
            return 1
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if recipes.count != 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cookbookCell") as! CookbookCell
            let recipe = recipes[indexPath.row]
            cell.setUI(recipe: recipe)
            return cell
        } else {
            let cell: UITableViewCell = .init(style: .default, reuseIdentifier: nil)
            cell.textLabel?.font = UIFont(name: "futura", size: 17)
            cell.textLabel?.text = "No recipes saved to your cookbook! Add a recipe to your cookbook to always have your recipes, even without an internet connection."
            cell.textLabel?.numberOfLines = 0
            return cell
        }
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if recipes.count != 0 {
            let recipe = recipes[indexPath.row]
            performSegue(withIdentifier: "showFromCookbook", sender: recipe)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if recipes.count != 0 {
            return true
        } else {
            return false
        }
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if recipes.count != 0 {
            let item = recipes[indexPath.row]
            let alert = UIAlertController(title: "Are you sure you want to delete \"\(item.name)\"", message: nil, preferredStyle: .alert)
            alert.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(.init(title: "Delete", style: .destructive, handler: {_ in self.deleteSelectedRecipe(recipe: item, idx: indexPath.row)}))
            self.present(alert, animated: true)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("Scrollviewdidscroll")
        if (self.lastContentOffset > scrollView.contentOffset.y) {
            if scrollView.contentOffset.y >= 0 {
                scrollBackUpView.setIsHidden(false, animated: true)
            }
            
            else if scrollView.contentOffset.y <= 0 {}
            else if (self.lastContentOffset < scrollView.contentOffset.y) {
                scrollBackUpView.setIsHidden(true, animated: true)
            }
            self.lastContentOffset = scrollView.contentOffset.y
        }
    }
    private func deleteSelectedRecipe(recipe: CookbookRecipe, idx: Int) {
        let realm = try! Realm()
        recipe.delete()
        recipes = Array(realm.objects(CookbookRecipe.self))
    }
}


extension CookbookVC: UISearchBarDelegate {
    
}
