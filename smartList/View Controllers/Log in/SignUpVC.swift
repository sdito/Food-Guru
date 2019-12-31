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
    
    @IBOutlet weak var createAccountOutlet: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var db: Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        createAccountOutlet.border(cornerRadius: 15.0)
        
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        emailTextField.setUpDoneToolbar(action: #selector(dismissTextfield), style: .done)
        passwordTextField.setUpDoneToolbar(action: #selector(dismissTextfield), style: .done)
    }
    
    
    
    @IBAction func emailCreateAccount(_ sender: Any) {
        let isAnonymousAccount = Auth.auth().currentUser?.isAnonymous
        self.createLoadingView()
        if isAnonymousAccount != true {
            Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { (authDataResult, error) in
                guard error == nil else {
                    print("Account not created")
                    self.dismiss(animated: false) {
                        let alert = UIAlertController(title: "Error", message: error!.localizedDescription, preferredStyle: .alert)
                        alert.addAction(.init(title: "Ok", style: .default, handler: nil))
                        self.present(alert, animated: true)
                    }
                    
                    return
                }
                
                self.handleNewEmailAccount(authDataResult: authDataResult)
            }
        } else {
            //Need to handle the linking of the accounts (for emails here), can guarantee that this is a new account unlike for google sign in
            
            let emailCredential = EmailAuthProvider.credential(withEmail: emailTextField.text!, password: passwordTextField.text!)
            Auth.auth().currentUser?.link(with: emailCredential, completion: { (authDataResult, error) in
                if error == nil {
                    self.handleNewEmailAccount(authDataResult: authDataResult)
                } else {
                    self.dismiss(animated: false) {
                        let alert = UIAlertController(title: "Error", message: "Please try logging in again.", preferredStyle: .alert)
                        alert.addAction(.init(title: "Ok", style: .default, handler: nil))
                        self.present(alert, animated: true)
                    }
                }
            })
        }
        
    }
    @IBAction func backPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func continueAsGuest(_ sender: Any) {
        self.createLoadingView()
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
                self.dismiss(animated: false) {
                    self.present(vc, animated: true, completion: nil)
                }
                
            } else {
                
                let alert = UIAlertController(title: "Error", message: "Unable to sign in anonymously", preferredStyle: .alert)
                alert.addAction(.init(title: "Ok", style: .default, handler: nil))
                self.dismiss(animated: false) {
                    self.present(alert, animated: true)
                }
                
            }
        }
    }
    
    @IBAction func signInAlreadyHaveAccount(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "signInVC") as! SignInVC
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: true, completion: nil)
    }
    
    
    
    private func handleNewEmailAccount(authDataResult: AuthDataResult?) {
        let docRef = self.db.collection("users").document("\(authDataResult?.user.uid ?? " ")")
        docRef.getDocument { (document, error) in
            self.db.collection("users").document("\(authDataResult?.user.uid ?? " ")").updateData([
            "email": authDataResult?.user.email as Any,
            "uid": authDataResult?.user.uid as Any
            ]) { err in
                if err != nil {
                    docRef.setData([
                        "email": authDataResult?.user.email as Any,
                        "uid": authDataResult?.user.uid as Any
                    ])
                }
            }
        }
        SharedValues.shared.anonymousUser = false
        SharedValues.shared.userID = authDataResult?.user.uid
        
        
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "createUsernameVC") as! CreateDisplayNameVC
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .crossDissolve
        self.dismiss(animated: false) {
            self.present(vc, animated: true, completion: nil)
        }
        
    }
    
    

}



extension SignUpVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            textField.resignFirstResponder()
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            textField.resignFirstResponder()
            emailTextField.becomeFirstResponder()
        }
        return true
    }
    
    @objc private func dismissTextfield() {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
}

