//
//  LogInVC.swift
//  smartList
//
//  Created by Steven Dito on 8/11/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseUI

class LogInVC: UIViewController {
    var db: Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
    }

    @IBAction func logInStart(_ sender: Any) {
    
        let authUI = FUIAuth.defaultAuthUI()
        guard authUI != nil else {
            return
        }
        
        authUI?.delegate = self
        authUI?.providers = [FUIEmailAuth(), FUIGoogleAuth()]
        
        let authViewController = authUI!.authViewController()
        present(authViewController, animated: true, completion: nil)
    }
}


extension LogInVC: FUIAuthDelegate {
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        guard error == nil else {
            //log the error
            return
        }
        
        
        //to check to see if user is already in user database, if not write email and uid into firestore
        let docRef = db.collection("users").document("\(authDataResult?.user.uid ?? "")")
        
        docRef.getDocument { (document, error) in
            if document?.exists == false {
                self.db.collection("users").document("\(authDataResult?.user.uid ?? "")").setData([
                    "email": authDataResult?.user.email! as Any,
                    "uid": authDataResult?.user.uid as Any,
                    "name": authDataResult?.user.displayName as Any
                    ])
            }
        }
        
        SharedValues.shared.userID = authDataResult?.user.uid
        performSegue(withIdentifier: "logInComplete", sender: self)
    }
}

