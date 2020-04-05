//
//  EditQuantityView.swift
//  smartList
//
//  Created by Steven Dito on 4/4/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit




protocol EditQuantityViewDelegate: class {
    func newQuantity(_ quantity: String?)
}




class EditQuantityView: UIView {
    
    private var numberPart: String = ""
    private var quantityPart: String = ""
    
    weak var delegate: EditQuantityViewDelegate!
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var cancelOutlet: UIButton!
    @IBOutlet weak var doneOutlet: UIButton!
    
    @IBOutlet var quantityButtons: [UIButton]!
    
    func setUI(quantity: String?, fromVC: UIViewController) {
        
        self.delegate = fromVC as? EditQuantityViewDelegate
        if let quantity = quantity {
            textField.text = quantity
        }
        [cancelOutlet, doneOutlet].forEach { (btn) in
            btn?.layer.cornerRadius = 5.0
            btn?.layer.borderWidth = 2.0
            btn?.layer.borderColor = Colors.secondary.cgColor
            btn?.clipsToBounds = true
        }
        quantityButtons.forEach { (btn) in
            btn.layer.cornerRadius = 5.0
            #warning("this isnt working")
        }
    }
    
    
    @IBAction func plusQuantity(_ sender: Any) {
        if textField.text == "" {
            textField.text = "2"
        } else if let text = textField.text, let number = Int(text) {
            textField.text = "\(number + 1)"
        }
    }
    
    @IBAction func minusQuantity(_ sender: Any) {
        if let text = textField.text, let number = Int(text) {
            textField.text = "\(number - 1)"
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        dismissView()
    }
    
    @IBAction func done(_ sender: Any) {
        delegate.newQuantity(textField.text)
        dismissView()
    }
    
    
    private func dismissView() {
        let vc = self.findViewController()
        if let vc = vc {
            UIView.animate(withDuration: 0.3, animations: {
                vc.view.alpha = 0.0
            }) { (true) in
                vc.dismiss(animated: false, completion: nil)
            }
        }
    }
    
    
}
