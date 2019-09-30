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
        createObserver()
        db = Firestore.firestore()
        tableView.backgroundColor = .lightGray
        self.createNavigationBarTextAttributes()
        self.title = setting?.description()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "settingContactDeveloperCell") as! SettingContactDeveloperCell
            cell.delegate = self
            return [cell]
        case .darkMode:
            return [UITableViewCell()]
            
          
            
        case .group:
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
                /*
                User.getGroupInfo(db: db) { (emails, date) in
                    SharedValues.shared.data = (emails, date)
                }
                */
                topCell.setUI(date: (SharedValues.shared.groupDate)?.dateFormatted(style: .short) ?? "", emails: SharedValues.shared.groupEmails ?? [""])
                
                let editGroup = tableView.dequeueReusableCell(withIdentifier: "settingButtonCell") as! SettingButtonCell
                editGroup.setUI(title: "Edit group")
                editGroup.button.addTarget(self, action: #selector(editGroupAction), for: .touchUpInside)
                
                let leaveGroup = tableView.dequeueReusableCell(withIdentifier: "settingButtonCell") as! SettingButtonCell
                leaveGroup.setUI(title: "Leave current group")
                leaveGroup.button.addTarget(self, action: #selector(leaveGroupAction), for: .touchUpInside)
                
                return [topCell, editGroup, leaveGroup]
            }
            
            
            
            
        case .textSize:
            return [UITableViewCell()]
        case .notifications:
            return [UITableViewCell()]
        case .licences:
            return [UITableViewCell()]
            
        
        case .list:
            return [UITableViewCell()]
        case .storage:
            return [UITableViewCell()]
        case .recipe:
            return [UITableViewCell()]
        }
    }
    
    private func createObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(observerSelectorGroupID), name: .groupIDchanged, object: nil)
    }
    
    @objc func observerSelectorGroupID() {
        tableView.reloadData()
    }
    
    @objc private func logOut() {
        let alert = UIAlertController(title: "Are you sure you want to log out of your account?", message: nil, preferredStyle: .alert)
        alert.addAction(.init(title: "Log out", style: .destructive, handler: {(alert: UIAlertAction!) in
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "logIn") as! LogInVC
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
        }))
        alert.addAction(.init(title: "Back", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    @objc private func createGroup() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "createGroup") as! CreateGroupVC
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
        
    }
    @objc private func leaveGroupAction() {
        let alert = UIAlertController(title: "Are you sure you want to leave your group?", message: nil, preferredStyle: .alert)
        
        alert.addAction(.init(title: "Leave group?", style: .destructive, handler: {(alert: UIAlertAction!) in User.leaveGroupUser(db: self.db, groupID: SharedValues.shared.groupID ?? " ")}))
        alert.addAction(.init(title: "Back", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    @objc private func editGroupAction() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "createGroup") as! CreateGroupVC
        vc.modalPresentationStyle = .fullScreen
        vc.previousGroupID = SharedValues.shared.groupID
        present(vc, animated: true, completion: nil)
    }
    
}

extension SettingsDetailVC: UpdateScreenDelegate {
    func updateScreen() {
        navigationController?.popViewController(animated: true)
        self.tabBarController?.createMessageView(color: Colors.messageGreen, text: "Message successfully sent")
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
        v.alpha = 0
        return v
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return returnCells(setting: setting!, db: db).count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return returnCells(setting: setting!, db: db)[indexPath.row]
    }
    
}
