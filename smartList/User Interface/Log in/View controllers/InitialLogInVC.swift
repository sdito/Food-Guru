//
//  InitialLogInVC.swift
//  smartList
//
//  Created by Steven Dito on 12/5/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import AuthenticationServices
import CryptoKit
import GoogleSignIn




class InitialLogInVC: UIViewController {
    
    @IBOutlet weak var createAccountOutlet: UIButton!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var googleSignInButton: GIDSignInButton!
    
    fileprivate var currentNonce: String?
    var db: Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .dark
        }
        createAccountOutlet.border(cornerRadius: 5.0)
        db = Firestore.firestore()
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance()?.presentingViewController = self
        User.resetSharedValues()
        
        if #available(iOS 13.0, *) {
            let button = ASAuthorizationAppleIDButton()
            button.addTarget(self, action: #selector(startSignInWithAppleFlow), for: .touchUpInside)
            stackView.insertArrangedSubview(button, at: 0)
            button.widthAnchor.constraint(equalTo: createAccountOutlet.widthAnchor).isActive = true
            
        }
        
        googleSignInButton.widthAnchor.constraint(equalTo: createAccountOutlet.widthAnchor).isActive = true
        googleSignInButton.style = .wide
        
    }
    
    
    
    @IBAction func createAccount(_ sender: Any) {
        print("Create account")
        let vc = storyboard?.instantiateViewController(withIdentifier: "signUpVC") as! SignUpVC
        vc.modalPresentationStyle = .fullScreen
//        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: true, completion: nil)
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
                    let alert = UIAlertController(title: "Error", message: "Unable to sign in anonymously", preferredStyle: .alert)
                    alert.addAction(.init(title: "Ok", style: .default, handler: nil))
                    self.present(alert, animated: true)
                }
                
            }
        }
    }
    @IBAction func logIn(_ sender: Any) {
        print("Log in")
        let vc = storyboard?.instantiateViewController(withIdentifier: "signInVC") as! SignInVC
        vc.modalPresentationStyle = .fullScreen
//        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: true, completion: nil)
        
    }
    
    private func normalGoogleLogIn(credential: AuthCredential) {
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                print(error.localizedDescription)
                self.dismiss(animated: false) {
                    let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(.init(title: "Ok", style: .default, handler: nil))
                    self.present(alert, animated: true)
                }
                return
            } else {
                self.handleNewGoogleAccount(authDataResult: authResult, isLinked: false)
            }
        }
    }
    
    private func handleNewGoogleAccount(authDataResult: AuthDataResult?, isLinked: Bool) {
        
        // just put below
        let docRef = self.db.collection("users").document("\(authDataResult?.user.uid ?? " ")")
        docRef.updateData([
            "email": authDataResult?.user.email as Any,
            "uid": authDataResult?.user.uid as Any,
            "name": authDataResult?.user.displayName as Any
        ]) { err in
            if err != nil {
                docRef.setData([
                    "email": authDataResult?.user.email as Any,
                    "uid": authDataResult?.user.uid as Any,
                    "name": authDataResult?.user.displayName as Any
                ])
            }
        }
        
        // end of new stuff
        
        if Auth.auth().currentUser != nil {
            SharedValues.shared.userID = Auth.auth().currentUser?.uid

            if Auth.auth().currentUser?.isAnonymous == true {
                SharedValues.shared.anonymousUser = true
            } else {
              SharedValues.shared.anonymousUser = false
            }
        }
        
        if isLinked == true {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "createUsernameVC") as! CreateDisplayNameVC
            vc.modalPresentationStyle = .fullScreen
            vc.modalTransitionStyle = .crossDissolve
//            self.dismiss(animated: false, completion: nil)
            self.dismiss(animated: false) {
                self.present(vc, animated: true, completion: nil)
            }
            
        } else {
            let sb: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "tabVC") as! TabVC
            vc.modalPresentationStyle = .fullScreen
            vc.modalTransitionStyle = .crossDissolve
//            self.dismiss(animated: false, completion: nil)
            self.dismiss(animated: false) {
                self.present(vc, animated: true, completion: nil)
                vc.createMessageView(color: Colors.messageGreen, text: "Welcome \(Auth.auth().currentUser?.displayName ?? "")")
            }
            
        }
    }
    
    // Start of apple log in stuff
    
    @objc @available(iOS 13, *)
    private func startSignInWithAppleFlow() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self as? ASAuthorizationControllerPresentationContextProviding
        authorizationController.performRequests()
    }
    
    
    

    @available(iOS 13.0, *)
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        return hashString
    }
    
    private func randomNonceString(length: Int = 32) -> String {
      precondition(length > 0)
      let charset: Array<Character> = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
      var result = ""
      var remainingLength = length

      while remainingLength > 0 {
        let randoms: [UInt8] = (0 ..< 16).map { _ in
          var random: UInt8 = 0
          let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
          if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
          }
          return random
        }

        randoms.forEach { random in
          if length == 0 {
            return
          }

          if random < charset.count {
            result.append(charset[Int(random)])
            remainingLength -= 1
          }
        }
      }

      return result
    }
}

