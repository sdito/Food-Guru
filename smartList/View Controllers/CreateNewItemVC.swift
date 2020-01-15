//
//  CreateNewItemVC.swift
//  smartList
//
//  Created by Steven Dito on 10/18/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import UIKit


protocol CreateNewItemDelegate {
    func itemCreated(item: Item)
}



class CreateNewItemVC: UITableViewController {
    var delegate: CreateNewItemDelegate!
    private var searchText: String = "" {
        didSet {
            if self.searchText == "" {
                tableView.isHidden = true
            } else {
                let txt = self.searchText.trimUntilText().lowercased()
                tableView.isHidden = false
                searchedItems.removeAll()
                items.forEach { (itm) in
                    let lower = itm.lowercased()
                    if lower.contains(txt) {
                        searchedItems.append(itm)
                    }
                }
                if searchedItems.isEmpty {
                    tableView.isHidden = true
                } else {
                    tableView.isHidden = false
                }
                tableView.reloadData()
            }
        }
    }
    
    private var searchedItems: [String] = []
    private lazy var items = GenericItem.all + ["Frozen chicken", "Chicken thighs", "Chicken breast", "Chicken strips", "Non-fat milk", "Whole milk", "2% milk", "Skim milk", "Whole chicken", "Rotisserie chicken", "Frozen strawberries", "Frozen blueberries", "Frozen broccoli", "Frozen peas", "Frozen corn", "Frozen vegetables", "Frozen dinner", "Frozen waffles"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.isHidden = true
    }
    
    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchedItems.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "createNewItemCell", for: indexPath) as! CreateNewItemCell
        cell.setUI(text: searchedItems[indexPath.row])
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let number = searchText.getAmountForNewItem()
        let text = searchedItems[indexPath.row]
        let words = text.split{ !$0.isLetter }.map { (sStr) -> String in
            String(sStr.lowercased())
        }
        let systemItem = Search.turnIntoSystemItem(string: text)
        let category = GenericItem.getCategory(item: systemItem, words: words)
        
        let displayText = "\(number)\(text)"
        let item = Item(name: displayText, selected: false, category: category.rawValue, store: nil, user: nil, ownID: nil, storageSection: nil, timeAdded: nil, timeExpires: nil, systemItem: systemItem, systemCategory: category)
        delegate.itemCreated(item: item)
        self.willMove(toParent: nil)
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    
}

extension CreateNewItemVC: SearchAssistantDelegate {
    func removeChildVC() {
        self.willMove(toParent: nil)
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    
    func searchTextChanged(text: String) {
        searchText = text
    }
    
    
}
