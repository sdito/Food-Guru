//
//  StorageHomeVC.swift
//  smartList
//
//  Created by Steven Dito on 9/5/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import UIKit

class StorageHomeVC: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var items: [Item] = [Item(name: "Eggs", selected: false, category: nil, store: nil, user: nil, ownID: nil, storageSection: "none", timeAdded: Date().timeIntervalSince1970, timeExpires: nil), Item(name: "Milk", selected: false, category: nil, store: nil, user: nil, ownID: nil, storageSection: nil, timeAdded: Date().timeIntervalSince1970, timeExpires: nil), Item(name: "Cheese", selected: false, category: nil, store: nil, user: nil, ownID: nil, storageSection: nil, timeAdded: Date().timeIntervalSince1970, timeExpires: nil)] {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    
    @IBAction func searchPressed(_ sender: Any) {
        print(SharedValues.shared.groupID)
        print(SharedValues.shared.groupEmails)
        print(SharedValues.shared.groupDate)
    }
    

}


extension StorageHomeVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "storageCell") as! StorageCell
        let item = items[indexPath.row]
        cell.setUI(item: item)
        return cell
    }
    
    
}
