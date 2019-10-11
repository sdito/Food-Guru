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
    
    lazy private var emptyCells: [UITableViewCell] = createEmptyListCells()
    
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
        createObserver()
        db = Firestore.firestore()
        List.readAllUserLists(db: db, userID: SharedValues.shared.userID!) { (dbLists) in
            self.lists = dbLists
        }
        
        
        print(Search.turnIntoSystemItem(string: "6 cups chicken broth, divided"))
        print(Search.turnIntoSystemItem(string: "3 tablespoons olive oil, divided"))
        print(Search.turnIntoSystemItem(string: "1 pound portobello mushrooms, thinly sliced"))
        print(Search.turnIntoSystemItem(string: "1 pound white mushrooms, thinly sliced"))
        print(Search.turnIntoSystemItem(string: "2 shallots, diced"))
        print(Search.turnIntoSystemItem(string: "1 1/2 cups Arborio rice"))
        print(Search.turnIntoSystemItem(string: "1/2 cup dry white wine"))
        print(Search.turnIntoSystemItem(string: "3 tablespoons finely chopped chives"))
        print(Search.turnIntoSystemItem(string: "4 tablespoons butter"))
        print(Search.turnIntoSystemItem(string: "1/3 cup freshly grated Parmesan cheese"))
//        print(Search.turnIntoSystemItem(string: "2 (28 ounce) cans whole peeled tomatoes"))
//        print(Search.turnIntoSystemItem(string: "2 teaspoons salt"))
//        print(Search.turnIntoSystemItem(string: "1 teaspoon white sugar"))
//        print(Search.turnIntoSystemItem(string: "1 bay leaf"))
//        print(Search.turnIntoSystemItem(string: "1 (6 ounce) can tomato paste"))
//        print(Search.turnIntoSystemItem(string: "3/4 teaspoon dried basil"))
//        print(Search.turnIntoSystemItem(string: "1/2 teaspoon ground black pepper"))
//        print(Search.turnIntoSystemItem(string: "3/4 cup grated Parmesan cheese"))
            
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "listSelected" {
            let destVC = segue.destination as! AddItemsVC
            destVC.list = sender as? List
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func setUpList(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "setUpList") as! SetUpListVC
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)

    }
    
    private func createObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(observerSelectorGroupID), name: .groupIDchanged, object: nil)
    }
    
    @objc func observerSelectorGroupID() {
        emptyCells = createEmptyListCells()
        tableView.reloadData()
    }
    
}
extension ListHomeVC: UITableViewDataSource, UITableViewDelegate {
    func createEmptyListCells() -> [UITableViewCell] {
        let one = tableView.dequeueReusableCell(withIdentifier: "settingBasicCell") as! SettingBasicCell
        var hasGroup: Bool {
            switch SharedValues.shared.groupID {
            case nil:
                return false
            default:
                return true
            }
        }
        var groupText: String {
            switch hasGroup {
            case false:
                return "Create a group in order to have your lists shared with other people."
            case true:
                return ""
            }
        }
        
        one.setUI(str: "You do not have any lists created or shared with you yet.\(groupText)")
        
        switch hasGroup {
        case true:
            return [one]
        case false:
            let two = tableView.dequeueReusableCell(withIdentifier: "settingButtonCell") as! SettingButtonCell
            two.setUI(title: "Create group")
            two.button.addTarget(self, action: #selector(self.createGroupPopUp), for: .touchUpInside)
            return [one, two]
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        switch lists?.count {
        case 0:
            return 1
        default:
            return sections?.count ?? 1
        }
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch lists?.count {
        case 0:
            return emptyCells.count
        default:
            return listsForSections?[section].count ?? 0
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch lists?.count {
        case 0:
            let view = UIView()
            view.alpha = 0
            return view
        default:
            let label = UILabel()
            label.text = sections?[section]
            label.font = UIFont(name: "futura", size: 15)
            label.backgroundColor = .lightGray
            label.textColor = .white
            label.alpha = 0.8
            return label
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch lists?.count {
        case 0:
            return emptyCells[indexPath.row]
        default:
            let item = listsForSections![indexPath.section][indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "listHomeCell", for: indexPath) as! ListHomeCell
            cell.setUI(list: item)
            return cell
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let l = lists![indexPath.row]
        
        if lists?.count != 0 {
            let l = listsForSections?[indexPath.section][indexPath.row]
            SharedValues.shared.listIdentifier = self.db.collection("lists").document("\(l?.docID! ?? " ")")
            self.performSegue(withIdentifier: "listSelected", sender: l)
        }
        
    }
    
    
}
