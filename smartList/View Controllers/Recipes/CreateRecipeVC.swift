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


class CreateRecipeVC: UIViewController {
    var db: Firestore!
    var storage: Storage!
    let imagePicker = UIImagePickerController()
    let imageToTextRecipe = UIImagePickerController()
    var image: Data?
    private var forCookbook = false
    
    @IBOutlet var stackViewsToHide: [UIStackView]!
    
    
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
    
    
    @IBOutlet weak var urlView: UIView!
    @IBOutlet weak var urlTextField: UITextField!
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
        urlTextField.delegate = self
        cuisineOutlet.border()
        recipeDescriptionOutlet.border()
        cuisineOutlet.titleEdgeInsets.left = 7
        recipeDescriptionOutlet.titleEdgeInsets.left = 7
        
        //nameTextField.becomeFirstResponder()
        
        
        createRecipeOutlet.setGradientBackground(colorOne: Colors.main, colorTwo: Colors.mainGradient)
        createRecipeOutlet.layer.cornerRadius = 15
        createRecipeOutlet.clipsToBounds = true
        
        //currTextField = nameTextField
        SharedValues.shared.currText = nameTextField
        
        initialInstructionSetUp()
        notesTextView.border()
        taglineTextView.border()
        self.createNavigationBarTextAttributes()
        
        
        handleUI()
        createObserver()
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
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func createObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(recipeDataReceivedFromURL), name: .recipeDataFromURLReceived, object: nil)
    }
    
    @objc private func recipeDataReceivedFromURL(_ notification: NSNotification) {
        if let data = notification.userInfo as NSDictionary? {
            //#error("now just need to change the values on the fields, thread issue")
            DispatchQueue.main.async {
                if let title = data["title"] as? String {
                    print(title)
                    
                    self.nameTextField.text = title
                }
                if let calories = data["calories"] as? Int {
                    print(calories)
                    self.caloriesTextField.text = "\(calories)"
                }
                if let cookTime = data["cookTime"] as? Int {
                    print(cookTime)
                    self.cookTimeTextField.text = "\(cookTime)"
                }
                if let prepTime = data["prepTime"] as? Int {
                    print(prepTime)
                    self.prepTimeTextField.text = "\(prepTime)"
                }
                if let ingredients = data["ingredients"] as? [String] {
                    print(ingredients)
                }
                if let instructions = data["instructions"] as? [String] {
                    print(instructions)
                }
                if let servings = data["servings"] as? Int {
                    print(servings)
                    self.servingsTextField.text = "\(servings)"
                }
            }
            
        }
    }
    
    @IBAction func linkToRecipe(_ sender: Any) {
        print("Link to recipe")
        urlView.isHidden = !urlView.isHidden
        
    }
    
    @IBAction func findUrlRecipe(_ sender: Any) {
        print("Find recipe")
        Recipe.getRecipeInfoFromURLallRecipes(recipeURL: urlTextField.text!)
        
        
    }
    
    @IBAction func imageToRecipe(_ sender: Any) {
        print("Image to recipe")
        imageToTextRecipe.sourceType = .photoLibrary
        imageToTextRecipe.delegate = self
        present(imageToTextRecipe, animated: true)
        
    }
    
    @IBAction func createRecipePressed(_ sender: Any) {
        switch forCookbook {
        case false:
            var recipe = Recipe(name: nameTextField.text!, recipeType: recipeType!, cuisineType: cuisineType!, cookTime: cookTimeTextField.toInt()!, prepTime: prepTimeTextField.toInt()!, ingredients: IngredientView.getIngredients(stack: ingredientsStackView), instructions: InstructionView.getInstructions(stack: instructionsListStackView), calories: caloriesTextField.toInt(), numServes: servingsTextField.toInt()!, userID: Auth.auth().currentUser?.uid, numReviews: nil, numStars: nil, notes: notesTextView.text, tagline: taglineTextView.text, recipeImage: image, imagePath: nil)
            recipe.writeToFirestore(db: db, storage: storage)
            navigationController?.popToRootViewController(animated: true)
        case true:
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
            
        }
        

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
    
    private func handleUI() {
        if (self.navigationController?.viewControllers.first as? CookbookVC) != nil {
            forCookbook = true
            stackViewsToHide.forEach { (sv) in
                sv.removeFromSuperview()
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
        if textField != urlTextField {
            SharedValues.shared.currText = textField
        }
        
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
        if picker == imagePicker {
            if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
                selectimageOutlet.contentMode = .scaleAspectFit
                selectimageOutlet.setBackgroundImage(pickedImage, for: .normal)
                selectimageOutlet.setTitle("", for: .normal)
                image = pickedImage.jpegData(compressionQuality: 0.75)
                print(pickedImage.size.height, pickedImage.size.width)
                
            }
        } else if picker == imageToTextRecipe {
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                let vision = Vision.vision()
                let textRecognizer = vision.cloudDocumentTextRecognizer()
                let visionImage = VisionImage(image: image)
                textRecognizer.process(visionImage) { (result, error) in
                    guard error == nil, let result = result else {
                        print("Error reading text: \(String(describing: error))")
                        return
                    }
                    
                    result.tryToGetRecipeInfo()
                    
                    let alert = UIAlertController(title: "Text from image", message: "blocks: \(result.blocks.map({$0.text}))", preferredStyle: .alert)
                    alert.addAction(.init(title: "Ok", style: .default, handler: nil))
                    self.present(alert, animated: true)
                    
                    print(result.text)
                }
            }
        }
        
        
        dismiss(animated: true, completion: nil)
    }
    
}



