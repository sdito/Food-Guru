//
//  UIViewController-Extension.swift
//  smartList
//
//  Created by Steven Dito on 9/27/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import Foundation
import UIKit
import FirebaseStorage


extension UIViewController {
    @objc func removeFromSuperViewSelector() {
        UIView.animate(withDuration: 0.3, animations: {
            self.presentedViewController?.view.alpha = 0.0
        }) { (true) in
            self.dismiss(animated: false, completion: nil)
        }
        
    }
    
    func createLoadingView(cancelAction: Selector) {
        #warning("not being used yet")
        let vc = UIViewController()
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width).isActive = true
        view.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height).isActive = true
        view.backgroundColor = .black
        view.alpha = 0.9
        vc.view.insertSubview(view, at: 1)
        
        
        let spinner = UIActivityIndicatorView(style: .whiteLarge)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        view.addSubview(spinner)
        spinner.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor).isActive = true
        
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Cancel", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.titleLabel?.font = UIFont(name: "futura", size: 17)
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            view.addSubview(button)
            button.topAnchor.constraint(equalToSystemSpacingBelow: spinner.bottomAnchor, multiplier: 1.0).isActive = true
            button.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor).isActive = true
            button.addTarget(self, action: cancelAction, for: .touchUpInside)
        }
        
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: false)
        
        
    }
    
    func createRatingView(delegateVC: UIViewController) {
        let vc = UIViewController()
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width).isActive = true
        button.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height).isActive = true
        button.addTarget(self, action: #selector(removeFromSuperViewSelector), for: .touchUpInside)
        button.backgroundColor = .black
        button.alpha = 0.3
        vc.view.insertSubview(button, at: 1)
        
        let v = Bundle.main.loadNibNamed("GiveRatingView", owner: nil, options: nil)?.first as! GiveRatingView
        v.delegate = delegateVC as? GiveRatingViewDelegate
        v.center.x = vc.view.center.x
        v.center.y = vc.view.center.y - 100
        
        
        vc.view.insertSubview(v, at: 2)
        v.alpha = 0
        v.shadowAndRounded(cornerRadius: 25.0, border: false)
        vc.modalPresentationStyle = .overFullScreen
        
        self.present(vc, animated: false) {
            UIView.animate(withDuration: 0.3) {
                v.alpha = 1.0
            }
        }
    }
    
    func createImageDetailView(imagePath: String?, initialImage: UIImage?) {
        //#error("image not centered")
        print("Image path \(String(describing: imagePath)) will be used here for the big grand detail view yay")
        let vc = UIViewController()
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width).isActive = true
        button.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height).isActive = true
        button.addTarget(self, action: #selector(removeFromSuperViewSelector), for: .touchUpInside)
        button.backgroundColor = .black
        button.alpha = 0.7
        vc.view.insertSubview(button, at: 1)
        
        let v = UIImageView()
        v.alpha = 0
        v.image = initialImage
        v.translatesAutoresizingMaskIntoConstraints = false
        let constant = self.view.bounds.width - 20
        v.widthAnchor.constraint(equalToConstant: constant).isActive = true
        v.heightAnchor.constraint(equalToConstant: constant).isActive = true
        v.shadowAndRounded(cornerRadius: 25, border: false)
        v.clipsToBounds = true
        
        
        vc.view.insertSubview(v, at: 2)
        
        if let superView = v.superview {
            v.centerXAnchor.constraint(equalTo: superView.centerXAnchor).isActive = true
            v.centerYAnchor.constraint(equalTo: superView.centerYAnchor).isActive = true
        }
        
        
        guard let iPath = imagePath else { return }
        let imageReference = Storage.storage().reference(withPath: iPath)
        imageReference.getData(maxSize: 2 * 1024 * 1024) { (data, error) in
            guard let data = data else {
                print("Error downloading image: \(String(describing: error))")
                return
            }
            let finalImage = UIImage(data: data)
            v.image = finalImage
            
        }
        
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: false) {
            UIView.animate(withDuration: 0.3) {
                v.alpha = 1.0
            }
        }
    }
    
    func createPickerView(itemNames: [String], itemStores: [String]?, itemListID: String, singleItem: Bool, delegateVC: UIViewController) {
        let vc = UIViewController()
        //vc.view.backgroundColor = .gray
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width).isActive = true
        button.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height).isActive = true
        button.addTarget(self, action: #selector(removeFromSuperViewSelector), for: .touchUpInside)
        vc.view.insertSubview(button, at: 1)
        
        
        let v = Bundle.main.loadNibNamed("SortItemView", owner: nil, options: nil)?.first as! SortItemView
        v.delegate = delegateVC as? DisableAddAllItemsDelegate
        switch singleItem {
        case true:
            v.setUIoneItem(name: itemNames.first!, stores: itemStores, listID: itemListID)
        case false:
            v.setUIallItems(items: itemNames, stores: itemStores, listID: itemListID)
        }
        
        v.center = vc.view.center
        vc.view.insertSubview(v, at: 2)
        v.alpha = 0
        v.shadowAndRounded(cornerRadius: 25.0, border: false)
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
        messageView.frame = CGRect(x: 10, y: self.view.safeAreaInsets.top + 50, width: self.view.bounds.width - 20, height: 70)
        messageView.layer.cornerRadius = 15
        messageView.clipsToBounds = true
        messageView.isUserInteractionEnabled = true
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(messageDismissSelector))
        messageView.addGestureRecognizer(gestureRecognizer)
        messageView.tag = 1
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            UIView.animate(withDuration: 0.5, animations: {
                messageView.alpha = 0
            }) { (true) in
                messageView.removeFromSuperview()
            }
        }
        
        self.view.addSubview(messageView)
    }
    @objc func messageDismissSelector() {
        let v = self.view.subviews.filter({$0.tag == 1})
        v.forEach { (view) in
            view.removeFromSuperview()
        }
    }
    
    @objc func createGroupPopUp() {
        if SharedValues.shared.anonymousUser == false {
            let vc = storyboard?.instantiateViewController(withIdentifier: "createGroup") as! CreateGroupVC
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Error", message: "Need to create a free account in order to access all the features", preferredStyle: .alert)
            alert.addAction(.init(title: "Ok", style: .default, handler: nil))
            present(alert, animated: true)
        }
        
    }
    
}
