//
//  SettingContactDeveloperCell.swift
//  smartList
//
//  Created by Steven Dito on 9/26/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth



protocol UpdateScreenDelegate: AnyObject {
    func updateScreen()
}



class SettingContactDeveloperCell: UITableViewCell {
    var db: Firestore!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var textView: UITextView!
    
    weak var delegate: UpdateScreenDelegate?
    
    override func awakeFromNib() {
        textField.delegate = self
        textView.delegate = self
        textField.becomeFirstResponder()
        textView.border(cornerRadius: 5.0)
    }
    
    @IBAction func sendFeedback(_ sender: Any) {
        
        if textView.text != "" {
            db = Firestore.firestore()
            db.collection("messages").document().setData([
                "fromEmail": textField.text as Any,
                "message": textView.text!,
                "uid": Auth.auth().currentUser?.uid as Any,
                "deviceName": UIDevice().name,
                "systemVersion": UIDevice().systemVersion,
                "timeIntervalSince1970": Date().timeIntervalSince1970
            ]){ err in
                if let err = err {
                    print("Error updating document: \(err)")
                } else {
                    print("Message sucessfully written")
                    self.textField.text = ""
                    self.textView.text = ""
                    self.delegate?.updateScreen()
                }
            }
        } else {
            let alert = UIAlertController(title: "Error", message: "To submit you must first write a message", preferredStyle: .alert)
            alert.addAction(.init(title: "Ok", style: .cancel, handler: nil))
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true)
        }
        
    }
}


extension SettingContactDeveloperCell: UITextFieldDelegate, UITextViewDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        textView.becomeFirstResponder()
        return true
    }
}

