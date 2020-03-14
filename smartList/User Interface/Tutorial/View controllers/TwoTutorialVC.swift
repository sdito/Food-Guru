//
//  TwoTutorialVC.swift
//  smartList
//
//  Created by Steven Dito on 1/5/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class TwoTutorialVC: UIViewController {

    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        self.view.setGradientBackgroundTutorial(colorOne: Colors.main, colorTwo: Colors.secondary)
        
        topView.setUpTutorialLabel()
        
        if SharedValues.shared.isPhone == false {
            topLabel.font = UIFont(name: "futura", size: 17)
        }
        
        imageView.addLoadingView()
        self.getImageForTutorial(imageText: "two") { (img) in
            self.imageView.image = img
            self.imageView.removeLoadingView()
        }
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        imageView.pulsateView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        imageView.disappearAnimation()
    }
    

}
