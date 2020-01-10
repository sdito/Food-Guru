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
        
//        topLabel.drawText(in: CGRect(x: 5, y: 5, width: topLabel.intrinsicContentSize.width, height: topLabel.intrinsicContentSize.height))
        

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
    
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size

        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height

        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }

        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
}



extension UIImage {
    func resizeImage(targetSize: CGSize) -> UIImage {
        let size = self.size

        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height

        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }

        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
}
