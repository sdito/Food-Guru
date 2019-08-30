//
//  IngredientView.swift
//  
//
//  Created by Steven Dito on 8/30/19.
//

import UIKit

class IngredientView: UIView, UITextFieldDelegate {
    
    @IBOutlet weak var left: UITextField!
    @IBOutlet weak var right: UITextField!
    
    override func awakeFromNib() {
        left.delegate = self
        right.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == left {
            textField.resignFirstResponder()
            right.becomeFirstResponder()
        } else {
            let t = (Bundle.main.loadNibNamed("IngredientView", owner: nil, options: nil)?.first as? IngredientView)!
            (self.superview as! UIStackView).insertArrangedSubview(t, at: (self.superview as! UIStackView).subviews.count)
            textField.resignFirstResponder()
            t.left.becomeFirstResponder()
        }
        return true
    }

}


