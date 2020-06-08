//
//  AdvancedSearchView.swift
//  smartList
//
//  Created by Steven Dito on 6/7/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class AdvancedSearchView: UIView {

    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var ingredientsTF: UITextField!
    @IBOutlet weak var titleTF: UITextField!
    @IBOutlet weak var tagTF: UITextField!
    @IBOutlet weak var avoidIngsTF: UITextField!
    
    func setUI() {
        print("initial set up")
        ingredientsTF.delegate = self
        titleTF.delegate = self
        tagTF.delegate = self
        avoidIngsTF.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidShowNotification, object: nil)
    }
    
    
    @IBAction func searchPressed(_ sender: Any) {
        print("search has been pressed")
        self.findViewController()?.dismiss(animated: false, completion: nil)
        // do the stuff to transfer the searches here
        
    }
    
    @IBAction func infoButton(_ sender: Any) {
        print("Info button selected")
        #warning("need to complete")
    }
    
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        print("Keyboard will show is being called")
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            print(keyboardRectangle.height)
            
        }
    }
}


extension AdvancedSearchView: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("Text field did begin editing")
        let stackView = textField.superview
        mainStackView.bringSubviewToFront(mainStackView.subviews[2])
    }
}


/*
 if textAssistantViewActive == false {
     // add the view here
     let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "createNewItemVC") as! CreateNewItemVC
     self.newItemVC = vc
     self.addChild(vc)
     self.view.addSubview(vc.tableView)
     vc.didMove(toParent: self)
     vc.isForSearch = true
     
     vc.tableView.translatesAutoresizingMaskIntoConstraints = false
     
     vc.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
     vc.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
     vc.tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor).isActive = true
     
     let tb = (tabBarController?.tabBar.frame.height ?? 0.0)
     let distance = (wholeStackView.frame.height) - (keyboardHeight ?? 0.0) - (searchBar.frame.height) + tb
     
     vc.tableView.heightAnchor.constraint(equalToConstant: distance).isActive = true
     
     vc.delegate = self as CreateNewItemDelegate
     delegate = vc
     delegate.searchTextChanged(text: searchText)
     textAssistantViewActive = true
     
     
 } else {
     delegate.searchTextChanged(text: searchText)
 }
 */
