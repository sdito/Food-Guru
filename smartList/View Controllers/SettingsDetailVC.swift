//
//  SettingsDetailVC.swift
//  smartList
//
//  Created by Steven Dito on 9/9/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class SettingsDetailVC: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var setting: Setting.SettingName?
    var db: Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        db = Firestore.firestore()
        tableView.backgroundColor = .lightGray
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    override func viewDidDisappear(_ animated: Bool) {
        // just to make sure these values are not accidently used
        SharedValues.shared.data = nil
    }
    
    private func returnCells(setting: Setting.SettingName, db: Firestore!) -> [UITableViewCell] {
        switch setting {
        case .account:
            let cell1 = tableView.dequeueReusableCell(withIdentifier: "settingBasicCell") as! SettingBasicCell
            cell1.setUI(str: Auth.auth().currentUser?.email ?? "No user email")
            let cell2 = tableView.dequeueReusableCell(withIdentifier: "settingBasicCell") as! SettingBasicCell
            cell2.setUI(str: Auth.auth().currentUser?.displayName ?? "No display name")
            let cell3 = tableView.dequeueReusableCell(withIdentifier: "settingButtonCell") as! SettingButtonCell
            cell3.setUI(title: "Log out of account")
            cell3.button.addTarget(self, action: #selector(logOut), for: .touchUpInside)
            
            return [cell1, cell2, cell3]
            
            
            
        case .about:
            let cell1 = tableView.dequeueReusableCell(withIdentifier: "settingBasicCell") as! SettingBasicCell
            cell1.setUI(str: "This is for the about cell")
            return [cell1]
            

            
        case .contact:
            return [UITableViewCell()]
        case .darkMode:
            return [UITableViewCell()]
            
          
            
        case .group:
            
            //PROBLEM HERE, NEED TO PULL GROUPID FROM FIRESTORE TO CHECK IF USER IS IN A GROUP, WILL NEED TO BE ABLE TO PULL GROUPID ON DEMAND
            
            
            //case: not in a group -> need to create a group
            if SharedValues.shared.groupID == nil {
                let cell1 = tableView.dequeueReusableCell(withIdentifier: "settingBasicCell") as! SettingBasicCell
                cell1.setUI(str: "Not in a group, create or join a group to easily share lists and storage with other members in your group.")
                let cell2 = tableView.dequeueReusableCell(withIdentifier: "settingButtonCell") as! SettingButtonCell
                cell2.setUI(title: "Create a group")
                cell2.button.addTarget(self, action: #selector(createGroup), for: .touchUpInside)
                return [cell1, cell2]
            } else {
                
                let topCell = tableView.dequeueReusableCell(withIdentifier: "settingTwoLevelCell") as! SettingTwoLevelCell
                User.getGroupInfo(db: db) { (emails, date) in
                    SharedValues.shared.data = (emails, date)
                }
                topCell.setUI(date: SharedValues.shared.data?.date ?? "", emails: SharedValues.shared.data?.emails ?? [""])
                
                let editGroup = tableView.dequeueReusableCell(withIdentifier: "settingButtonCell") as! SettingButtonCell
                editGroup.setUI(title: "Edit group")
                
                let leaveGroup = tableView.dequeueReusableCell(withIdentifier: "settingButtonCell") as! SettingButtonCell
                leaveGroup.setUI(title: "Leave current group")
                
                return [topCell, editGroup, leaveGroup]
            }
            
            
            
            
        case .textSize:
            return [UITableViewCell()]
        case .notifications:
            return [UITableViewCell()]
        case .licences:
            return [UITableViewCell()]
        }
    }
    
    @objc private func logOut() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "logIn") as! LogInVC
        present(vc, animated: true, completion: nil)
    }
    @objc private func createGroup() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "createGroup") as! CreateGroupVC
        present(vc, animated: true, completion: nil)
        
    }
}

extension SettingsDetailVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let v = UIView()
        v.backgroundColor = .lightGray
        return v
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let v = UIView()
        v.backgroundColor = .lightGray
        return v
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return returnCells(setting: setting!, db: db).count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return returnCells(setting: setting!, db: db)[indexPath.row]
    }
    
}
