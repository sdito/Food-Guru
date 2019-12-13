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
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var createUsernameOutlet: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        createUsernameOutlet.border(cornerRadius: 15.0)
        usernameTextField.text = Auth.auth().currentUser?.email?.getBeginningAddress()
    }
    
    @IBAction func createUsername(_ sender: Any) {
        self.createLoadingView(cancelAction: #selector(cancelSelector))
        if let name = usernameTextField.text {
            Auth.auth().currentUser?.createProfileChangeRequest().displayName = name
            User.setDisplayNameInFirebaseDocument(db: db, displayName: name)
            let sb: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "tabVC") as! TabVC
            vc.modalPresentationStyle = .fullScreen
            vc.modalTransitionStyle = .crossDissolve
            self.dismiss(animated: false, completion: nil)
            self.present(vc, animated: true, completion: nil)
        } else {
            self.dismiss(animated: false, completion: nil)
        }
        
    }
    
    @objc func cancelSelector() {
        #warning("not implemented")
    }
}
