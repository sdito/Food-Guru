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
        let end = NSAttributedString(string: " to add a new recipe or note to the selected date. Select ")
        str.append(end)
        
        let image = NSTextAttachment()
        let img = UIImage(named: "order_main")
        let imageString = NSAttributedString(attachment: image)
        let resized = img!.resizeImage(targetSize: CGSize(width: 15, height: 15))
        image.image = resized
        str.append(imageString)
        
        str.append(NSAttributedString(string: " to add the ingredients from the recipes on that date to your shopping list."))
        
        topLabel.attributedText = str
        
        
        if SharedValues.shared.isPhone == false {
            topLabel.font = UIFont(name: "futura", size: 17)
        }
        
        topView.alpha = 0.3
        imageView.addLoadingView()
        self.getImageForTutorial(imageText: "seven") { (img) in
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
