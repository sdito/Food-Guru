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
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension CookbookVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cookbookCell") as! CookbookCell
        let recipe = recipes[indexPath.row]
        cell.setUI(recipe: recipe)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let recipe = recipes[indexPath.row]
        performSegue(withIdentifier: "showFromCookbook", sender: recipe)
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
}


extension CookbookVC: UISearchBarDelegate {
    
}
