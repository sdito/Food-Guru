//
//  FourTutorialVC.swift
//  smartList
//
//  Created by Steven Dito on 1/5/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class FourTutorialVC: UIViewController {

    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var topLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        
        let str = NSMutableAttributedString(string: "After selecting a recipe, select ")
        let plus = NSAttributedString(string: "+", attributes: [.foregroundColor:Colors.main])
        str.append(plus)
        let second = NSAttributedString(string: " to add the item to your list. Select ")
        str.append(second)
        let download = NSAttributedString(string: "Download", attributes: [.foregroundColor:Colors.main])
        str.append(download)
        let third = NSAttributedString(string: " to have the recipe saved to your cookbook and select ")
        str.append(third)
        let save = NSAttributedString(string: "Save", attributes: [.foregroundColor:Colors.main])
        str.append(save)
        let fourth = NSAttributedString(string: " to have your recipe appear in saved recipes.")
        str.append(fourth)
        topLabel.attributedText = str
        self.view.setGradientBackgroundTutorial(colorOne: Colors.main, colorTwo: Colors.secondary)
        topView.setUpTutorialLabel()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        imageView.pulsateView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        imageView.disappearAnimation()
    }

}
