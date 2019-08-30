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
            //create another ingredientView and set the left tf to become the first responder
            if (self.superview as! UIStackView).subviews.firstIndex(of: self) == (self.superview as! UIStackView).subviews.count - 1 {
                let t = (Bundle.main.loadNibNamed("IngredientView", owner: nil, options: nil)?.first as? IngredientView)!
                (self.superview as! UIStackView).insertArrangedSubview(t, at: (self.superview as! UIStackView).subviews.count)
                textField.resignFirstResponder()
                t.left.becomeFirstResponder()
            } else {
                // don't need to create another ingredientsView, just need to set the next textfield to first responder
                textField.resignFirstResponder()
                ((self.superview as! UIStackView).subviews[(self.superview as! UIStackView).subviews.firstIndex(of: self)! + 1] as! IngredientView).left.becomeFirstResponder()
            }
            
            
        }
        return true
    }

}


