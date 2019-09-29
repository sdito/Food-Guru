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
import FirebaseStorage


class CreateRecipeVC: UIViewController {
    var db: Firestore!
    var storage: Storage!
    let imagePicker = UIImagePickerController()
    var image: Data?
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var servingsTextField: UITextField!
    @IBOutlet weak var cookTimeTextField: UITextField!
    @IBOutlet weak var prepTimeTextField: UITextField!
    @IBOutlet weak var caloriesTextField: UITextField!
    
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var taglineTextView: UITextView!
    
    @IBOutlet weak var selectimageOutlet: UIButton!
    @IBOutlet weak var cuisineOutlet: UIButton!
    @IBOutlet weak var recipeDescriptionOutlet: UIButton!
    @IBOutlet weak var createRecipeOutlet: UIButton!
    
    @IBOutlet weak var instructionsListStackView: UIStackView!
    @IBOutlet weak var ingredientsStackView: UIStackView!
    
    
    //var currTextField: UIView?
    
    var cuisineType: String? {
        didSet {
            cuisineOutlet.setTitle(self.cuisineType, for: .normal)
        }
    }
    var recipeType: [String]? {
        didSet {
            recipeDescriptionOutlet.setTitle(self.recipeType?.joined(separator: ", "), for: .normal)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        storage = Storage.storage()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        selectimageOutlet.border()
        
        nameTextField.delegate = self
        servingsTextField.delegate = self
        cookTimeTextField.delegate = self
        prepTimeTextField.delegate = self
        caloriesTextField.delegate = self
        notesTextView.delegate = self
        taglineTextView.delegate = self
        
        cuisineOutlet.border()
        recipeDescriptionOutlet.border()
        cuisineOutlet.titleEdgeInsets.left = 7
        recipeDescriptionOutlet.titleEdgeInsets.left = 7
        
        nameTextField.becomeFirstResponder()
        createRecipeOutlet.setGradientBackground(colorOne: Colors.main, colorTwo: Colors.mainGradient)
        createRecipeOutlet.layer.cornerRadius = 15
        createRecipeOutlet.clipsToBounds = true
        
        //currTextField = nameTextField
        SharedValues.shared.currText = nameTextField
        
        initialInstructionSetUp()
        notesTextView.border()
        taglineTextView.border()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if SharedValues.shared.recipeType != nil && SharedValues.shared.cuisineType != nil {
            cuisineType = SharedValues.shared.cuisineType
            recipeType = SharedValues.shared.recipeType
            
            SharedValues.shared.cuisineType = nil
            SharedValues.shared.recipeType = nil
            
            cuisineOutlet.setTitleColor(Colors.main, for: .normal)
            recipeDescriptionOutlet.setTitleColor(Colors.main, for: .normal)
        }
    }
    
    @IBAction func createRecipePressed(_ sender: Any) {
        var recipe = Recipe(name: nameTextField.text!, recipeType: recipeType!, cuisineType: cuisineType!, cookTime: cookTimeTextField.toInt()!, prepTime: prepTimeTextField.toInt()!, ingredients: IngredientView.getIngredients(stack: ingredientsStackView), instructions: InstructionView.getInstructions(stack: instructionsListStackView), calories: caloriesTextField.toInt(), numServes: servingsTextField.toInt()!, userID: Auth.auth().currentUser?.uid, numReviews: nil, numStars: nil, notes: notesTextView.text, tagline: taglineTextView.text, recipeImage: image, imagePath: nil)
        recipe.writeToFirestore(db: db, storage: storage)
        navigationController?.popToRootViewController(animated: true)

    }
    
    @IBAction func selectImage(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    
    @IBAction func selectCuisine(_ sender: Any) {
        pushToPopUp()
    }
    @IBAction func selectDescriptions(_ sender: Any) {
        pushToPopUp()
        
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
}





extension CreateRecipeVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameTextField {
            textField.resignFirstResponder()
            servingsTextField.becomeFirstResponder()
        } else if textField == servingsTextField {
            textField.resignFirstResponder()
            cookTimeTextField.becomeFirstResponder()
            performSegue(withIdentifier: "recipeDetailSelection", sender: nil)
        } else if textField == cookTimeTextField {
            textField.resignFirstResponder()
            prepTimeTextField.becomeFirstResponder()
        } else if textField == prepTimeTextField {
            textField.resignFirstResponder()
            caloriesTextField.becomeFirstResponder()
        } else if textField == caloriesTextField {
            textField.resignFirstResponder()
        }
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        SharedValues.shared.currText = textField
    }
}


extension CreateRecipeVC: UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        SharedValues.shared.currText = textView
        return true
    }
}


extension CreateRecipeVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            selectimageOutlet.contentMode = .scaleAspectFit
            selectimageOutlet.setBackgroundImage(pickedImage, for: .normal)
            selectimageOutlet.setTitle("", for: .normal)
            image = pickedImage.jpegData(compressionQuality: 0.75)
            print(pickedImage.size.height, pickedImage.size.width)
        
//            #error("have something working with the below three lines of code, need to get it so that the edited image gets written to firestore")
//            let url = info[UIImagePickerController.InfoKey.imageURL] as! URL
//            let uploadReference = Storage.storage().reference(withPath: "testImagePath")
//            uploadReference.putFile(from: url)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
}
