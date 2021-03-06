//
//  OneTutorialVC.swift
//  smartList
//
//  Created by Steven Dito on 1/5/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit


class OneTutorialVC: UIViewController {
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var arrow: UIImageView!
    
    private var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        
        self.view.setGradientBackground(colorOne: Colors.main, colorTwo: Colors.secondary)
        topView.setUpTutorialLabel()
        
        if SharedValues.shared.isPhone == false {
            topLabel.font = UIFont(name: "futura", size: 17)
        }
        
        
        
        imageView.addLoadingView()
        topView.alpha = 0.3
        self.getImageForTutorial(imageText: "one") { (img) in
            self.imageView.removeLoadingView()
            self.imageView.image = img
            self.topView.alpha = 1.0
        }
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        imageView.pulsateView()
        
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false, block: { (tmr) in
            print("Timer was fired")
            self.arrow.setIsHidden(false, animated: true)
        })
        
        (self.parent as? TutorialVC)?.button.isHidden = false
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        imageView.disappearAnimation()
        arrow.setIsHidden(true, animated: true)
        timer?.invalidate()
    }
    

}



