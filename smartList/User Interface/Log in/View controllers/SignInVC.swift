//
//  SignInVC.swift
//  smartList
//
//  Created by Steven Dito on 12/5/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import UIKit
import FirebaseAuth

class SignInVC: UIViewController {
    
    @IBOutlet weak var logInOutlet: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logInOutlet.border(cornerRadius: 15.0)
        
        emailTextField.setUpDoneToolbar(action: #selector(dismissKeyboard), style: .done)
        passwordTextField.setUpDoneToolbar(action: #selector(dismissKeyboard), style: .done)
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    // MARK: @IBAction funcs
    @IBAction func logIn(_ sender: Any) {
        // with email and password
        if let email = emailTextField.text, let password = passwordTextField.text {
            if email != "" && password != "" {
                self.createLoadingView()
                Auth.auth().signIn(withEmail: email, password: password) { (authDataResult, error) in
                    if error != nil {
                        print("There is an error: \(error?.localizedDescription ?? "unknown error")")
                        self.dismiss(animated: false) {
                            let alert = UIAlertController(title: "Error", message: error!.localizedDescription, preferredStyle: .alert)
                            alert.addAction(.init(title: "Ok", style: .default, handler: nil))
                            self.present(alert, animated: true)
                        }
                        
                    } else {
                        print("Successfully logged in")
                        if Auth.auth().currentUser != nil {
                            SharedValues.shared.userID = Auth.auth().currentUser?.uid
                            
                            if Auth.auth().currentUser?.isAnonymous == true {
                                SharedValues.shared.anonymousUser = true
                            } else {
                                SharedValues.shared.anonymousUser = false
                            }
                            
                        }
                        
                        let sb: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        let vc = sb.instantiateViewController(withIdentifier: "tabVC") as! TabVC
                        vc.modalPresentationStyle = .fullScreen
                        vc.modalTransitionStyle = .crossDissolve
                        
                        self.dismiss(animated: false) {
                            self.present(vc, animated: true, completion: nil)
                            vc.createMessageView(color: Colors.messageGreen, text: "Welcome \(authDataResult?.user.displayName ?? "")")
                        }
                        
                    }
                }
            } else {
                let alert = UIAlertController(title: "Error", message: "Not all fields are filled in.", preferredStyle: .alert)
                alert.addAction(.init(title: "Ok", style: .default, handler: nil))
                present(alert, animated: true)
            }
        }
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
                self.dismiss(animated: false) {
                    let alert = UIAlertController(title: "Error", message: "Unable to sign in. Please try again.", preferredStyle: .alert)
                    alert.addAction(.init(title: "Ok", style: .default, handler: nil))
                    self.present(alert, animated: true)
                }
                
            }
        }
    }
    
    @IBAction func forgotPassword(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "forgotPasswordVC") as! ForgotPasswordVC
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func noAccountSignUp(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "signUpVC") as! SignUpVC
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func backPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}



// MARK: Text field delegate
extension SignInVC: UITextFieldDelegate {
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
    
    @objc private func dismissKeyboard() {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
}
