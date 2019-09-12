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
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var textField: UITextField!
    
    
    var emails: [String] = [(Auth.auth().currentUser?.email)!] {
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
    }
    @IBAction func exit(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func createGroup(_ sender: Any) {
        User.writeGroupToFirestoreAndAddToUsers(db: db, emails: emails)
        
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension CreateGroupVC: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emails.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "groupNameCell", for: indexPath) as! GroupNameCell
        let email = emails[indexPath.row]
        cell.setUI(str: email)
        
        return cell
    }
}

extension CreateGroupVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        User.checkIfEmailIsValid(db: db, email: textField.text!) { (ec) in
            if let ec = ec {
                switch ec {
                case .approved:
                    self.emails.append(textField.text!)
                    textField.text = ""
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
        return true
    }
}



