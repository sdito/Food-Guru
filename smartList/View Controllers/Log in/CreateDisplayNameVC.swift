//
//  CreateUsernameVC.swift
//  smartList
//
//  Created by Steven Dito on 12/12/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class CreateDisplayNameVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var createUsernameOutlet: UIButton!
    @IBOutlet weak var backOutlet: UIButton!
    
    var db: Firestore!
    var forChange: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .dark
        }
        db = Firestore.firestore()
        createUsernameOutlet.border(cornerRadius: 15.0)
        getCurrentNameOrSuggested()
        usernameTextField.setUpDoneToolbar(action: #selector(dismissKeyboard), style: .done)
    }
    
    @IBAction func backPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func createUsername(_ sendrer: Any) {
        // should only be shown if when logging in the user does not already have a username
        if let name = usernameTextField.text {
            let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
            changeRequest?.displayName = name
            changeRequest?.commitChanges(completion: { (error) in
                if let error = error {
                    print(error)
                }
            })
            
            User.setDisplayNameInFirebaseDocument(db: db, displayName: name)
            
            if forChange == false {
                let sb: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = sb.instantiateViewController(withIdentifier: "tabVC") as! TabVC
                vc.modalPresentationStyle = .fullScreen
                vc.modalTransitionStyle = .crossDissolve
                self.present(vc, animated: true, completion: nil)
            } else {
                SharedValues.shared.newUsername = name
                self.dismiss(animated: true, completion: nil)
            }
            
        }
        
    }
    
    private func getCurrentNameOrSuggested() {
        if Auth.auth().currentUser?.displayName != "" || Auth.auth().currentUser?.displayName != nil {
            usernameTextField.text = Auth.auth().currentUser!.displayName
        } else {
            usernameTextField.text = Auth.auth().currentUser?.email?.getBeginningAddress()
        }
    }
    
    @objc private func dismissKeyboard() {
        usernameTextField.resignFirstResponder()
    }
}


