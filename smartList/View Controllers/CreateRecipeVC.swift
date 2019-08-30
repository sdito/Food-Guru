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
        initialInstructionSetUp()
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
        insert()
        
    }
    
    private func insert() {
        let v = (Bundle.main.loadNibNamed("InstructionView", owner: nil, options: nil)?.first as? InstructionView)!
        v.setUI(num: "+")
        v.button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        
        //v.setUI(num: "\(instructionsListStackView.subviews.count)")
        instructionsListStackView.insertArrangedSubview(v, at: instructionsListStackView.subviews.count)
        //instructionsListStackView.insertSubview(v, at: 1)
        for i in instructionsListStackView.subviews {
            if i != instructionsListStackView.subviews.last && type(of: i) == InstructionView.self {
                (i as! InstructionView).button.setTitle("\(instructionsListStackView.subviews.firstIndex(of: i) ?? 0)", for: .normal)
                i.alpha = 1.0
            }
        }
    }
    
    private func initialInstructionSetUp() {
        let v = (Bundle.main.loadNibNamed("InstructionView", owner: nil, options: nil)?.first as? InstructionView)!
        let v2 = (Bundle.main.loadNibNamed("InstructionView", owner: nil, options: nil)?.first as? InstructionView)!
        v2.button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        v.setUI(num: "1")
        v2.setUI(num: "+")
        v.alpha = 1.0
        instructionsListStackView.insertArrangedSubview(v, at: 1)
        instructionsListStackView.insertArrangedSubview(v2, at: 2)
    }
    
    private func pushToPopUp() {
        currTextField?.resignFirstResponder()
        self.add(popUp: SelectRecipeTypeVC.popUp.popOverVC)
    }
    
    @objc private func buttonAction(sender: UIButton) {
        insert()
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
