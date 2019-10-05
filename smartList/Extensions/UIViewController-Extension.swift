//
//  UIViewController-Extension.swift
//  smartList
//
//  Created by Steven Dito on 9/27/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import Foundation
import UIKit



extension UIViewController {
    @objc func removeFromSuperViewSelector() {
        self.dismiss(animated: true, completion: nil)
    }
    func createPickerView(itemName: String, itemStores: [String]?, itemCategories: [String]?, itemListID: String) {
        let vc = UIViewController()
        //vc.view.backgroundColor = .gray
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width).isActive = true
        button.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height).isActive = true
        button.addTarget(self, action: #selector(removeFromSuperViewSelector), for: .touchUpInside)
        vc.view.insertSubview(button, at: 1)
        
        
        let v = Bundle.main.loadNibNamed("SortItemView", owner: nil, options: nil)?.first as! SortItemView
        v.setUI(name: itemName, stores: itemStores, categories: itemCategories, listID: itemListID)
        v.center = vc.view.center
        vc.view.insertSubview(v, at: 2)
        v.alpha = 0
        v.shadowAndRounded()
        vc.modalPresentationStyle = .overFullScreen
        
        self.present(vc, animated: false) {
            UIView.animate(withDuration: 0.3) {
                v.alpha = 1.0
                
            }
            
        }
    }
    func createNavigationBarTextAttributes() {
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "futura", size: 20)!]
        
    }
    @objc func createMessageView(color: UIColor, text: String) {
        let messageView = UILabel()
        messageView.backgroundColor = color
        messageView.text = text
        messageView.textColor = .white
        messageView.font = UIFont(name: "futura", size: 20)
        messageView.textAlignment = .center
        messageView.frame = CGRect(x: 10, y: self.view.safeAreaInsets.top + 20, width: self.view.bounds.width - 20, height: 70)
        messageView.layer.cornerRadius = 15
        messageView.clipsToBounds = true
        messageView.isUserInteractionEnabled = true
        
        /*
        let gestureRecognizer = UIGestureRecognizer(target: self, action: #selector(messageView.removeFromSuperview)
        gestureRecognizer.delegate = messageView as? UIGestureRecognizerDelegate
        messageView.addGestureRecognizer(gestureRecognizer)
        */
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            UIView.animate(withDuration: 0.5, animations: {
                messageView.alpha = 0
            }) { (true) in
                messageView.removeFromSuperview()
            }
            
        }
        
        self.view.addSubview(messageView)
    }
    
    @objc func createGroupPopUp() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "createGroup") as! CreateGroupVC
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
}
