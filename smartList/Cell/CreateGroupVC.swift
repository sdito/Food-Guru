//
//  CreateGroupVC.swift
//  smartList
//
//  Created by Steven Dito on 9/10/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import UIKit
import FirebaseFirestore

class CreateGroupVC: UIViewController {
    var db: Firestore!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var textField: UITextField!
    
    var emails: [String] = [] {
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
        User.writeGroupToFirestore(db: db, emails: emails)
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
        if textField.text != "" {
            emails.append(textField.text!)
            textField.text = ""
        }
        return true
    }
}
