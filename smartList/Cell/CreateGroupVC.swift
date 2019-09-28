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
    var db: Firestore!
    var previousGroupID: String?
    private var selectedEmail: String? {
        didSet {
            collectionView.reloadData()
        }
    }
    
    @IBOutlet weak var exitOutlet: UIButton!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var doneCreatingOutlet: UIButton!
    
    
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
    @IBAction func exit(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func createGroup(_ sender: Any) {
        
        if previousGroupID == nil {
            // create a new group, nothing to do with editing
            User.writeGroupToFirestoreAndAddToUsers(db: db, emails: emails)
            self.dismiss(animated: true, completion: nil)
        } else {
            User.editedGroupInfo(db: db, initialEmails: SharedValues.shared.groupEmails ?? [""], updatedEmails: emails, groupID: SharedValues.shared.groupID ?? " ", storageID: SharedValues.shared.foodStorageID ?? " ")
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    @objc private func addItem() {
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
                        let alert = UIAlertController(title: "Error", message: "This email does not have an account associated with it. Double check the email or ask them to make an account.", preferredStyle: .alert)
                        alert.addAction(.init(title: "Ok", style: .cancel, handler: nil))
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
}


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

extension CreateGroupVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        addItem()
        return true
    }
}



