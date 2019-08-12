//
//  LogInVC.swift
//  smartList
//
//  Created by Steven Dito on 8/11/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import UIKit
//import FirebaseCore
import FirebaseFirestore
import FirebaseUI

class LogInVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        SharedValues.shared.userID = authDataResult?.user.uid
        performSegue(withIdentifier: "logInComplete", sender: self)
    }
}

