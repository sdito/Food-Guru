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

protocol RecipesFoundFromSearchingDelegate {
    func recipesFound(ingredients: [String])
}


class SearchByIngredientVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var buttonOutlet: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var newItemButtonOutlet: UIButton!
    
    var db: Firestore!
    var delegate: SearchAssistantDelegate!
    var recipesFoundDelegate: RecipesFoundFromSearchingDelegate!
    private var keyboardHeight: CGFloat?
    private var selectedItems: [Item] = [] {
        didSet {
            if self.selectedItems.isEmpty == false {
                let display = self.selectedItems.map { (itm) -> String in itm.name}.joined(separator: ", ")
                buttonOutlet.setTitle("Find recipes with \(display)", for: .normal)
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
    // MARK: override funcs
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
            self.possibleItems = itms.filter({$0.systemItem != .other})
        }
        searchBar.setUpAddItemToolbar(cancelAction: #selector(cancelSelector), addAction: #selector(addSelector))
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        
        newItemButtonOutlet.widthAnchor.constraint(equalToConstant: newItemButtonOutlet.bounds.width + 10.0).isActive = true
        newItemButtonOutlet.shadowAndRounded(cornerRadius: 10, border: false)
    }
    
    // MARK: @IBAction funcs
    @IBAction func buttonAction(_ sender: Any) {
        let ingredients = selectedItems.map { (itm) -> GenericItem in
            itm.systemItem!
        }.map { (genericItem) -> String in
            genericItem.rawValue
        }
        
        
        self.recipesFoundDelegate.recipesFound(ingredients: ingredients)
        
    }
    
    @IBAction func exitPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func addItem(_ sender: Any) {
        //#error("need to get create item vc to be proper size")
        searchBar.isHidden = false
        buttonOutlet.isHidden = true
        
        searchBar.becomeFirstResponder()
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "createNewItemVC") as! CreateNewItemVC
        self.addChild(vc)
        self.view.addSubview(vc.tableView)
        vc.didMove(toParent: self)
        vc.tableView.translatesAutoresizingMaskIntoConstraints = false
        vc.tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor).isActive = true
        
        
        let distance = (self.view.bounds.height) - (searchBar.bounds.height) - (keyboardHeight ?? 0.0)
        vc.tableView.heightAnchor.constraint(equalToConstant: distance).isActive = true
        vc.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        vc.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        vc.delegate = self
        delegate = vc
    }
    // MARK: functions
    @objc private func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            keyboardHeight = keyboardRectangle.height
        }
    }
    
}
// MARK: CreateNewItemDelegate
extension SearchByIngredientVC: CreateNewItemDelegate {
    func itemCreated(item: Item) {
        possibleItems.append(item)
        selectedItems.append(item)
        searchBar.text = ""
        searchBar.isHidden = true
        buttonOutlet.isHidden = false
        
        for item in selectedItems {
            if let row = possibleItems.firstIndex(of: item) {
                tableView.selectRow(at: IndexPath(row: row, section: 0), animated: false, scrollPosition: .none)
            }
        }
        //tableView.selectRow(at: IndexPath(row: possibleItems.count - 1, section: 0), animated: false, scrollPosition: .none)
    }
}
// MARK: Search bar
extension SearchByIngredientVC: UISearchBarDelegate {
    @objc private func cancelSelector() {
        searchBar.endEditing(true)
        searchBar.isHidden = true
        buttonOutlet.isHidden = false
        delegate.removeChildVC()
    }
    @objc private func addSelector() {
        
        if searchBar.text != "" {
            let item = Item.createItemFrom(text: searchBar.text ?? " ")
            possibleItems.append(item)
            selectedItems.append(item)
            searchBar.text = ""
            searchBar.isHidden = true
            buttonOutlet.isHidden = false
            searchBar.setTextProperties()
            for item in selectedItems {
                if let row = possibleItems.firstIndex(of: item) {
                    tableView.selectRow(at: IndexPath(row: row, section: 0), animated: false, scrollPosition: .none)
                }
            }
        }
        
        
        
        searchBar.endEditing(true)
        searchBar.isHidden = true
        buttonOutlet.isHidden = false
        delegate.removeChildVC()
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        delegate.searchTextChanged(text: searchBar.text ?? "")
        
    }
}
// MARK: Table view
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


