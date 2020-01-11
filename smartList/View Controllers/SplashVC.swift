//
//  SplashVC.swift
//  smartList
//
//  Created by Steven Dito on 1/11/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class SplashVC: UIViewController {
    
    @IBOutlet weak var label: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        UIView.animate(withDuration: 0.2, delay: 0.35, animations: {
            self.label.center.x += 50
        }) { (done) in
            UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseIn, animations: {
                self.label.center.x -= self.view.bounds.width - (self.label.bounds.width/2) + 50
            }) { (complete) in
                let sb: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = sb.instantiateViewController(withIdentifier: "tabVC") as! TabVC
                vc.modalPresentationStyle = .fullScreen
                vc.modalTransitionStyle = .crossDissolve
                self.present(vc, animated: true, completion: nil)
            }
        }
        
    }
    

}

/*
 let sb: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
 let vc = sb.instantiateViewController(withIdentifier: "tabVC") as! TabVC
 vc.modalPresentationStyle = .fullScreen
 vc.modalTransitionStyle = .crossDissolve
 self.present(vc, animated: true, completion: nil)
 */
