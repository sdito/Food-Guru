//
//  OneTutorialVC.swift
//  smartList
//
//  Created by Steven Dito on 1/5/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit


class OneTutorialVC: UIViewController {
    
    var timer: Timer?
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var arrow: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        let image = NSTextAttachment()
        let img = UIImage(named: "checked-checkbox-xxl")
        let imageString = NSAttributedString(attachment: image)
        
        let resized = img!.resizeImage(targetSize: CGSize(width: 15, height: 15))
        
        image.image = resized
        
        let str = NSMutableAttributedString(string: "Select ")
        str.append(imageString)
        str.append(NSAttributedString(string: " to add the selected items from your list to your storage"))
        
        topLabel.attributedText = str
        
        self.view.setGradientBackground(colorOne: Colors.main, colorTwo: Colors.secondary)
        topView.setUpTutorialLabel()
        
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        imageView.pulsateView()
        
        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false, block: { (tmr) in
            print("Timer was fired")
            self.arrow.setIsHidden(false, animated: true)
        })
        
        
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        imageView.disappearAnimation()
        arrow.setIsHidden(true, animated: true)
        timer?.invalidate()
    }
    

}




