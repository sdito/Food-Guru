//
//  CreateRecipeVC.swift
//  smartList
//
//  Created by Steven Dito on 8/19/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class CreateRecipeVC: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var servingsTextField: UITextField!
    @IBOutlet weak var cookTimeTextField: UITextField!
    @IBOutlet weak var prepTimeTextField: UITextField!
    @IBOutlet weak var caloriesTextField: UITextField!
    @IBOutlet weak var ingredientsTextField: UITextField!
    
    @IBOutlet weak var cuisineOutlet: UIButton!
    @IBOutlet weak var recipeDescriptionOutlet: UIButton!
    
    @IBOutlet weak var createRecipeOutlet: UIButton!
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var instructionsListStackView: UIStackView!
    
    var currTextField: UITextField?
    
    var cuisineType: String? {
        didSet {
            cuisineOutlet.setTitle(self.cuisineType!, for: .normal)
        }
    }
    var recipeType: [String]? {
        didSet {
            recipeDescriptionOutlet.setTitle("name", for: .normal)//self.recipeType?.joined(separator: ", "), for: .normal)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.delegate = self
        servingsTextField.delegate = self
        cookTimeTextField.delegate = self
        prepTimeTextField.delegate = self
        caloriesTextField.delegate = self
        ingredientsTextField.delegate = self
        
        nameTextField.becomeFirstResponder()
        createRecipeOutlet.setGradientBackground(colorOne: Colors.main, colorTwo: Colors.mainGradient)
        createRecipeOutlet.layer.cornerRadius = 15
        createRecipeOutlet.clipsToBounds = true
        currTextField = nameTextField
        textView.border()
    }
    
    @IBAction func createRecipePressed(_ sender: Any) {
        
        //still need to have notes for user to write in about recipe on storybaord
        //let recipe = Recipe(name: nameTextField.text!, recipeType: recipeType!, cuisineType: cuisineType!, cookTime: cookTimeTextField.toInt()!, prepTime: prepTimeTextField.toInt()!, ingredients: <#T##[String]#>, instructions: <#T##[String]#>, calories: caloriesTextField.toInt(), numServes: servingsTextField.toInt()!, id: Auth.auth().currentUser?.uid, numReviews: nil, numStars: nil, notes: nil)
    }
    
    
    @IBAction func selectCuisine(_ sender: Any) {
        pushToPopUp()
    }
    @IBAction func selectDescriptions(_ sender: Any) {
        pushToPopUp()
        
    }
    @IBAction func addInstruction(_ sender: Any) {
        print("called")
        //instructionsListStackView.createInstructionRow()
        //instructionsListStackView.insertSubview(UIView(), at: 1)
        
        
        let v = UIView()
        v.backgroundColor = .red
        v.heightAnchor.constraint(equalTo: instructionsListStackView.subviews[0].heightAnchor, multiplier: 1)
        
        
        instructionsListStackView.insertSubview(v, at: 1)
        
        
        
        //print(instructionsListStackView.subviews.count)
    }
    
    
    private func pushToPopUp() {
        currTextField?.resignFirstResponder()
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
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        currTextField = textField
    }
}
