//
//  SevenTutorialVC.swift
//  smartList
//
//  Created by Steven Dito on 3/14/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class SevenTutorialVC: UIViewController {
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        self.view.setGradientBackground(colorOne: Colors.main, colorTwo: Colors.secondary)
        
        topView.setUpTutorialLabel()
        
        
        let str = NSMutableAttributedString(string: "Use your meal planner to track items with your group. Select ")
        let plus = NSAttributedString(string: "+", attributes: [NSAttributedString.Key.foregroundColor: Colors.main])
        str.append(plus)
        let end = NSAttributedString(string: " to add a new recipe to the selected date. You can add recipes from saved recipes, your cookbook, or you can create a new recipe.")
        str.append(end)
        topLabel.attributedText = str
        
        
        if SharedValues.shared.isPhone == false {
            topLabel.font = UIFont(name: "futura", size: 17)
        }
        
        imageView.addLoadingView()
        self.getImageForTutorial(imageText: "seven") { (img) in
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
