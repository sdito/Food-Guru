//
//  ForgotPasswordVC.swift
//  smartList
//
//  Created by Steven Dito on 12/5/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import UIKit
import FirebaseAuth

class ForgotPasswordVC: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var getPasswordOutlet: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getPasswordOutlet.border(cornerRadius: 15.0)
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func initiatePasswordRecovery(_ sender: Any) {
        getPasswordOutlet.isUserInteractionEnabled = false
        print(emailTextField.text as Any)
        if let email = emailTextField.text {
            Auth.auth().sendPasswordReset(withEmail: email) { error in
                if error == nil {
                    self.dismiss(animated: true, completion: nil)
                    self.getPasswordOutlet.isUserInteractionEnabled = true
                    self.presentingViewController?.createMessageView(color: Colors.messageGreen, text: "Check your email!")
                } else {
                    print(error as Any)
                    self.getPasswordOutlet.isUserInteractionEnabled = true
                }
            }
        } else {
            getPasswordOutlet.isUserInteractionEnabled = true
        }
        
    }
    

}
