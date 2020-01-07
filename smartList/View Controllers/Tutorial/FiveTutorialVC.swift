//
//  FiveTutorialVC.swift
//  smartList
//
//  Created by Steven Dito on 1/5/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class FiveTutorialVC: UIViewController {
    
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        imageView.pulsateView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        imageView.disappearAnimation()
    }
    

}
