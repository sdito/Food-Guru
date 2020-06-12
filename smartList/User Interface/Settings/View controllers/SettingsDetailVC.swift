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
        
        if let sID = SharedValues.shared.foodStorageID {
            FoodStorage.findIfUsersStorageIsWithGroup(db: db, storageID: sID)
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        SharedValues.shared.newUsername = nil
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    // MARK: functions
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
 
            
        case .licences:
            self.title = "Software licenses"
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
                        return "Creating a group will allow you to share your items in stock with the people you want!"
                    } else {
                        return "Creating a storage with your group will allow you to see realtime updates and share your items."
                    }
                }
                
                let cell1 = tableView.dequeueReusableCell(withIdentifier: "settingBasicCell") as! SettingBasicCell
                cell1.setUI(str: "You do not have a storage created yet. A storage will allow you to keep track of the items you have in stock, and to help you find recipes with your items.")
                
                let cell2 = tableView.dequeueReusableCell(withIdentifier: "settingBasicCell") as! SettingBasicCell
                cell2.setUI(str: txt)
                
                let button2 = tableView.dequeueReusableCell(withIdentifier: "settingButtonCell") as! SettingButtonCell
                button2.setUI(title: "Create storage without group")
                button2.button.addTarget(self, action: #selector(createStorageIndividual), for: .touchUpInside)
                if SharedValues.shared.groupID == nil {
                    let button1 = tableView.dequeueReusableCell(withIdentifier: "settingButtonCell") as! SettingButtonCell
                    button1.setUI(title: "Create group")
                    button1.button.addTarget(self, action: #selector(createGroup), for: .touchUpInside)
                    return [cell1, cell2, button1, button2]
                } else {
                   let button3 = tableView.dequeueReusableCell(withIdentifier: "settingButtonCell") as! SettingButtonCell
                    button3.setUI(title: "Create storage with group (recommended)")
                    button3.button.addTarget(self, action: #selector(createStorageGroup), for: .touchUpInside)
                   return [cell1, cell2, button3, button2]
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
                
                
                
                if SharedValues.shared.groupID != nil && SharedValues.shared.isStorageWithGroup == false {
                    // would need to have the option to merge the groups for members in their group
                    let button0 = tableView.dequeueReusableCell(withIdentifier: "settingButtonCell") as! SettingButtonCell
                    button0.setUI(title: "Merge storages with group")
                    button0.button.addTarget(self, action: #selector(mergeStoragesWithGroup), for: .touchUpInside)
                    return [cell1, button0, button1, button2]
                } else {
                    let cell2 = tableView.dequeueReusableCell(withIdentifier: "settingBasicCell") as! SettingBasicCell
                    var txt: String {
                        if SharedValues.shared.isStorageWithGroup == true {
                            return "Storage is with group"
                        } else {
                            return "Storage is not with group"
                        }
                    }
                    cell2.setUI(str: txt)
                    return [cell1, cell2, button1, button2]
                }
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
        case .tutorial:
            return []
        case .mealPlanner:
            // If the user has a meal planner
            if SharedValues.shared.mealPlannerID != nil {
                let topCell = tableView.dequeueReusableCell(withIdentifier: "settingTwoLevelCell") as! SettingTwoLevelCell
                let top = "Meal planner members"
                topCell.setUI(top: top, emails: SharedValues.shared.groupEmails ?? [(Auth.auth().currentUser?.email ?? "This device")])
                let button1 = tableView.dequeueReusableCell(withIdentifier: "settingButtonCell") as! SettingButtonCell
                button1.setUI(title: "Delete all items from meal planner")
                button1.button.addTarget(self, action: #selector(deleteItemsFromMealPlanner), for: .touchUpInside)
                let switchCell = tableView.dequeueReusableCell(withIdentifier: "settingSwitchCell") as! SettingSwitchCell
                switchCell.setUIforMealPlanner()
                return [topCell, switchCell, button1]
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "settingBasicCell") as! SettingBasicCell
                cell.setUI(str: "You haven't created a meal planner yet. Go to the meal planner tab to create one!")
                return [cell]
            }
            
        case .review:
            return []
        }
    }
    
    private func createObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(observerSelectorGroupID), name: .groupIDchanged, object: nil)
    }
    
    @objc func observerSelectorGroupID() {
        tableView.reloadData()
    }
    
    @objc func mergeStoragesWithGroup(_ sender: UIButton) {
        sender.alpha = 0.4
        sender.isUserInteractionEnabled = false
        
        // need to merge storages with group
        if let storageID = SharedValues.shared.foodStorageID {
            let groupEmails = Set<String>(SharedValues.shared.groupEmails ?? [])
            var storageEmails = Set<String>(SharedValues.shared.foodStorageEmails ?? [])
            
            if let e = Auth.auth().currentUser?.email {
                storageEmails.insert(e)
            }
            let emailsToAdd = groupEmails.subtracting(storageEmails)
            
            // delete all values from ownUserStorages from group document
            if let groupID = SharedValues.shared.groupID {
                let reference = db.collection("groups").document(groupID)
                reference.updateData([
                    "ownUserStorages": FieldValue.delete()
                ])
            }
            
            FoodStorage.mergeItemsTogetherInStorage(db: self.db, newStorageID: storageID, newEmails: Array(groupEmails))
            
            if !emailsToAdd.isEmpty {
                let ge = Array(groupEmails)
                FoodStorage.updateDataInStorageDocument(db: self.db, foodStorageID: storageID, emails: ge)
            }
        } else {
            let alert = UIAlertController(title: "Error", message: "No storage found, so unable to merge the storages.", preferredStyle: .alert)
            alert.addAction(.init(title: "Ok", style: .default, handler: nil))
            present(alert, animated: true)
        }
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
        self.present(vc, animated: true, completion: nil)
        vc.backOutlet.isHidden = false
        vc.forChange = true
        vc.createUsernameOutlet.setTitle("Change username", for: .normal)
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
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "createGroup") as! CreateGroupVC
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
        
        alert.addAction(.init(title: "Leave group", style: .destructive, handler: {(alert: UIAlertAction!) in User.leaveGroupUser(db: self.db, groupID: SharedValues.shared.groupID ?? " ")}))
        alert.addAction(.init(title: "Back", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    @objc private func editGroupAction() {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "createGroup") as! CreateGroupVC
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
    
    @objc private func deleteItemsFromMealPlanner() {
    
        if let id = SharedValues.shared.mealPlannerID {
            
            let alert = UIAlertController(title: "Are you sure you want to delete all recipes from your meal planner?", message: "This action cannot be undone.", preferredStyle: .alert)
            alert.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(.init(title: "Delete", style: .destructive, handler: { (action) in
                MealPlanner.deleteAllItems(db: self.db, id: id)
            }))
            present(alert, animated: true)
        } else {
            let alert = UIAlertController(title: "You haven't created a meal planner yet.", message: "Go to the meal planner tab to create your meal planner.", preferredStyle: .alert)
            alert.addAction(.init(title: "Ok", style: .default, handler: nil))
            present(alert, animated: true)
        }
        
    }
    
    @objc private func deleteStorage() {
        print("Delete storage")
        let alert = UIAlertController(title: "Are you sure you want to delete your storage?", message: "This action can't be undone", preferredStyle: .alert)
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
// MARK: UpdateScreenDeleagate
extension SettingsDetailVC: UpdateScreenDelegate {
    func updateScreen() {
        navigationController?.popViewController(animated: true)
        self.tabBarController?.createMessageView(color: Colors.messageGreen, text: "Message successfully sent")
    }
    
    
}

// MARK: SettingViewedRecipeCellDelegate
extension SettingsDetailVC: SettingViewedRecipeCellDelegate {
    func recipeDocumentIdPressed(djangoID: Int) {
        self.createLoadingView()
        Network.shared.getSingleRecipe(id: djangoID) { (recipeResponse) in
            self.dismiss(animated: false, completion: nil)
            switch recipeResponse {
            case .success(let recipe):
                let vc = UIStoryboard(name: "Recipes", bundle: nil).instantiateViewController(withIdentifier: "recipeDetailVC") as! RecipeDetailVC
                let data = (UIImage(), recipe)
                vc.data = data
                self.navigationController?.pushViewController(vc, animated: true)
            case .failure(_):
                #warning("need to handle this")
            }
            
        }
    }
    
}

// MARK: Table view
extension SettingsDetailVC: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return returnCells(setting: setting!, db: db).count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return returnCells(setting: setting!, db: db)[indexPath.row]
    }
    
}


