//
//  EndTutorialVC.swift
//  smartList
//
//  Created by Steven Dito on 1/11/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class EndTutorialVC: UIViewController {
    
    @IBOutlet weak var logo: UIImageView!
    
    private var timer: Timer?
    private let rotation: CGFloat = .pi/2
    private var rotationCount = 1
    
    override func viewWillAppear(_ animated: Bool) {
        timer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true, block: { (tmr) in
            self.logoAnimation(degrees: self.rotation * CGFloat(self.rotationCount))
            self.rotationCount += 1
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.timer?.fire()
        }
        
        (self.parent as? TutorialVC)?.button.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        timer?.invalidate()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func continuePressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    private func logoAnimation(degrees: CGFloat) {
        UIView.animate(withDuration: 0.2, animations: {
            self.logo.transform = CGAffineTransform(rotationAngle: degrees - self.rotation - self.rotation/10)
        }) { (complete) in
            UIView.animate(withDuration: 0.5, animations: {
                self.logo.transform = CGAffineTransform(rotationAngle: degrees)
            })
        }
        
    }
}
