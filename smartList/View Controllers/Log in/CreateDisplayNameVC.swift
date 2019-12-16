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

class CreateDisplayNameVC: UIViewController {
    var db: Firestore!
    var forChange: Bool = false
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var createUsernameOutlet: UIButton!
    @IBOutlet weak var backOutlet: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        createUsernameOutlet.border(cornerRadius: 15.0)
        getCurrentNameOrSuggested()
    }
    
    @IBAction func backPressed(_ sender: Any) {
        print("Back pressed")
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func createUsername(_ sendrer: Any) {
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
                self.dismiss(animated: true, completion: nil)
                self.presentingViewController?.createMessageView(color: Colors.messageGreen, text: "Welcome \(name)")
                #error("left off here, need to reload settings when display name is changed")
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
    
    @objc func cancelSelector() {
        #warning("not implemented")
    }
}
