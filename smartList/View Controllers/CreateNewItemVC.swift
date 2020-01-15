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
    
    private lazy var items = GenericItem.all + ["Frozen chicken", "Chicken thighs", "Chicken breast", "Chicken strips", "Non-fat milk", "Whole milk", "2% milk", "Skim milk", "Whole chicken", "Rotisserie chicken", "Frozen strawberries", "Frozen blueberries", "Frozen broccoli", "Frozen peas", "Frozen corn", "Frozen vegetables", "Frozen dinner", "Frozen waffles", "Chocolate chips", "Baking chocolate", "Dark chocolate", "Milk chocolate", "Chocolate candy bar", "Fuji apples", "Granny smith apples", "Honeycrisp apples", "Red delivious apples", "Chicken kabobs", "Beef kabobs", "Beef steak", "Green bell peppers", "Red bell peppers", "Yellow bell peppers", "White bread", "Whole grain bread", "Ciabatta bread", "Whole wheat bread", "Italian sausage", "Sausage links", "Hot sausage", "Mild sausage", "Sweet sausage", "Broccoli florets", "Salted butter", "Unsalted butter", "Butter substitute", "Baby carrots", "Frozen carrots", "Mild cheddar cheese", "Sharp cheddar cheese", "Maraschino cheries", "Coffee creamer", "Decaf coffee", "Corn on the cob", "Baby corn", "Crab legs", "Crab meat", "Oat crackers", "Wheat crackers", "Soup crackers", "Whipped cream cheese", "Flavored cream cheese", "Healthy dip", "Mixed granola", "Purple grapes", "Green grapes", "Seedless grapes", "Fat free yogurt", "Turkey breast", "Whole turkey", "Frozen turkey", "Frozen beef", "Turkey drumsticks", "Baked ham", "Roasted ham", "Pickled jalapeños", "Lamb chops", "Ground lamb", "Frozen lamb", "Iceberg lettuce", "Romaine lettuce", "Green leaf lettuce", "Lobster tails", "Frozen lobster", "Vegan mayonnaise", "Shredded mozzarella", "Fresh mozzarella", "Cremini mushrooms", "Frozen mushrooms", "Shiitake mushrooms", "Hot mustard", "Brown mustard", "Instant oatmeal", "White onions", "Sweet onions", "Pickled onion", "Cut onion", "Valencia oranges", "Navel oranges", "Shredded parmesan", "Whole wheat pasta", "Frozen peaches", "Canned peaches", "Peach cups", "Chopped pecans", "Chopped walnuts", "Frozen pizza crust", "Microwave popcorn", "Ground pork", "Pork shoulder", "Pork butt", "Pork chops", "Pork kabobs", "Pork rinds", "Pork ribs", "Red potatoes", "Russet potatoes", "Frozen potato", "Frozen raspberries", "Sweet relish", "White rice", "Brown rice", "Balsamic salad dressing", "Catalina salad dressing", "Caesar salad dressing", "Peppered salami", "Smoked salmon", "Salmon fillets", "Mild salsa", "Hot salsa", "Green salsa", "Sea salt", "Pink salt", "Kosher salt", "Frozen shrimp", "Shrimp meat", "Yellow squash", "Spaghetti squash", "Summer squash", "Green tea", "Black tea", "Canned tuna", "Red vinegar", "Rice vinegar", "White vinegar", "Distilled vinegar", "Vegan whipped cream", "Dry yeast"]
    
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
