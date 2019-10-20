//
//  SearchByIngredientVC.swift
//  smartList
//
//  Created by Steven Dito on 10/18/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import UIKit
import FirebaseFirestore




protocol SearchAssistantDelegate {
    func searchTextChanged(text: String)
    func removeChildVC()
}




class SearchByIngredientVC: UIViewController {
    var delegate: SearchAssistantDelegate!
    private var selectedItems: [Item] = [] {
        didSet {
            if self.selectedItems.isEmpty == false {
                let display = self.selectedItems.map { (itm) -> String in itm.name}.joined(separator: ", ")
                buttonOutlet.setTitle("Find recipe with \(display)", for: .normal)
                buttonOutlet.isUserInteractionEnabled = true
                buttonOutlet.setTitleColor(Colors.main, for: .normal)
            } else {
                buttonOutlet.setTitle("Select or add ingredients", for: .normal)
                buttonOutlet.isUserInteractionEnabled = false
                if #available(iOS 13.0, *) {
                    buttonOutlet.setTitleColor(.label, for: .normal)
                } else {
                    buttonOutlet.setTitleColor(.black, for: .normal)
                }
            }
        }
    }
    private var possibleItems: [Item] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    var db: Firestore!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var buttonOutlet: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        searchBar.setTextProperties()
        buttonOutlet.isUserInteractionEnabled = false
        buttonOutlet.titleLabel?.numberOfLines = 2
        buttonOutlet.titleLabel?.textAlignment = .center
        Item.readItemsForStorageNoListener(db: db, storageID: SharedValues.shared.foodStorageID ?? " ") { (itms) in
            self.possibleItems = itms
        }
        searchBar.setUpAddItemToolbar(cancelAction: #selector(cancelSelector), addAction: #selector(addSelector))
    }
    
    
    
    @IBAction func buttonAction(_ sender: Any) {
        let ingredients = selectedItems.map { (itm) -> GenericItem in
            itm.systemItem!
        }.map { (genericItem) -> String in
            genericItem.rawValue
        }
        print(ingredients)
        Search.getRecipesFromIngredients(db: db, ingredients: ingredients) { (recipesReturned) in
            for recipe in recipesReturned! {
                print(recipe.name)
            }
        }
    }
    
    @IBAction func addItem(_ sender: Any) {
        //#error("need to get create item vc to be proper size")
        searchBar.isHidden = false
        searchBar.becomeFirstResponder()
        let vc = storyboard?.instantiateViewController(withIdentifier: "createNewItemVC") as! CreateNewItemVC
        self.addChild(vc)
        self.view.addSubview(vc.tableView)
        vc.didMove(toParent: self)
        vc.tableView.translatesAutoresizingMaskIntoConstraints = false
        vc.tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor).isActive = true
        
        #warning("need to get the actual keyboard height below")
        vc.tableView.heightAnchor.constraint(equalToConstant: (self.view.bounds.height - searchBar.bounds.height - 300)).isActive = true
        vc.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        vc.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        vc.delegate = self
        delegate = vc
    }
    
}

extension SearchByIngredientVC: CreateNewItemDelegate {
    func itemCreated(item: Item) {
        possibleItems.append(item)
        selectedItems.append(item)
        searchBar.text = ""
        searchBar.isHidden = true
        
        
        for item in selectedItems {
            if let row = possibleItems.firstIndex(of: item) {
                tableView.selectRow(at: IndexPath(row: row, section: 0), animated: false, scrollPosition: .none)
            }
        }
        //tableView.selectRow(at: IndexPath(row: possibleItems.count - 1, section: 0), animated: false, scrollPosition: .none)
    }
}

extension SearchByIngredientVC: UISearchBarDelegate {
    @objc private func cancelSelector() {
        searchBar.endEditing(true)
        searchBar.isHidden = true
        delegate.removeChildVC()
    }
    @objc private func addSelector() {
        print("Add")
        //#error("create the item here, and do the other stuff")
        let item = Item.createItemFrom(text: searchBar.text ?? " ")
        possibleItems.append(item)
        selectedItems.append(item)
        searchBar.text = ""
        searchBar.isHidden = true
        searchBar.setTextProperties()
        for item in selectedItems {
            if let row = possibleItems.firstIndex(of: item) {
                tableView.selectRow(at: IndexPath(row: row, section: 0), animated: false, scrollPosition: .none)
            }
        }
        
        searchBar.endEditing(true)
        searchBar.isHidden = true
        delegate.removeChildVC()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        delegate.searchTextChanged(text: searchBar.text ?? "")
    }
}

extension SearchByIngredientVC: UITableViewDataSource, UITableViewDelegate {
    private func handleCellSelection(indexPathRow: Int) {
        if selectedItems.contains(possibleItems[indexPathRow]) {
            selectedItems = selectedItems.filter({$0 != possibleItems[indexPathRow]})
        } else {
            selectedItems.insert(possibleItems[indexPathRow], at: 0)
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return possibleItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = possibleItems[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "recipeSearchCell") as! RecipeSearchCell
        cell.setUI(item: item)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedItems.contains(possibleItems[indexPath.row]) {
            selectedItems = selectedItems.filter({$0 != possibleItems[indexPath.row]})
        } else {
            selectedItems.insert(possibleItems[indexPath.row], at: 0)
        }
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        handleCellSelection(indexPathRow: indexPath.row)
    }
}


