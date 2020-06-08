//
//  CreateRecipeVC.swift
//  smartList
//
//  Created by Steven Dito on 8/19/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import UIKit
import Firebase
import RealmSwift



protocol CreateRecipeForMealPlannerDelegate: class {
    func recipeCreated(recipe: CookbookRecipe)
}


class CreateRecipeVC: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var servingsTextField: UITextField!
    @IBOutlet weak var cookTimeTextField: UITextField!
    @IBOutlet weak var prepTimeTextField: UITextField!
    @IBOutlet weak var caloriesTextField: UITextField!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var createRecipeOutlet: UIButton!
    @IBOutlet weak var instructionsListStackView: UIStackView!
    @IBOutlet weak var ingredientsStackView: UIStackView!
    
    var db: Firestore!
    var fromPlanner: (Bool, String?)?
    weak var mealPlannerRecipeDelegate: CreateRecipeForMealPlannerDelegate!
    
    
    private var image: Data?
    private var forCookbook = true

    // MARK: Override funcs
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        
        nameTextField.delegate = self
        servingsTextField.delegate = self
        cookTimeTextField.delegate = self
        prepTimeTextField.delegate = self
        caloriesTextField.delegate = self
        notesTextView.delegate = self
        
        createRecipeOutlet.setGradientBackground(colorOne: Colors.main, colorTwo: Colors.secondary)
        createRecipeOutlet.layer.cornerRadius = 15
        createRecipeOutlet.clipsToBounds = true
        
        //currTextField = nameTextField
        SharedValues.shared.currText = nameTextField
        
        initialInstructionSetUp()
        notesTextView.border(cornerRadius: 5.0)
        self.createNavigationBarTextAttributes()
        
        createObserver()
        
        
        notesTextView.setUpDoneToolbar(action: #selector(removeFirstResponder), style: .done)
        nameTextField.setUpDoneToolbar(action: #selector(removeFirstResponder), style: .done)
        servingsTextField.setUpDoneToolbar(action: #selector(removeFirstResponder), style: .done)
        cookTimeTextField.setUpDoneToolbar(action: #selector(removeFirstResponder), style: .done)
        prepTimeTextField.setUpDoneToolbar(action: #selector(removeFirstResponder), style: .done)
        caloriesTextField.setUpDoneToolbar(action: #selector(removeFirstResponder), style: .done)
    }

    
    deinit {
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    // MARK: @IBAction funcs
    
    @IBAction func createRecipePressed(_ sender: Any) {
        
        
        guard nameTextField.text != "" else {
            let alert = UIAlertController(title: "Error", message: "Missing recipe name", preferredStyle: .alert)
            alert.addAction(.init(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
        
        guard InstructionView.getInstructions(stack: instructionsListStackView) != [] else {
            let alert = UIAlertController(title: "Error", message: "Missing recipe instructions", preferredStyle: .alert)
            alert.addAction(.init(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
        
        guard IngredientView.getIngredients(stack: ingredientsStackView) != [] else {
            let alert = UIAlertController(title: "Error", message: "Missing recipe ingredients", preferredStyle: .alert)
            alert.addAction(.init(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
        
        let ingredients: List<String> = List.init()
        let instructions: List<String> = List.init()
        IngredientView.getIngredients(stack: ingredientsStackView).forEach { (str) in
            ingredients.append(str)
        }
        InstructionView.getInstructions(stack: instructionsListStackView).forEach { (str) in
            instructions.append(str)
        }
        
        let cookbookRecipe = CookbookRecipe()
        cookbookRecipe.setUp(name: nameTextField.text!, servings: RealmOptional(servingsTextField.toInt()), cookTime: RealmOptional(cookTimeTextField.toInt()), prepTime: RealmOptional(prepTimeTextField.toInt()), calories: RealmOptional(caloriesTextField.toInt()), ingredients: ingredients, instructions: instructions, notes: notesTextView.text)
        cookbookRecipe.write()
        
        navigationController?.popToRootViewController(animated: true)
        
        
        if fromPlanner?.0 == true {
            if mealPlannerRecipeDelegate != nil {
                print("This is being called")
                mealPlannerRecipeDelegate.recipeCreated(recipe: cookbookRecipe)
            } else {
                print("Something went wrong... mealPlannerRecipeDelegate is nil on CreateRecipeVC")
            }
            
        }
    }
    
    // MARK: Functions
    private func createObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }

    
    @objc private func removeFirstResponder() {
        SharedValues.shared.currText?.resignFirstResponder()
    }

    @objc private func keyboardChange(notification: Notification) {
        //#error("left off here")
        guard let keyboardRect = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let toolbarHeight: CGFloat = 40.0
        
        if let view = SharedValues.shared.currText {
            let frame = view.convert(view.frame, to: UIApplication.shared.keyWindow)
            let viewPosition = (UIApplication.shared.keyWindow?.bounds.height)! - frame.origin.y
            let keyboardPosition = keyboardRect.height + toolbarHeight
            
            if viewPosition > keyboardPosition {
                print("All is good")
            } else {
                let difference = keyboardPosition - viewPosition
                print("Need to move: \(difference)")
                #warning("need to scroll down the scroll view by the difference here")
            }
        }
    }
    
    private func insert() {
        let v = (Bundle.main.loadNibNamed("InstructionView", owner: nil, options: nil)?.first as? InstructionView)!
        v.setUI(num: "+")
        v.button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        v.tv.delegate = self
        
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
        
        v.tv.delegate = self
        v2.tv.delegate = self
        instructionsListStackView.insertArrangedSubview(v, at: 1)
        instructionsListStackView.insertArrangedSubview(v2, at: 2)
        
        
        let t = (Bundle.main.loadNibNamed("IngredientView", owner: nil, options: nil)?.first as? IngredientView)!
        let t2 = (Bundle.main.loadNibNamed("IngredientView", owner: nil, options: nil)?.first as? IngredientView)!
        
        ingredientsStackView.insertArrangedSubview(t, at: 1)
        ingredientsStackView.insertArrangedSubview(t2, at: 2)
    }
    
    private func pushToPopUp() {
        performSegue(withIdentifier: "recipeDetailSelection", sender: nil)
    }
    
    @objc private func buttonAction(sender: UIButton) {
        insert()
    }
    
    private func resetDataForNewRecipeFromURL() {
        instructionsListStackView.subviews.forEach { (v) in
            if type(of: v) == InstructionView.self {
                v.removeFromSuperview()
            }
        }
        
        ingredientsStackView.subviews.forEach { (v) in
            if type(of: v) == IngredientView.self {
                v.removeFromSuperview()
            }
        }
        initialInstructionSetUp()
    }
}



// MARK: Text field
extension CreateRecipeVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameTextField {
            textField.resignFirstResponder()
            servingsTextField.becomeFirstResponder()
        } else if textField == servingsTextField {
            textField.resignFirstResponder()
            cookTimeTextField.becomeFirstResponder()
        } else if textField == cookTimeTextField {
            textField.resignFirstResponder()
            prepTimeTextField.becomeFirstResponder()
        } else if textField == prepTimeTextField {
            textField.resignFirstResponder()
            caloriesTextField.becomeFirstResponder()
        } else if textField == caloriesTextField {
            textField.resignFirstResponder()
            print("Got to this point")
            if let tf = ingredientsStackView.subviews[1] as? IngredientView {
                tf.left.becomeFirstResponder()
            }
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        SharedValues.shared.currText = textField
        
    }
}

// MARK: Text view
extension CreateRecipeVC: UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        SharedValues.shared.currText = textView
        
        if let iv = textView.superview?.superview as? InstructionView {
            if iv.button.titleLabel?.text == "+" {
                print("Need to add another tv")
                insert()
            }
        }
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.setUpDoneToolbar(action: #selector(removeTextViewKeyboard), style: .done)
    }
    
    @objc func removeTextViewKeyboard() {
        SharedValues.shared.currText?.resignFirstResponder()
    }
}

