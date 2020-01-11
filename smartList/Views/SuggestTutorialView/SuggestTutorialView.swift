//
//  SuggestTutorialView.swift
//  smartList
//
//  Created by Steven Dito on 1/11/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class SuggestTutorialView: UIView {

    @IBOutlet weak var xButton: UIButton!
    @IBOutlet weak var viewTutorialButton: UIButton!
    
    

    
    override func awakeFromNib() {
        xButton.addTarget(self, action: #selector(xButtonAction), for: .touchUpInside)
        viewTutorialButton.addTarget(self, action: #selector(viewTutorialButtonAction), for: .touchUpInside)
        
        xButton.layer.cornerRadius = 3.0
        xButton.clipsToBounds = true
        xButton.backgroundColor = .systemGreen
        
        self.backgroundColor = Colors.messageGreen
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 13.0) {
            print("Automatically removing view")
            self.animateRemoveFromSuperview()
        }
    }
    
    
    @objc private func xButtonAction() {
        self.animateRemoveFromSuperview()
    }
    @objc private func viewTutorialButtonAction() {
        let sb: UIStoryboard = UIStoryboard(name: "Tutorial", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "tutorialVC") as! TutorialVC
        vc.modalPresentationStyle = .fullScreen
        self.findViewController()?.present(vc, animated: true, completion: nil)
        self.removeFromSuperview()
    }
}
