//
//  CreateGroupVC.swift
//  smartList
//
//  Created by Steven Dito on 9/10/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class CreateGroupVC: UIViewController {
    
    @IBOutlet weak var exitOutlet: UIButton!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var doneCreatingOutlet: UIButton!
    
    var db: Firestore!
    var previousGroupID: String?
    private var selectedEmail: String? {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var emails: [String] = SharedValues.shared.groupEmails ?? [(Auth.auth().currentUser?.email)!] {
        didSet {
            collectionView.reloadData()
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        collectionView.dataSource = self
        collectionView.delegate = self
        textField.delegate = self
        textField.becomeFirstResponder()
        textField.setUpDoneToolbar(action: #selector(addItem), style: .add)
        textField.setUpStandardFormat(text: "Enter user's email")
        
        if previousGroupID == nil {
            doneCreatingOutlet.setTitle("Create group", for: .normal)
        } else if previousGroupID != nil {
            doneCreatingOutlet.setTitle("Done editing", for: .normal)
        }
    }
    
    // MARK: @IBAction funcs
    
    @IBAction func addUser(_ sender: Any) {
        print("Add user pressed")
        addItem()
    }
    
    @IBAction func appleEmailAlert(_ sender: Any) {
        let alert = UIAlertController(title: "Apple account", message: "If you are getting an error while trying to add someone to your group, it could be due to them creating an account with Apple. If the individal selected the option to hide their email when creating an account, then the user will need to go to the settings of this app, click on 'Account,' and then find the email that is associated with their account there.", preferredStyle: .alert)
        alert.addAction(.init(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true)
    }
    
    @IBAction func exit(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func createGroup(_ sender: Any) {
        doneCreatingOutlet.isUserInteractionEnabled = false
        doneCreatingOutlet.alpha = 0.4
        
        print("Prev group id: \(previousGroupID ?? "none")")
        print("Previous emails: \(SharedValues.shared.groupEmails?.joined(separator: ", ") ?? "none")")
        print("New emails: \(emails.joined(separator: ", "))")
        
        if previousGroupID == nil {
            // create a new group, nothing to do with editing
            User.writeGroupToFirestoreAndAddToUsers(db: db, emails: emails)
//            MealPlanner.handleMealPlannerForGroupChangeOrNewGroup(db: db, oldEmails: nil, newEmails: emails, mealPlannerID: SharedValues.shared.mealPlannerID)
            self.presentingViewController?.createMessageView(color: Colors.messageGreen, text: "Group created")
            self.dismiss(animated: true, completion: nil)
            
        } else {
            // need to edit the group
            #error("not properly updating the group info, and not updating the new group info on the user's profiles")
            User.editedGroupInfo(db: db, initialEmails: SharedValues.shared.groupEmails ?? [""], updatedEmails: emails, groupID: SharedValues.shared.groupID ?? " ", storageID: SharedValues.shared.foodStorageID ?? " ")
//            MealPlanner.handleMealPlannerForGroupChangeOrNewGroup(db: db, oldEmails: SharedValues.shared.groupEmails, newEmails: emails, mealPlannerID: SharedValues.shared.mealPlannerID)
            self.presentingViewController?.createMessageView(color: Colors.messageGreen, text: "Group edited")
            self.dismiss(animated: true, completion: nil)
            
        }
        
        
    }
    
    
    // MARK: functions
    @objc private func addItem() {
        let email = textField.text!
        if emails.contains(textField.text!) == false {
            User.checkIfEmailIsValid(db: db, email: textField.text!) { (ec) in
                if let ec = ec {
                    switch ec {
                    case .approved:
                        self.emails.append(self.textField.text!)
                        self.textField.text = ""
                    case .alreadyInGroup:
                        let alert = UIAlertController(title: "Error", message: "This user is in a group. Ask them to leave the group they are currently in if you want them to join your group.", preferredStyle: .alert)
                        alert.addAction(.init(title: "Ok", style: .cancel, handler: nil))
                        self.present(alert, animated: true)
                    case .noUser:
                        let alert = UIAlertController(title: "Error", message: "This email does not have an account associated with it. Invite them to the app in order to have them in your group!.", preferredStyle: .alert)
                        alert.addAction(.init(title: "Invite", style: .default, handler: {alert in
                            self.sendEmail(email: email)
                        }))
                        alert.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
                        self.present(alert, animated: true)
                    }
                }
            }
        } else {
            let alert = UIAlertController(title: "Error", message: "User is already in your group", preferredStyle: .alert)
            alert.addAction(.init(title: "Ok", style: .cancel, handler: nil))
            present(alert, animated: true)
            textField.text = ""
        }
    }
    private func sendEmail(email: String) {
        let subject = "Join%20my%20group%20on%20Food%20Guru!"
        let link = URL(string: "https://apps.apple.com/us/app/food-guru:-recipes-and-more/id1493046325?ls=1")!
        let body = "Here%20is%20the%20link%20to%20download%20the%20app%20on%20the%20appstore:%20\(link)"
        
        if let url = URL(string: "mailto:\(email)?&subject=\(subject)&body=\(body)") {
            UIApplication.shared.open(url)
            
        }
    }
}

// MARK: Collection View extension
extension CreateGroupVC: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emails.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "groupNameCell", for: indexPath) as! GroupNameCell
        let email = emails[indexPath.row]
        cell.setUI(str: email, selectedEmail: selectedEmail)
        cell.deleteButton.addTarget(self, action: #selector(deleteEmailSelector), for: .touchUpInside)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(emails[indexPath.row])
        let path = emails[indexPath.row]
        if path == selectedEmail {
            selectedEmail = nil
        } else {
            selectedEmail = emails[indexPath.row]
            
        }
        
    }
    
    @objc func deleteEmailSelector() {
        if selectedEmail != Auth.auth().currentUser?.email {
            emails = emails.filter({$0 != selectedEmail})
        } else {
            let alert = UIAlertController(title: "Error", message: "If you want to leave the group, select 'Leave current group' from previous screen", preferredStyle: .alert)
            alert.addAction(.init(title: "Ok", style: .cancel, handler: nil))
            present(alert, animated: true)
            selectedEmail = nil
        }
    }
}

// MARK: Text field extension
extension CreateGroupVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        addItem()
        return true
    }
}



