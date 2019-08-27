//
//  CreateRecipeVC.swift
//  smartList
//
//  Created by Steven Dito on 8/19/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import UIKit

class CreateRecipeVC: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var servingsTextField: UITextField!
    
    
    @IBOutlet weak var cookTimeTextField: UITextField!
    @IBOutlet weak var prepTimeTextField: UITextField!
    @IBOutlet weak var caloriesTextField: UITextField!
    @IBOutlet weak var ingredientsTextField: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.delegate = self
        servingsTextField.delegate = self
        cookTimeTextField.delegate = self
        prepTimeTextField.delegate = self
        caloriesTextField.delegate = self
        ingredientsTextField.delegate = self
        
        nameTextField.becomeFirstResponder()
    }
    override func viewDidDisappear(_ animated: Bool) {
        UITextField().resignFirstResponder()
    }
    
    @IBAction func selectDescriptions(_ sender: Any) {
        self.add(popUp: SelectRecipeTypeVC.popUp.popOverVC)
    }
    
}



extension CreateRecipeVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameTextField {
            textField.resignFirstResponder()
            servingsTextField.becomeFirstResponder()
        } else if textField == servingsTextField {
            textField.resignFirstResponder()
            self.add(popUp: SelectRecipeTypeVC.popUp.popOverVC)
            cookTimeTextField.becomeFirstResponder()
        } else if textField == cookTimeTextField {
            textField.resignFirstResponder()
            prepTimeTextField.becomeFirstResponder()
        } else if textField == prepTimeTextField {
            textField.resignFirstResponder()
            caloriesTextField.becomeFirstResponder()
        } else if textField == caloriesTextField {
            textField.resignFirstResponder()
            ingredientsTextField.becomeFirstResponder()
        }
        
        return true
    }
}
