//
//  SettingsHomeVC.swift
//  smartList
//
//  Created by Steven Dito on 9/5/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import UIKit

class SettingsHomeVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func settings(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "logIn") as! LogInVC
        //let vc = self.storyboard?.instantiateInitialViewController(withIdentifier: "logIn") as! LogInVC
        present(vc, animated: true, completion: nil)
    }

}
