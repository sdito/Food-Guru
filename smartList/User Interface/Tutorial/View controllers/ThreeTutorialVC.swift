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
        
        let str = NSMutableAttributedString(string: "From the home tab, select the ")
        let image = NSTextAttachment()
        let img = UIImage(named: "star_search")
        let imageString = NSAttributedString(attachment: image)
        let resized = img!.resizeImage(targetSize: CGSize(width: 25, height: 25))
        image.image = resized
        str.append(imageString)
        let next = NSAttributedString(string: " to get to the advanced search menu. This is the same as with searching from the search bar, but there are more options and you have more control. For ingredients, you can have multiple by separating them with a comma.")
        str.append(next)
        topLabel.attributedText = str
        
        self.view.setGradientBackground(colorOne: Colors.main, colorTwo: Colors.secondary)
        topView.setUpTutorialLabel()
        
        if SharedValues.shared.isPhone == false {
            topLabel.font = UIFont(name: "futura", size: 17)
        }
        
        topView.alpha = 0.3
        imageView.addLoadingView()
        self.getImageForTutorial(imageText: "three") { (img) in
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
