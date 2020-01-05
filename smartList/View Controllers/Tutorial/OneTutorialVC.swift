//
//  OneTutorialVC.swift
//  smartList
//
//  Created by Steven Dito on 1/5/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class OneTutorialVC: UIViewController {

    @IBOutlet weak var topLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let image = NSTextAttachment()
        let img = UIImage(named: "checked-checkbox-xxl")
        
        
        image.image = img
        let imageString = NSAttributedString(attachment: image)
        
        
        
        let str = NSMutableAttributedString(string: "Select the")
        str.append(imageString)
        str.append(NSAttributedString(string: "button to add the selected items from your list to your storage"))
        
        topLabel.attributedText = str
    }


}
