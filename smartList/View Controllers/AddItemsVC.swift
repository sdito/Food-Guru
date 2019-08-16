//
//  AddItemsVC.swift
//  smartList
//
//  Created by Steven Dito on 8/8/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import UIKit
//import FirebaseCore
import FirebaseFirestore

class AddItemsVC: UIViewController {
    private var storeText: String?
    
    var db: Firestore!
    var list: List? {
        didSet {
            if list?.items?.isEmpty == false {
                tableView?.reloadData()
            }
        }
    }
    
    @IBOutlet weak var storesView: UIView!
    @IBOutlet weak var categoriesView: UIView!
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.delegate = self
        tableView.dataSource = self
        
        Item.readItems(db: db, docID: SharedValues.shared.listIdentifier!.documentID) { (itm) in
            self.list?.items = itm
            self.setUIfrom(list: self.list!)
        }
        
        
        if let first = stackView.subviews.last as! UIButton? {
            SharedValues.shared.currentCategory = first.titleLabel?.text ?? "none"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        SharedValues.shared.listIdentifier?.updateData([
            "numItems": list?.items?.count as Any
        ])
    }
    
    //currently crashes if something is empty from the list
    @IBAction func addItem(_ sender: Any) {
        if list?.stores?.isEmpty == false {
            if let txt = segmentedControl.titleForSegment(at: segmentedControl.selectedSegmentIndex) {
                storeText = txt
            } else {
                storeText = "none - segmented control didnt work"
            }
        } else {
            storeText = "none - stores is empty"
        }
        
        
        let item = Item(name: textField.text!, category: SharedValues.shared.currentCategory, store: storeText, user: nil)
        item.writeToFirestore(db: db)
        
        if list?.items?.isEmpty == false {
            list?.items!.append(item)
        } else {
            list?.items = [item]
        }

        textField.text = ""
    }
    
    
    private func setUIfrom(list: List) {
        //segmented control set up
        segmentedControl.removeAllSegments()
        list.stores?.forEach({ (store) in
            segmentedControl.insertSegment(withTitle: store, at: 0, animated: false)
        })
        
        segmentedControl.selectedSegmentIndex = 0
        
        //buttons set up
        stackView.subviews.forEach({$0.removeFromSuperview()})
        list.categories?.forEach({ (category) in
            let button = UIButton()
            button.createCategoryButton(with: category)
            stackView.insertArrangedSubview(button, at: 0)
        })
        if list.categories?.isEmpty == true {
            scrollView.isHidden = true
            
        }
        if list.stores?.isEmpty == true {
            segmentedControl.isHidden = true
        }
    }
}

// have the cells organized by
extension AddItemsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list?.items?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let item = list?.items?[indexPath.row] else { return UITableViewCell() }
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell") as! ItemCell
        cell.setUI(item: item)
        return cell
    }
}
