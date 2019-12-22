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
    private let currentSearchesView = Bundle.main.loadNibNamed("CurrentSearchesView", owner: nil, options: nil)?.first as! CurrentSearchesView
    private var lastContentOffset: CGFloat = 0
    
    
    private var filteredRecipes: [CookbookRecipe] = [] {
        didSet {
            print(currentSearches.map({$0.0}))
            tableView.reloadData()
        }
    }
    private var recipes: [CookbookRecipe] = [] {
        didSet {
            print(self.recipes.map({$0.name}))
            tableView.reloadData()
        }
    }
    
    private var currentSearches: [(String, SearchType)] = [] {
        didSet {
            print("Current searches set: \(self.currentSearches)")
            filteredRecipes = recipes.filterRecipes(from: self.currentSearches.map({$0.0}))
            if self.view.subviews.contains(currentSearchesView) {
                print("Already contains")
                currentSearchesView.setUI(searches: self.currentSearches)
            } else {
                // add the view
                wholeStackView.insertArrangedSubview(currentSearchesView, at: 1)
                currentSearchesView.setUI(searches: self.currentSearches)
            }
            
            if self.currentSearches.isEmpty {
                searchBar.placeholder = "Filter recipes"
            } else {
                searchBar.placeholder = "Add another search"
            }
        }
    }
    
    @IBOutlet weak var searchHelperView: UIView!
    @IBOutlet weak var searchHelperSV: UIStackView!
    @IBOutlet weak var wholeStackView: UIStackView!
    
    
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
        
        scrollBackUpView.shadowAndRounded(cornerRadius: 10, border: false)
        
        
        if #available(iOS 13.0, *) {
            self.view.backgroundColor = .systemBackground
        } else {
            self.view.backgroundColor = .white
        }
        searchHelperView.isHidden = true
        searchHelperSV.setUpQuickSearchButtonsForCookbook()
        addSelectors(sv: searchHelperSV)
        currentSearchesView.delegate = self
        searchBar.setUpAddItemToolbar(cancelAction: #selector(cancelSelector), addAction: #selector(addSelector))
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        let realm = try! Realm()
        recipes = Array(realm.objects(CookbookRecipe.self))
        filteredRecipes = recipes
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
//        self.dismiss(animated: false, completion: nil)
        tabBarController?.selectedIndex = 0
        NotificationCenter.default.post(name: .haveSavedRecipesAppear, object: nil)
        
    }
    
    
    @IBAction func allRecipes(_ sender: Any) {
        tabBarController?.selectedIndex = 0
//        self.dismiss(animated: false, completion: nil)
        
    }
    @objc private func cancelSelector() {
        searchBar.text = ""
        searchBar.endEditing(true)
    }
    @objc private func addSelector() {
        print("add selector")
        search()
    }
    
    @objc private func searchPressed(sender: UIButton) {
        print(sender.titleLabel?.text as Any)
        
        if let text = sender.titleLabel?.text {
            let search = Search.searchFromSearchBar(string: text)
            currentSearches += search
        }
        
        searchHelperView.isHidden = true
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

extension CookbookVC: CurrentSearchesViewDelegate {
    func buttonPressedToDeleteSearch(index: Int) {
        currentSearches.remove(at: index)
    }
}

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
            cell.textLabel?.text = "No recipes saved to your cookbook! Add a recipe to your cookbook to always have your recipes, even without an internet connection."
            cell.textLabel?.numberOfLines = 0
            return cell
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if recipes.count != 0 {
            let item = filteredRecipes[indexPath.row]
            let alert = UIAlertController(title: "Are you sure you want to delete \"\(item.name)\"", message: nil, preferredStyle: .alert)
            alert.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(.init(title: "Delete", style: .destructive, handler: {_ in self.deleteSelectedRecipe(recipe: item, idx: indexPath.row)}))
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
    
    private func deleteSelectedRecipe(recipe: CookbookRecipe, idx: Int) {
        let realm = try! Realm()
        recipe.delete()
        recipes = Array(realm.objects(CookbookRecipe.self))
    }
}


extension CookbookVC: UISearchBarDelegate {
    func search() {
        print(searchBar.text!)
        searchBar.text = ""
        searchBar.endEditing(true)
        searchHelperView.isHidden = true
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        currentSearches.removeAll()
        if searchText == "" {
            searchHelperView.isHidden = false
            filteredRecipes = recipes
        } else {
            searchHelperView.isHidden = true
            filteredRecipes = recipes.filter({$0.name.lowercased().contains(searchBar.text!.lowercased())})
        }
        
        
        
        
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        print("Search bar did begin editing")
        searchHelperView.isHidden = false
    }
}
