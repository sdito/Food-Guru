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
    
    private var items: [Item] = []
    private var lists: [List]? {
        didSet {
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let n = lists?.count {
            return n
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = lists![indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "listHomeCell", for: indexPath) as! ListHomeCell
        cell.setUI(list: item)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let l = lists![indexPath.row]
        SharedValues.shared.listIdentifier = self.db.collection("lists").document("\(l.docID!)")
        self.performSegue(withIdentifier: "listSelected", sender: l)
    }
    
    
}
