//
//  ListHomeVC.swift
//  smartList
//
//  Created by Steven Dito on 9/5/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import UIKit
import FirebaseFirestore

class ListHomeVC: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var db: Firestore!
    var sections: [String]?
    var listsForSections: [[List]]?
    
    private var items: [Item] = []
    private var lists: [List]? {
        didSet {
            (sections, listsForSections) = self.lists?.organizeTableViewForListHome() ?? (nil, nil)
            tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        //super.viewWillAppear(animated)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        db = Firestore.firestore()
        List.readAllUserLists(db: db, userID: SharedValues.shared.userID!) { (dbLists) in
            self.lists = dbLists
        }

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "listSelected" {
            let destVC = segue.destination as! AddItemsVC
            destVC.list = sender as? List
        }
    }
    @IBAction func setUpList(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "setUpList") as! SetUpListVC
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)

    }
    
}
extension ListHomeVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections?.count ?? 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if lists != nil {
            return listsForSections?[section].count ?? 0
        } else {
            return 0
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if lists != nil {
            let label = UILabel()
            label.text = sections?[section]
            label.font = UIFont(name: "futura", size: 15)
            label.backgroundColor = .lightGray
            label.textColor = .white
            label.alpha = 0.8
            return label
        }
        return nil
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let item = lists![indexPath.row]
        if lists != nil {
            let item = listsForSections![indexPath.section][indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "listHomeCell", for: indexPath) as! ListHomeCell
            cell.setUI(list: item)
            return cell
        }
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let l = lists![indexPath.row]
        if lists != nil {
            let l = listsForSections?[indexPath.section][indexPath.row]
            SharedValues.shared.listIdentifier = self.db.collection("lists").document("\(l?.docID! ?? " ")")
            self.performSegue(withIdentifier: "listSelected", sender: l)
        }
        
    }
    
    
}
