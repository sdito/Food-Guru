//
//  SignInVC.swift
//  smartList
//
//  Created by Steven Dito on 12/5/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import UIKit
import FirebaseAuth
import GoogleSignIn

class SignInVC: UIViewController {
    @IBOutlet weak var logInOutlet: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logInOutlet.border(cornerRadius: 15.0)
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance()?.presentingViewController = self
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        GIDSignIn.sharedInstance()?.delegate = nil
    }
    
    @IBAction func logIn(_ sender: Any) {
        
        // with email and password
        
        if let email = emailTextField.text, let password = passwordTextField.text {
            if email != "" && password != "" {
                self.createLoadingView(cancelAction: #selector(cancelSelector))
                Auth.auth().signIn(withEmail: email, password: password) { (authDataResult, error) in
                    if error != nil {
                        print("There is an error: \(error?.localizedDescription ?? "unknown error")")
                        self.dismiss(animated: false, completion: nil)
                        let alert = UIAlertController(title: "Error", message: error!.localizedDescription, preferredStyle: .alert)
                        alert.addAction(.init(title: "Ok", style: .default, handler: nil))
                        self.present(alert, animated: true)
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
                        self.dismiss(animated: false, completion: nil)
                        let sb: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        let vc = sb.instantiateViewController(withIdentifier: "tabVC") as! TabVC
                        vc.modalPresentationStyle = .fullScreen
                        vc.modalTransitionStyle = .crossDissolve
                        self.present(vc, animated: true, completion: nil)
                        vc.createMessageView(color: Colors.messageGreen, text: "Welcome \(authDataResult?.user.displayName ?? "")")
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
        
        print("CONTINUE FROM GUEST HERE")
        
        self.createLoadingView(cancelAction: #selector(cancelSelector))
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
    
    @objc func cancelSelector() {
        #warning("need to implement")
        print("Cancel log in process now")
    }

}


extension SignInVC: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        self.createLoadingView(cancelAction: #selector(cancelSelector))
        // ...
        if let error = error {
            print("Error signing in with google account: \(error.localizedDescription)")
            self.dismiss(animated: false, completion: nil)
            return
        }

        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                print(error.localizedDescription)
                self.dismiss(animated: false, completion: nil)
                let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(.init(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true)
                return
            } else {
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
                self.dismiss(animated: false, completion: nil)
                self.present(vc, animated: true, completion: nil)
                vc.createMessageView(color: Colors.messageGreen, text: "Welcome \(Auth.auth().currentUser?.displayName ?? "")")
            }
        }
    }

    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url)
    }
}