extension InitialLogInVC: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        
        if let error = error {
            print("Error signing in with google account: \(error.localizedDescription)")
//            self.dismiss(animated: false, completion: nil)
            let alert = UIAlertController(title: nil, message: "Error signing in with google account, please try again.", preferredStyle: .alert)
            alert.addAction(.init(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
        
        self.createLoadingView()
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        print("GOT TO THIS POINT")
        
        let isAnonymousAccount = Auth.auth().currentUser?.isAnonymous
        
        if isAnonymousAccount == true {
            Auth.auth().currentUser?.link(with: credential, completion: { (authDataResult, error) in
                if error != nil {
                    self.normalGoogleLogIn(credential: credential)
                    return
                } else {
                    self.handleNewGoogleAccount(authDataResult: authDataResult, isLinked: true)
                }
            })
            
        } else {
            normalGoogleLogIn(credential: credential)
        }
        
        
    }

    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url)
    }
    
}


extension InitialLogInVC: ASAuthorizationControllerDelegate {
    private func normalAppleLogIn(credential: OAuthCredential) {
        Auth.auth().signIn(with: credential) { (authDataResult, error) in
            if error == nil {
                if let uid = authDataResult?.user.uid {
                    let reference = self.db.collection("users").document(uid)
                    reference.updateData([
                        "email": authDataResult?.user.email as Any,
                        "uid": authDataResult?.user.uid as Any,
                        "name": Auth.auth().currentUser?.displayName as Any
                    ]) { err in
                        if err != nil {
                            reference.setData([
                                "email": authDataResult?.user.email as Any,
                                "uid": authDataResult?.user.uid as Any,
                                "name": Auth.auth().currentUser?.displayName as Any
                            ])
                        }
                    }
                }
                
                SharedValues.shared.anonymousUser = false
                SharedValues.shared.userID = Auth.auth().currentUser?.uid
                
                if Auth.auth().currentUser?.displayName == nil {
                    // go to create username VC
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "createUsernameVC") as! CreateDisplayNameVC
                    vc.modalPresentationStyle = .fullScreen
                    vc.modalTransitionStyle = .crossDissolve
                    self.dismiss(animated: false) {
                        self.present(vc, animated: true, completion: nil)
                    }
                    
                } else {
                    let sb: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = sb.instantiateViewController(withIdentifier: "tabVC") as! TabVC
                    vc.modalPresentationStyle = .fullScreen
                    vc.modalTransitionStyle = .crossDissolve
                    self.dismiss(animated: false) {
                        print("This is being called")
                        self.present(vc, animated: true, completion: nil)
                        vc.createMessageView(color: Colors.messageGreen, text: "Welcome \(authDataResult?.user.displayName ?? "")")
                    }
                    
                }
            } else {
//                self.dismiss(animated: false, completion: nil)
                
                let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                alert.addAction(.init(title: "Ok", style: .default, handler: nil))
                self.dismiss(animated: false) {
                    self.present(alert, animated: true)
                }
            }
        }
    }
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            self.createLoadingView()
            guard let nonce = currentNonce else {
                self.dismiss(animated: false, completion: nil)
                
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                self.dismiss(animated: false) {
                    let alert = UIAlertController(title: "Error", message: "A problem occured trying to log in with apple. Please try again. ", preferredStyle: .alert)
                    alert.addAction(.init(title: "Ok", style: .default, handler: nil))
                    self.present(alert, animated: true)
                }
                
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                self.dismiss(animated: false) {
                    let alert = UIAlertController(title: "Error", message: "There was a problem when trying to log in with apple. Please try again.", preferredStyle: .alert)
                    alert.addAction(.init(title: "Ok", style: .default, handler: nil))
                    self.present(alert, animated: true)
                }
                
                
                return
            }
            
            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
            
            let isAnonymous = SharedValues.shared.anonymousUser
            if isAnonymous == false || isAnonymous == nil {
                normalAppleLogIn(credential: credential)
            } else {
                print("They have an anonymous account")
                // Means they are currently logged in under an anonymous account
                // try to link the account, if linking does not work, then do the normal sign in process, create username if needed
                Auth.auth().currentUser?.link(with: credential, completion: { (authDataResult, error) in
                    if error == nil {
                        // then they can correctly link the account
                        if let uid = authDataResult?.user.uid {
                            let reference = self.db.collection("users").document(uid)
                            reference.updateData([
                                "email": authDataResult?.user.email as Any,
                                "uid": authDataResult?.user.uid as Any
                            ])
                        }
                        SharedValues.shared.anonymousUser = false
                        SharedValues.shared.userID = Auth.auth().currentUser?.uid
                        
                        // will always need to create a new username when the accounts are linked
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "createUsernameVC") as! CreateDisplayNameVC
                        vc.modalPresentationStyle = .fullScreen
                        vc.modalTransitionStyle = .crossDissolve
                        self.dismiss(animated: false) {
                            self.present(vc, animated: true, completion: nil)
                        }
                        
                        
                    } else {
                        // do normal sign in since linking is not possible with the account situation (there is an error)
                        self.normalAppleLogIn(credential: credential)
                    }
                })
            }
        }
  }

    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
    // Handle error.
    print("Sign in with Apple errored: \(error)")
  }

}
