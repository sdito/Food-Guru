//
//  LoadingView.swift
//  smartList
//
//  Created by Steven Dito on 3/15/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class LoadingView: UIView {
    
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var background: UIView!
    
    private var timer: Timer?
    
    func startAnimating() {
        setUpInitialUI()
        timer = Timer.scheduledTimer(withTimeInterval: 0.55, repeats: true, block: { (tmr) in
            self.spinAnimation()
        })
    }
    
    
    private func spinAnimation() {
        if self.findViewController()?.isViewLoaded ?? false {
            UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveLinear, animations: {
                self.logo.transform = self.logo.transform.rotated(by: CGFloat(Double.pi))
                self.logo.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            }) { (complete) in
                UIView.animate(withDuration: 0.05) {
                    self.logo.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                }
            }
        } else {
            timer?.invalidate()
            timer = nil
        }
    }
    
    private func setUpInitialUI() {
        background.layer.cornerRadius = background.frame.width / 8
        self.shadow()
        background.backgroundColor = Colors.secondarySystemBackground.withAlphaComponent(0.65)
        
    }
    
}
