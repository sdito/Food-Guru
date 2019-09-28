//
//  UIView-Extension.swift
//  smartList
//
//  Created by Steven Dito on 8/15/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import Foundation
import UIKit


extension UIView {
    func setGradientBackground(colorOne: UIColor, colorTwo: UIColor) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = [colorOne.cgColor, colorTwo.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 1.0, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.0, y: 0.0)
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func border() {
        self.layer.cornerRadius = 5
        self.layer.borderWidth = 0.5
        self.layer.borderColor = Colors.lightGray.cgColor
        self.clipsToBounds = true
    }
    
    func shadow() {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.4
        self.layer.shadowOffset = .zero
        self.layer.shadowRadius = 5
    }
    
    func setIsHidden(_ hidden: Bool, animated: Bool) {
        if animated {
            if self.isHidden && !hidden {
                self.alpha = 0.0
                self.isHidden = false
            }
            UIView.animate(withDuration: 0.2, animations: {
                self.alpha = hidden ? 0.0 : 0.925
            }) { (complete) in
                self.isHidden = hidden
            }
        } else {
            self.isHidden = hidden
        }
    }
    func circularPercentageView(endStrokeAt: CGFloat, color: CGColor) {
        self.layer.cornerRadius = self.frame.size.width / 2
        
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: self.frame.size.width/2, y: self.frame.size.height / 2), radius: self.frame.size.width / 2, startAngle: CGFloat(-0.5 * .pi), endAngle: CGFloat(1.5 * .pi), clockwise: true)
        
        let circleShape = CAShapeLayer()
        circleShape.path = circlePath.cgPath
        circleShape.strokeColor = color
        circleShape.fillColor = UIColor.clear.cgColor
        circleShape.lineWidth = 3.0
        circleShape.strokeStart = 0.0
        if endStrokeAt < 0.2 {
            circleShape.strokeEnd = 0.2
        } else {
            circleShape.strokeEnd = endStrokeAt
        }
        self.layer.addSublayer(circleShape)
    }
    
}


