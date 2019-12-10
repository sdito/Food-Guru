//
//  SignInVC.swift
//  smartList
//
//  Created by Steven Dito on 12/5/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import UIKit

class SignInVC: UIViewController {
    @IBOutlet weak var logInOutlet: UIButton!
    @IBOutlet weak var googleLogInOutlet: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logInOutlet.border(cornerRadius: 15.0)
        googleLogInOutlet.border(cornerRadius: 15.0)
    }
    @IBAction func logIn(_ sender: Any) {
        // with email and password
    }
    @IBAction func logInWithGoogle(_ sender: Any) {
    }
    @IBAction func continueAsGuest(_ sender: Any) {
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
    

}
