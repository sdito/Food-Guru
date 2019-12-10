//
//  ForgotPasswordVC.swift
//  smartList
//
//  Created by Steven Dito on 12/5/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import UIKit

class ForgotPasswordVC: UIViewController {

    @IBOutlet weak var getPasswordOutlet: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getPasswordOutlet.border(cornerRadius: 15.0)
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func initiatePasswordRecovery(_ sender: Any) {
        print("Get the password back here")
    }
    

}
