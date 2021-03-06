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
    
    @objc func doneSelector() {
        SharedValues.shared.currText?.resignFirstResponder()
    }
    
    override func awakeFromNib() {
        left.delegate = self
        right.delegate = self
        
        left.tag = 1
        right.tag = 2
        
        left.setUpDoneToolbar(action: #selector(doneSelector), style: .done)
        right.setUpDoneToolbar(action: #selector(doneSelector), style: .done)
    }
    
    // MARK: functions
    // to get the ingredients from each ingredient view in [String] format
    class func getIngredients(stack: UIStackView) -> [String] {
        var ingredients: [String] = []
        for view in stack.subviews {
            if type(of: view) == IngredientView.self {
                ingredients += (view as! IngredientView).ingredients()
            }
        }
        
        // get rid of blanks and have it alphabetical
        ingredients = ingredients.filter({$0 != ""})
        return ingredients.sorted()
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
                
                // get the index of the current view, and set the 'left' textField of the next view in order to become frist responder
                let vi = ((self.superview as! UIStackView).subviews[(self.superview as! UIStackView).subviews.firstIndex(of: self)! + 1] as! IngredientView).left//.becomeFirstResponder()
                vi?.becomeFirstResponder()
            }
        }
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        SharedValues.shared.currText = textField
        
        if textField.tag == 2 {
            if (self.superview as! UIStackView).subviews.firstIndex(of: self) == (self.superview as! UIStackView).subviews.count - 1 {
                let t = (Bundle.main.loadNibNamed("IngredientView", owner: nil, options: nil)?.first as? IngredientView)!
                (self.superview as! UIStackView).insertArrangedSubview(t, at: (self.superview as! UIStackView).subviews.count)
            }

        }
                
    }
}

// MARK: Extension
extension IngredientView {
    func ingredients() -> [String] {
        return [self.left.text ?? "", self.right.text ?? ""]
    }
}
