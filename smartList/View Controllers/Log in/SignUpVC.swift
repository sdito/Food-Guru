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
import GoogleSignIn

class SignUpVC: UIViewController {
    
    @IBOutlet weak var createAccountOutlet: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var db: Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        createAccountOutlet.border(cornerRadius: 15.0)
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance()?.presentingViewController = self
        User.resetSharedValues()
        
        
        print("\(String(describing: Auth.auth().currentUser?.isAnonymous)) is if the current user is anonymous")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        GIDSignIn.sharedInstance()?.delegate = nil
    }
    
    
    @IBAction func emailCreateAccount(_ sender: Any) {
        let isAnonymousAccount = Auth.auth().currentUser?.isAnonymous
        self.createLoadingView(cancelAction: #selector(cancelLoadingPopUp))
        if isAnonymousAccount != true {
            Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { (authDataResult, error) in
                guard error == nil else {
                    print("Account not created")
                    self.dismiss(animated: false, completion: nil)
                    
                    let alert = UIAlertController(title: "Error", message: error!.localizedDescription, preferredStyle: .alert)
                    alert.addAction(.init(title: "Ok", style: .default, handler: nil))
                    self.present(alert, animated: true)
                    
                    return
                }
                
                self.handleNewEmailAccount(authDataResult: authDataResult)
            }
        } else {
            //Need to handle the linking of the accounts (for emails here), can guarantee that this is a new account unlike for google sign in
            #error("need to handle google account linking")
            let emailCredential = EmailAuthProvider.credential(withEmail: emailTextField.text!, password: passwordTextField.text!)
            Auth.auth().currentUser?.link(with: emailCredential, completion: { (authDataResult, error) in
                if error == nil {
                    self.handleNewEmailAccount(authDataResult: authDataResult)
                } else {
                    self.dismiss(animated: false, completion: nil)
                    print(error?.localizedDescription as Any)
                }
            })
        }
        
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
    
    private func handleNewEmailAccount(authDataResult: AuthDataResult?) {
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


extension SignUpVC: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        self.createLoadingView(cancelAction: #selector(cancelLoadingPopUp))
        if let error = error {
            print("Error signing in with google account: \(error.localizedDescription)")
            self.dismiss(animated: false, completion: nil)
            return
        }

        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        print("GOT TO THIS POINT")
        
        
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
