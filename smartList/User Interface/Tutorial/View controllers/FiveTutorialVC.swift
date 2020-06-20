//
//  FiveTutorialVC.swift
//  smartList
//
//  Created by Steven Dito on 1/5/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class FiveTutorialVC: UIViewController {
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        self.view.setGradientBackground(colorOne: Colors.main, colorTwo: Colors.secondary)
        
        let image = NSTextAttachment()
        let img = UIImage(named: "checked-checkbox-xxl")
        let imageString = NSAttributedString(attachment: image)
        
        let resized = img!.resizeImage(targetSize: CGSize(width: 15, height: 15))
        
        image.image = resized
        
        let str = NSMutableAttributedString(string: "Select ")
        str.append(imageString)
        str.append(NSAttributedString(string: " to add the selected items from your list to your storage"))
        
        topLabel.attributedText = str
        
        topView.setUpTutorialLabel()
        
        if SharedValues.shared.isPhone == false {
            topLabel.font = UIFont(name: "futura", size: 17)
        }
        
        topView.alpha = 0.3
        imageView.addLoadingView()
        self.getImageForTutorial(imageText: "five") { (img) in
            self.imageView.image = img
            self.imageView.removeLoadingView()
            self.topView.alpha = 1.0
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
