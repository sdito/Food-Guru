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
import AVFoundation

extension UIViewController {
    
    @objc func removeFromSuperviewForPickerView(_ sender: UIButton) {
        let vc = sender.findViewController()
        UIView.animate(withDuration: 0.3, animations: {
            vc?.view.alpha = 0.0
        }) { (true) in
            vc?.dismiss(animated: false, completion: nil)
        }
    }
    
    @objc func removeFromSuperViewSelector() {
        UIView.animate(withDuration: 0.3, animations: {
            self.presentedViewController?.view.alpha = 0.0
        }) { (true) in
            self.dismiss(animated: false, completion: nil)
        }
        
    }
    
    
    func createLoadingView() {
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
        button.setTitleColor(.clear, for: .normal)
        button.titleLabel?.font = UIFont(name: "futura", size: 17)
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            view.addSubview(button)
            button.topAnchor.constraint(equalToSystemSpacingBelow: spinner.bottomAnchor, multiplier: 1.0).isActive = true
            button.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor).isActive = true
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
    
    func createEditItemInfoView(forCategory: Bool, stores: [String]?, item: Item, listID: String?) {
        let vc = UIViewController()
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width).isActive = true
        button.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height).isActive = true
        button.addTarget(self, action: #selector(removeFromSuperViewSelector), for: .touchUpInside)
        button.backgroundColor = .black
        button.alpha = 0.3
        vc.view.insertSubview(button, at: 1)
        
        let v = Bundle.main.loadNibNamed("EditItemInfoView", owner: nil, options: nil)?.first as! EditItemInfoView
        v.setUI(forCategory: forCategory, stores: stores, item: item, listID: listID)
        v.forStore = !forCategory
        v.center.x = vc.view.center.x
        v.center.y = vc.view.center.y
        
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
//        vc.view.tag = 111
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width).isActive = true
        button.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height).isActive = true
        button.addTarget(self, action: #selector(removeFromSuperviewForPickerView), for: .touchUpInside)
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
    
    
    func createIngredientsDidntShowInSearchView() {
        
        let button = UIButton()
        button.backgroundColor = .systemGreen
        
        let text = "Why didnt all the ingredients appear in my search?"
        let font = UIFont(name: "futura", size: 14)
        let distanceToTop: CGFloat = 150
        if #available(iOS 13.0, *) {
            button.setTitleColor(.systemBackground, for: .normal)
        } else {
            button.setTitleColor(.white, for: .normal)
        }
        button.setTitle(text, for: .normal)
        button.titleLabel?.font = font
        button.titleLabel?.textAlignment = .center
        let rect = NSString(string: text).boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font!], context: nil)
        let xValue = (self.view.bounds.width/2.0) - (5.0) - (rect.width/2.0)
        button.frame = CGRect(x: -rect.width - 15.0, y: distanceToTop, width: rect.width + 10.0, height: rect.height + 4.0)
        button.border(cornerRadius: 5.0)
        
        
        button.addTarget(self, action: #selector(whyDidntAllIngredintsShow), for: .touchUpInside)
        
        
        self.view.addSubview(button)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            UIView.animate(withDuration: 0.25) {
                button.frame = CGRect(x: xValue, y: distanceToTop, width: rect.width + 10.0, height: rect.height + 4.0)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 7.0) {
            button.animateRemoveFromSuperview(y: distanceToTop)
        }
 
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
    
    @objc func whyDidntAllIngredintsShow(_ sender: UIButton) {
        let alert = UIAlertController(title: "Search", message: "Some items did not appear in your search since this application has not supported those specific ingredients yet in order to enable search. There will always be more ingredients added in the future! If you this this specific ingredient should been in the application, send me a message from settings.", preferredStyle: .alert)
        alert.addAction(.init(title: "Don't show this again", style: .default, handler: {alert in
            #warning("need to write to user defaults, before prsenting the button view need to cheeck this value in user defaults")
            UserDefaults.standard.set(true, forKey: "doneSeeingNoIngredientView")
            
        }))
        alert.addAction(.init(title: "Ok", style: .cancel, handler: nil))
        sender.findViewController()?.present(alert, animated: true)
        sender.removeFromSuperview()
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
