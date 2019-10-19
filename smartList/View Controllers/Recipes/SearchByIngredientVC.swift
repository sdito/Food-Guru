//
//  SearchByIngredientVC.swift
//  smartList
//
//  Created by Steven Dito on 10/18/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import UIKit
import FirebaseFirestore

class SearchByIngredientVC: UIViewController {
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
        buttonOutlet.isUserInteractionEnabled = false
        buttonOutlet.titleLabel?.numberOfLines = 2
        buttonOutlet.titleLabel?.textAlignment = .center
        Item.readItemsForStorageNoListener(db: db, storageID: SharedValues.shared.foodStorageID ?? " ") { (itms) in
            self.possibleItems = itms
        }
    }
    @IBAction func buttonAction(_ sender: Any) {
        print("Button pressed")
    }
    
    @IBAction func addItem(_ sender: Any) {
        #error("need to get create item vc to be proper size")
        searchBar.isHidden = false
        searchBar.becomeFirstResponder()
        let vc = storyboard?.instantiateViewController(withIdentifier: "createNewItemVC") as! CreateNewItemVC
        vc.view.heightAnchor.constraint(equalToConstant: 200)
        self.present(vc, animated: true, completion: nil)
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
