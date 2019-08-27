//
//  SelectRecipeTypeVC.swift
//  smartList
//
//  Created by Steven Dito on 8/26/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import UIKit

class SelectRecipeTypeVC: UIViewController {

    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var topLabel: UILabel!
    
    private var typesSelected: Set<String> = [] {
        didSet {
            topLabel.text = self.typesSelected.sorted().joined(separator: ", ")
        }
    }
    
    private var allTypes: [String] = RecipeType.allItems {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillDisappear(animated)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        topView.setGradientBackground(colorOne: Colors.main, colorTwo: Colors.mainGradient)
    }
    
    @IBAction func exit(_ sender: Any) {
        SelectRecipeTypeVC.popUp.popOverVC.view.removeFromSuperview()
    }
    
    struct popUp {
        static let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "recipeType") as! SelectRecipeTypeVC
    }
}


extension SelectRecipeTypeVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("called")
        allTypes = RecipeType.allItems
        allTypes = allTypes.filter({ (type) -> Bool in
            type.starts(with: searchBar.text!)
        })
    }
}


extension SelectRecipeTypeVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allTypes.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recipeType") as! RecipeTypeCell
        let type = allTypes[indexPath.row]
        cell.setUI(type: type, set: typesSelected)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let item = allTypes[indexPath.row]
        if typesSelected.contains(item) == false {
            typesSelected.insert(allTypes[indexPath.row])
        } else {
            typesSelected.remove(allTypes[indexPath.row])
        }
        
        searchBar.text = ""
        allTypes = RecipeType.allItems
        print(typesSelected)
    }
    
    
}
