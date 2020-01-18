//
//  SixTutorialVC.swift
//  smartList
//
//  Created by Steven Dito on 1/5/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class SixTutorialVC: UIViewController {
    
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        
        let image = NSTextAttachment()
        
        let img = UIImage(named: "link-5-xl")
        
        let imageString = NSAttributedString(attachment: image)
        let resized = img!.resizeImage(targetSize: CGSize(width: 15, height: 15))
        image.image = resized
        let str = NSMutableAttributedString(string: "To create a recipe, for your cookbook or for everyone, either select ")
        str.append(imageString)
        let second = NSAttributedString(string: " and paste an allrecipes.com recipe or fill in the fields yourself. Recipes can be scaled for how many servings you want.")
        str.append(second)
        
        topLabel.attributedText = str
        self.view.setGradientBackgroundTutorial(colorOne: Colors.main, colorTwo: Colors.secondary)
        topView.setUpTutorialLabel()
        
        if SharedValues.shared.isPhone == false {
            topLabel.font = UIFont(name: "futura", size: 17)
        }
        
    }
    override func viewDidAppear(_ animated: Bool) {
        imageView.pulsateView()
        (self.parent as? TutorialVC)?.button.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        imageView.disappearAnimation()
    }

}
