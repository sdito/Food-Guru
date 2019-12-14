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
    var db: Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        createAccountOutlet.border(cornerRadius: 15.0)
        googleCreateAccountOutlet.border(cornerRadius: 15.0)
    }
    
    @IBAction func emailCreateAccount(_ sender: Any) {
        
        self.createLoadingView(cancelAction: #selector(cancelLoadingPopUp))
        
        print("This is being pressed")
        #warning("none of this works yet")
        Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { (authDataResult, error) in
            guard error == nil else {
                print("Account not created")
                self.dismiss(animated: false, completion: nil)
                
                let alert = UIAlertController(title: "Error", message: error!.localizedDescription, preferredStyle: .alert)
                alert.addAction(.init(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true)
                
                return
            }
            
            let docRef = self.db.collection("users").document("\(authDataResult?.user.uid ?? " ")")
            
            docRef.getDocument { (document, error) in
                self.db.collection("users").document("\(authDataResult?.user.uid ?? " ")").setData([
                "email": authDataResult?.user.email as Any,
                "uid": authDataResult?.user.uid as Any
                ])
            }
            SharedValues.shared.anonymousUser = false
            SharedValues.shared.userID = authDataResult?.user.uid
            
            
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "createUsernameVC") as! CreateDisplayNameVC
            vc.modalPresentationStyle = .fullScreen
            vc.modalTransitionStyle = .crossDissolve
            self.dismiss(animated: false, completion: nil)
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func googleCreateAccount(_ sender: Any) {
        print("Google create account time")
    }
    
    @IBAction func continueAsGuest(_ sender: Any) {
        self.createLoadingView(cancelAction: #selector(cancelLoadingPopUp))
        Auth.auth().signInAnonymously { (authDataResult, error) in
            if error == nil {
                let sb: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = sb.instantiateViewController(withIdentifier: "tabVC") as! TabVC
                vc.modalPresentationStyle = .fullScreen
                vc.modalTransitionStyle = .crossDissolve
                if Auth.auth().currentUser != nil {
                    SharedValues.shared.userID = Auth.auth().currentUser?.uid
                    
                    if Auth.auth().currentUser?.isAnonymous == true {
                        SharedValues.shared.anonymousUser = true
                    } else {
                        SharedValues.shared.anonymousUser = false
                    }
                    
                }
                self.dismiss(animated: false, completion: nil)
                self.present(vc, animated: true, completion: nil)
            } else {
                self.dismiss(animated: false, completion: nil)
                let alert = UIAlertController(title: "Error", message: "Unable to sign in anonymously", preferredStyle: .alert)
                alert.addAction(.init(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true)
            }
        }
    }
    
    @IBAction func signInAlreadyHaveAccount(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "signInVC") as! SignInVC
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: true, completion: nil)
    }
    
    
    
    @objc func cancelLoadingPopUp() {
        print("cancel pressed")
    }
}
