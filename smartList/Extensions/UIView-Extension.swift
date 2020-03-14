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
    func setUpTutorialLabel() {
        self.layer.cornerRadius = 5.0
        self.layer.borderWidth = 1
        if #available(iOS 13.0, *) {
            self.layer.borderColor = UIColor.label.cgColor
        } else {
            self.layer.borderColor = UIColor.black.cgColor
        }
        self.clipsToBounds = true
    }
    func pulsateView() {
        UIView.animate(withDuration: 0.3, animations: {
            self.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        }) { (true) in
            UIView.animate(withDuration: 0.2) {
                self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }
        }
    }
    
    func disappearAnimation() {
        UIView.animate(withDuration: 0.1) {
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }
    
    func findViewController() -> UIViewController? {
        if let nextResponder = self.next as? UIViewController {
            return nextResponder
        } else if let nextResponder = self.next as? UIView {
            return nextResponder.findViewController()
        } else {
            return nil
        }
    }
    func shadowAndRounded(cornerRadius: CGFloat, border: Bool) {
        self.layer.cornerRadius = cornerRadius
        self.layer.borderWidth = 1.0
        
        self.layer.masksToBounds = true
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        self.layer.shadowRadius = 4.0
        self.layer.shadowOpacity = 0.5
        self.layer.masksToBounds = false
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.layer.cornerRadius).cgPath
        
        if border == true {
            print("border time")
            if #available(iOS 13.0, *) {
                self.layer.borderColor = UIColor.label.cgColor
            } else {
                self.layer.borderColor = UIColor.black.cgColor
            }
        } else {
            self.layer.borderColor = UIColor.clear.cgColor
        }
    }
    
    func setGradientBackground(colorOne: UIColor, colorTwo: UIColor) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = [colorOne.cgColor, colorTwo.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 1.0, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.0, y: 0.0)
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func setGradientBackgroundTutorial(colorOne: UIColor, colorTwo: UIColor) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = [colorOne.cgColor, colorTwo.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.0)
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    
    func border(cornerRadius: CGFloat) {
        self.layer.cornerRadius = cornerRadius
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
    
    func animateRemoveFromSuperview(y: CGFloat) {
        let width = self.bounds.width
        UIView.animate(withDuration: 0.3, animations: {
            self.frame = CGRect(x: 0.0 - width, y: y, width: width, height: self.bounds.height)
        }) { (complete) in
            self.removeFromSuperview()
        }
    }
    
    
    func setIsHidden(_ hidden: Bool, animated: Bool) {
        if animated {
            if self.isHidden && !hidden {
                self.alpha = 0.0
                self.isHidden = false
            }
            UIView.animate(withDuration: 0.2, animations: {
                self.alpha = hidden ? 0.0 : 1.0
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

    func findCalendarView() -> CalendarView? {
        if type(of: self) == CalendarView.self {
            return self as? CalendarView
        } else {
            return self.superview?.findCalendarView()
        }
    }
    
    func addLoadingView() {
        let view = UIActivityIndicatorView(style: .whiteLarge)
        view.startAnimating()
        view.tag = 89 // used for removing
        view.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(view)
        view.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        view.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        
        
    }
    
    func removeLoadingView() {
        self.subviews.forEach { (v) in
            if v.tag == 89 {
                v.removeFromSuperview()
            }
        }
    }
    
    
}


