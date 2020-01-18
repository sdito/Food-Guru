//
//  ThreeTutorialVC.swift
//  smartList
//
//  Created by Steven Dito on 1/5/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class ThreeTutorialVC: UIViewController {

    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var topView: UIView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        
        let str = NSMutableAttributedString(string: "From the recipes tab, select the heart on the top right of a recipe to save it for later. These recipes can be found be pressing ")
        let save = NSAttributedString(string: "Saved", attributes: [.foregroundColor:Colors.main])
        str.append(save)
        let second = NSAttributedString(string: " at the bottom. Select ")
        str.append(second)
        let cookbook = NSAttributedString(string: "Cookbook", attributes: [.foregroundColor:Colors.main])
        str.append(cookbook)
        let third = NSAttributedString(string: " to view recipes downloaded on your device")
        str.append(third)
        
        topLabel.attributedText = str
        self.view.setGradientBackground(colorOne: Colors.main, colorTwo: Colors.secondary)
        topView.setUpTutorialLabel()
        
        if SharedValues.shared.isPhone == false {
            topLabel.font = UIFont(name: "futura", size: 17)
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        imageView.pulsateView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        imageView.disappearAnimation()
    }

}
