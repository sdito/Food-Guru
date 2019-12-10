//
//  SIgnUpVC.swift
//  smartList
//
//  Created by Steven Dito on 12/5/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class SignUpVC: UIViewController {
    
    @IBOutlet weak var googleCreateAccountOutlet: UIButton!
    @IBOutlet weak var createAccountOutlet: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    var db: Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        createAccountOutlet.border(cornerRadius: 15.0)
        googleCreateAccountOutlet.border(cornerRadius: 15.0)
    }
    
    @IBAction func emailCreateAccount(_ sender: Any) {
        print("This is being pressed")
        #warning("none of this works even a little bit yet")
        Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { (authDataResult, error) in
            guard error == nil else {
                print("Account not created")
                return
                
                
            }
            
            let docRef = self.db.collection("users").document("\(authDataResult?.user.uid ?? " ")")
            
            docRef.getDocument { (document, error) in
                self.db.collection("users").document("\(authDataResult?.user.uid ?? " ")").setData([
                "email": authDataResult?.user.email as Any,
                "uid": authDataResult?.user.uid as Any,
                "name": authDataResult?.user.displayName as Any
                ])
            }
            SharedValues.shared.anonymousUser = false
            SharedValues.shared.userID = authDataResult?.user.uid
            
            let sb: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "tabVC") as! TabVC
            vc.modalPresentationStyle = .fullScreen
            vc.modalTransitionStyle = .crossDissolve
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func googleCreateAccount(_ sender: Any) {
    }
    
    @IBAction func continueAsGuest(_ sender: Any) {
    }
    
    @IBAction func signInAlreadyHaveAccount(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "signInVC") as! SignInVC
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: true, completion: nil)
    }
}
