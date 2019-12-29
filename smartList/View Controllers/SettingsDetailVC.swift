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
        self.createNavigationBarTextAttributes()
        self.title = setting?.description()
        Recipe.readPreviouslyViewedRecipes(db: db)
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
        
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("View did dissapear")
        SharedValues.shared.newUsername = nil
    }
    
    private func returnCells(setting: Setting.SettingName, db: Firestore!) -> [UITableViewCell] {
        switch setting {
        case .account:
            if SharedValues.shared.anonymousUser == false {
                let cell1 = tableView.dequeueReusableCell(withIdentifier: "settingBasicCell") as! SettingBasicCell
                cell1.setUI(str: "Email: \(Auth.auth().currentUser?.email ?? "N/A")" )
                let cell2 = tableView.dequeueReusableCell(withIdentifier: "settingBasicCell") as! SettingBasicCell
                var name: String {
                    if SharedValues.shared.newUsername != nil {
                        return SharedValues.shared.newUsername!
                    } else {
                        return Auth.auth().currentUser?.displayName ?? "N/A"
                    }
                }
                cell2.setUI(str: "Name: \(name)")
                let cell3 = tableView.dequeueReusableCell(withIdentifier: "settingButtonCell") as! SettingButtonCell
                cell3.setUI(title: "Log out of account")
                cell3.button.addTarget(self, action: #selector(logOut), for: .touchUpInside)
                let cell4 = tableView.dequeueReusableCell(withIdentifier: "settingButtonCell") as! SettingButtonCell
                cell4.button.addTarget(self, action: #selector(changeUsername), for: .touchUpInside)
                cell4.setUI(title: "Change display name")
                
                return [cell1, cell2, cell3, cell4]
            } else {
                let cell1 = tableView.dequeueReusableCell(withIdentifier: "settingBasicCell") as! SettingBasicCell
                cell1.setUI(str: "Create a free account to unlock all the features in the application and to secure your data.")
                let cell2 = tableView.dequeueReusableCell(withIdentifier: "settingButtonCell") as! SettingButtonCell
                cell2.setUI(title: "Create account")
                cell2.button.addTarget(self, action: #selector(createAccountFromAnonymous), for: .touchUpInside)
                return [cell1, cell2]
            }
            
            
            
            
        case .about:
            let cell1 = tableView.dequeueReusableCell(withIdentifier: "settingBasicCell") as! SettingBasicCell
            cell1.setUI(str: "Hopefully this application is useful for you, if you have any feedback or difficulties with the app, please do not hesitate to contact the developer!")
            return [cell1]

        case .contact:
            let cell = tableView.dequeueReusableCell(withIdentifier: "settingContactDeveloperCell") as! SettingContactDeveloperCell
            cell.delegate = self
            return [cell]
            
        case .darkMode:
            let cell1 = tableView.dequeueReusableCell(withIdentifier: "settingBasicCell") as! SettingBasicCell
            cell1.setUI(str: "1. Make sure iOS 13 or a newer version of iOS is downloaded on your phone.")
            let cell2 = tableView.dequeueReusableCell(withIdentifier: "settingBasicCell") as! SettingBasicCell
            cell2.setUI(str: "2. Access the control center.")
            let cell3 = tableView.dequeueReusableCell(withIdentifier: "settingBasicCell") as! SettingBasicCell
            cell3.setUI(str: "3. Press and hold on the brightness control displayed in the control center.")
            let cell4 = tableView.dequeueReusableCell(withIdentifier: "settingBasicCell") as! SettingBasicCell
            cell4.setUI(str: "4. Select 'Dark Mode'")
            return [cell1, cell2, cell3, cell4]
            
        case .group:
            if SharedValues.shared.anonymousUser == false {
                if SharedValues.shared.groupID == nil {
                    let cell1 = tableView.dequeueReusableCell(withIdentifier: "settingBasicCell") as! SettingBasicCell
                    cell1.setUI(str: "Not in a group, create or join a group to easily share lists and storage with other members in your group.")
                    let cell2 = tableView.dequeueReusableCell(withIdentifier: "settingButtonCell") as! SettingButtonCell
                    cell2.setUI(title: "Create a group")
                    cell2.button.addTarget(self, action: #selector(createGroup), for: .touchUpInside)
                    return [cell1, cell2]
                } else {
                    let topCell = tableView.dequeueReusableCell(withIdentifier: "settingTwoLevelCell") as! SettingTwoLevelCell
                    let top = "Created on \((SharedValues.shared.groupDate)?.dateFormatted(style: .short) ?? "")"
                    topCell.setUI(top: top, emails: SharedValues.shared.groupEmails ?? [""])
                    let editGroup = tableView.dequeueReusableCell(withIdentifier: "settingButtonCell") as! SettingButtonCell
                    editGroup.setUI(title: "Edit group")
                    editGroup.button.addTarget(self, action: #selector(editGroupAction), for: .touchUpInside)
                    let leaveGroup = tableView.dequeueReusableCell(withIdentifier: "settingButtonCell") as! SettingButtonCell
                    leaveGroup.setUI(title: "Leave current group")
                    leaveGroup.button.addTarget(self, action: #selector(leaveGroupAction), for: .touchUpInside)
                    return [topCell, editGroup, leaveGroup]
                }
            } else {
                let cell1 = tableView.dequeueReusableCell(withIdentifier: "settingBasicCell") as! SettingBasicCell
                cell1.setUI(str: "Groups allow you to share your lists, recipes, and storage with other people. Create a free account to unlock all the features in the application and to secure your data.")
                let cell2 = tableView.dequeueReusableCell(withIdentifier: "settingButtonCell") as! SettingButtonCell
                cell2.setUI(title: "Create account")
                cell2.button.addTarget(self, action: #selector(createAccountFromAnonymous), for: .touchUpInside)
                return [cell1, cell2]
            }
 
            
            
        case .notifications:
            return [UITableViewCell()]
            
            
        case .licences:
            self.title = "Software licences"
            let cell1 = tableView.dequeueReusableCell(withIdentifier: "settingBasicCell") as! SettingBasicCell
            cell1.setUI(str: "recipepuppy.com")
            let cell2 = tableView.dequeueReusableCell(withIdentifier: "settingBasicCell") as! SettingBasicCell
            cell2.setUI(str: "iconsdb.com")
            let cell3 = tableView.dequeueReusableCell(withIdentifier: "settingBasicCell") as! SettingBasicCell
            cell3.setUI(str: "icons8.com")
            let cell4 = tableView.dequeueReusableCell(withIdentifier: "settingBasicCell") as! SettingBasicCell
            cell4.setUI(str: "world.openfoodfacts.org")
            let cell5 = tableView.dequeueReusableCell(withIdentifier: "settingBasicCell") as! SettingBasicCell
            cell5.setUI(str: "flaticon.com")
            return [cell1, cell2, cell3, cell4, cell5]
            
            
        case .storage:
            if SharedValues.shared.foodStorageID == nil {
                var txt: String {
                    if SharedValues.shared.groupID == nil {
                        return "You do not have a storage created yet. A storage will allow you to keep track of the items you have in stock, and to help you find recipes with your items. Create a group to easily share your storage with other people."
                    } else {
                        return "You do not have a storage created yet. A storage will allow you to keep track of the items you have in stock, and to help you find recipes with your items."
                    }
                }
                let cell1 = tableView.dequeueReusableCell(withIdentifier: "settingBasicCell") as! SettingBasicCell
                cell1.setUI(str: txt)
                let button2 = tableView.dequeueReusableCell(withIdentifier: "settingButtonCell") as! SettingButtonCell
                button2.setUI(title: "Create storage without group")
                button2.button.addTarget(self, action: #selector(createStorageIndividual), for: .touchUpInside)
                if SharedValues.shared.groupID == nil {
                    let button1 = tableView.dequeueReusableCell(withIdentifier: "settingButtonCell") as! SettingButtonCell
                    button1.setUI(title: "Create group")
                    button1.button.addTarget(self, action: #selector(createGroup), for: .touchUpInside)
                    return [cell1, button1, button2]
                } else {
                   let button3 = tableView.dequeueReusableCell(withIdentifier: "settingButtonCell") as! SettingButtonCell
                    button3.setUI(title: "Create storage with group (recommended)")
                    button3.button.addTarget(self, action: #selector(createStorageGroup), for: .touchUpInside)
                   return [cell1, button3, button2]
                }
                
            } else {
                let cell1 = tableView.dequeueReusableCell(withIdentifier: "settingTwoLevelCell") as! SettingTwoLevelCell
                FoodStorage.getEmailsfromStorageID(storageID: SharedValues.shared.foodStorageID ?? " ", db: db) { (emails) in
                    SharedValues.shared.foodStorageEmails = emails
                }
                cell1.setUI(top: "Storage members", emails: SharedValues.shared.foodStorageEmails ?? [""])
                let button1 = tableView.dequeueReusableCell(withIdentifier: "settingButtonCell") as! SettingButtonCell
                button1.setUI(title: "Delete storage")
                button1.button.addTarget(self, action: #selector(deleteStorage), for: .touchUpInside)
                let button2 = tableView.dequeueReusableCell(withIdentifier: "settingButtonCell") as! SettingButtonCell
                button2.setUI(title: "Delete all items from storage")
                button2.button.addTarget(self, action: #selector(deleteItemsFromStorage), for: .touchUpInside)
                return [cell1, button1, button2]
            }
            
        case .recentlyViewedRecipes:
            self.title = "Recently viewed recipes"
            var cells: [UITableViewCell] = []
            if let data = SharedValues.shared.previouslyViewedRecipes {
                for item in data.keys.sorted().reversed() {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "settingViewedRecipeCell") as! SettingViewedRecipeCell
                    let recipe = data[item]
                    cell.setUIfromData(data: recipe!)
                    cell.delegate = self
                    cells.append(cell)
                }
            }
            return cells
        }
    }
    
    private func createObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(observerSelectorGroupID), name: .groupIDchanged, object: nil)
    }
    
    @objc func observerSelectorGroupID() {
        tableView.reloadData()
    }
    
    @objc private func createAccountFromAnonymous() {
        print("Create account from anonymous")
        let sb: UIStoryboard = UIStoryboard(name: "LogIn", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "initialLogInVC") as! InitialLogInVC
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    @objc private func changeUsername() {
        print("Change the username from here")
        let sb: UIStoryboard = UIStoryboard(name: "LogIn", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "createUsernameVC") as! CreateDisplayNameVC
//        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
        vc.backOutlet.isHidden = false
        vc.forChange = true
        vc.createUsernameOutlet.setTitle("Change username", for: .normal)
//        #error("need to reload the table view once the display name is changed")
    }
    
    @objc private func logOut() {
        let alert = UIAlertController(title: "Are you sure you want to log out of your account?", message: nil, preferredStyle: .alert)
        alert.addAction(.init(title: "Log out", style: .destructive, handler: {(alert: UIAlertAction!) in
            do {
                try Auth.auth().signOut()
                let sb: UIStoryboard = UIStoryboard(name: "LogIn", bundle: nil)
                let vc = sb.instantiateViewController(withIdentifier: "initialLogInVC") as! InitialLogInVC
                vc.modalPresentationStyle = .fullScreen
                vc.modalTransitionStyle = .crossDissolve
                self.present(vc, animated: true, completion: nil)
                
            } catch {
                print(error)
            }
             
        }))
        alert.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    @objc private func createGroup() {
        if SharedValues.shared.anonymousUser == false {
            let vc = storyboard?.instantiateViewController(withIdentifier: "createGroup") as! CreateGroupVC
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Error", message: "You must create a free account to create a group. Create a free account to access all the features.", preferredStyle: .alert)
            alert.addAction(.init(title: "Ok", style: .default, handler: nil))
            present(alert, animated: true)
        }
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
    @objc private func createStorageIndividual() {
        print("create individual storage")
        let foodStorage = FoodStorage(isGroup: false, groupID: nil, peopleEmails: [Auth.auth().currentUser?.email ?? "no email"], items: nil, numberOfPeople: 1)
        FoodStorage.createStorageToFirestoreWithPeople(db: db, foodStorage: foodStorage)
        tableView.reloadData()
    }
    @objc private func createStorageGroup() {
        print("create group storage")
        let foodStorage = FoodStorage(isGroup: true, groupID: SharedValues.shared.groupID, peopleEmails: SharedValues.shared.groupEmails ?? ["emails didnt work"], items: nil, numberOfPeople: SharedValues.shared.groupEmails?.count)
        FoodStorage.createStorageToFirestoreWithPeople(db: db, foodStorage: foodStorage)
    }
    @objc private func deleteItemsFromStorage() {
        let alert = UIAlertController(title: "Are you sure you want to delete all items from your storage?", message: "This action can't be undone", preferredStyle: .alert)
        alert.addAction(.init(title: "Delete", style: .destructive, handler: { (action) in
            if let id = SharedValues.shared.foodStorageID {
                FoodStorage.deleteItemsFromStorage(db: self.db, storageID: id)
                self.createMessageView(color: Colors.messageGreen, text: "Items successfully deleted from storage")
            }
            
        }))
        alert.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    @objc private func deleteStorage() {
        print("Delete storage")
        let alert = UIAlertController(title: "Are you sure you want to delete your storage?", message: "This action can't be undome", preferredStyle: .alert)
        alert.addAction(.init(title: "Delete", style: .destructive, handler: { (action) in
            if let id = SharedValues.shared.foodStorageID {
                FoodStorage.deleteStorage(db: self.db, storageID: id)
                self.createMessageView(color: Colors.messageGreen, text: "Storage successfully deleted")
            }
        }))
        alert.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true)
        
        
    }
    
}

extension SettingsDetailVC: UpdateScreenDelegate {
    func updateScreen() {
        navigationController?.popViewController(animated: true)
        self.tabBarController?.createMessageView(color: Colors.messageGreen, text: "Message successfully sent")
    }
    
    
}


extension SettingsDetailVC: SettingViewedRecipeCellDelegate {
    func recipeDocumentIdPressed(id: String) {
        Recipe.readOneRecipeFrom(id: id, db: db) { (rcp) in
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "recipeDetailVC") as! RecipeDetailVC
            let data = (UIImage(), rcp)
            vc.data = data
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}


extension SettingsDetailVC: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return returnCells(setting: setting!, db: db).count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return returnCells(setting: setting!, db: db)[indexPath.row]
    }
    
}


