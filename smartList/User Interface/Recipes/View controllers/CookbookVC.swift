//
//  CookbookVC.swift
//  smartList
//
//  Created by Steven Dito on 11/3/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import UIKit
import RealmSwift
import FirebaseFirestore


class CookbookVC: UIViewController {
    
    @IBOutlet weak var cookbookOutlet: UIButton!
    @IBOutlet weak var wholeStackView: UIStackView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var scrollBackUpView: UIView!
    
    private var lastContentOffset: CGFloat = 0
    private var filteredRecipes: [CookbookRecipe] = []
    private var recipes: [CookbookRecipe] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.setTextProperties()
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
        
        self.view.backgroundColor = Colors.systemBackground
        searchBar.setUpAddItemToolbar(cancelAction: #selector(cancelSelector), addAction: #selector(addSelector))
        cookbookOutlet.handleSelectedForBottomTab(selected: true)
        
        scrollBackUpView.layoutIfNeeded()
        scrollBackUpView.shadowAndRounded(cornerRadius: 10, border: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        let realm = try! Realm()
        recipes = Array(realm.objects(CookbookRecipe.self))
        filteredRecipes = recipes
        tableView.reloadData()
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
    // MARK: @IBAction funcs
    @IBAction func savedRecipes(_ sender: Any) {
        tabBarController?.selectedIndex = 0
        NotificationCenter.default.post(name: .haveSavedRecipesAppear, object: nil, userInfo: ["haveSavedRecipesShow": true])
    }
    
    @IBAction func allRecipes(_ sender: Any) {
        tabBarController?.selectedIndex = 0
        NotificationCenter.default.post(name: .haveSavedRecipesAppear, object: nil, userInfo: ["haveSavedRecipesShow": false])
        
    }
    // MARK: functions
    @objc private func cancelSelector() {
        searchBar.endEditing(true)
        searchBar.text = ""
        filteredRecipes = recipes
    }
    
    @objc private func addSelector() {
        search()
    }
    
    @objc private func searchPressed(sender: UIButton) {
        searchBar.endEditing(true)
    }
    
    private func addSelectors(sv: UIStackView) {
        sv.subviews.forEach { (v) in
            if type(of: v) == UIButton.self {
                (v as! UIButton).addTarget(self, action: #selector(searchPressed), for: .touchUpInside)
            }
        }
    }
    
}

// MARK: Table view
extension CookbookVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if recipes.count != 0 {
            return filteredRecipes.count
        } else {
            return 1
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if recipes.count != 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cookbookCell") as! CookbookCell
            let recipe = filteredRecipes[indexPath.row]
            cell.setUI(recipe: recipe, systemItems: SharedValues.shared.currentItemsInStorage ?? [])
            return cell
        } else {
            let cell: UITableViewCell = .init(style: .default, reuseIdentifier: nil)
            cell.textLabel?.font = UIFont(name: "futura", size: 17)
            cell.textLabel?.text = "No recipes saved to your cookbook! Add a recipe to your cookbook to always have your recipes, even without an internet connection. Cookbook recipes are private and will only be on your device."
            cell.textLabel?.numberOfLines = 0
            return cell
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        if recipes.count != 0 {
            let recipe = filteredRecipes[indexPath.row]
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
            let item = filteredRecipes[indexPath.row]
            let alert = UIAlertController(title: "Are you sure you want to delete \"\(item.name)\"", message: nil, preferredStyle: .alert)
            alert.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(.init(title: "Delete", style: .destructive, handler: {_ in self.deleteSelectedRecipe(recipe: item, idx: indexPath)}))
            self.present(alert, animated: true)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
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
    
    private func deleteSelectedRecipe(recipe: CookbookRecipe, idx: IndexPath) {
        let realm = try! Realm()
        recipe.delete()
        filteredRecipes = Array(realm.objects(CookbookRecipe.self))
        searchBar.text = ""
        searchBar.endEditing(true)
        tableView.reloadData()
        
//        tableView.cellForRow(at: idx)?.isHidden = true
        
    }
}

// MARK: Search bar
extension CookbookVC: UISearchBarDelegate {
    func search() {
        searchBar.endEditing(true)
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            filteredRecipes = recipes
            tableView.reloadData()
        } else {
            filteredRecipes = recipes.filter({$0.name.lowercased().contains(searchBar.text!.lowercased())})
            tableView.reloadData()
        }
    }
    
}
