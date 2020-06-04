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
    
    @IBOutlet var stackViewsToHide: [UIStackView]!
    @IBOutlet weak var scrollView: UIScrollView!
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
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var recipeTypeStackView: UIStackView!
    
    var db: Firestore!
    var fromPlanner: (Bool, String?)?
    weak var mealPlannerRecipeDelegate: CreateRecipeForMealPlannerDelegate!
    
    private var storage: Storage!
    private let imagePicker = UIImagePickerController()
    private var image: Data?
    private var forCookbook = true {
        didSet {
            self.handleUI()
        }
    }
    private var cuisineType: String? {
        didSet {
            cuisineOutlet.setTitle(self.cuisineType, for: .normal)
        }
    }
    private var recipeType: [String]? {
        didSet {
            recipeDescriptionOutlet.setTitle(self.recipeType?.joined(separator: ", "), for: .normal)
        }
    }
    // MARK: Override funcs
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        storage = Storage.storage()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        selectimageOutlet.border(cornerRadius: 5.0)
        
        nameTextField.delegate = self
        servingsTextField.delegate = self
        cookTimeTextField.delegate = self
        prepTimeTextField.delegate = self
        caloriesTextField.delegate = self
        notesTextView.delegate = self
        taglineTextView.delegate = self
        urlTextField.delegate = self
        cuisineOutlet.border(cornerRadius: 5.0)
        recipeDescriptionOutlet.border(cornerRadius: 5.0)
        cuisineOutlet.titleEdgeInsets.left = 7
        recipeDescriptionOutlet.titleEdgeInsets.left = 7
        
        createRecipeOutlet.setGradientBackground(colorOne: Colors.main, colorTwo: Colors.secondary)
        createRecipeOutlet.layer.cornerRadius = 15
        createRecipeOutlet.clipsToBounds = true
        
        //currTextField = nameTextField
        SharedValues.shared.currText = nameTextField
        
        initialInstructionSetUp()
        notesTextView.border(cornerRadius: 5.0)
        taglineTextView.border(cornerRadius: 5.0)
        self.createNavigationBarTextAttributes()
        
        handleUI()
        createObserver()
        
        if fromPlanner != nil && fromPlanner!.0 {
            recipeTypeStackView.removeFromSuperview()
        }
        
        notesTextView.setUpDoneToolbar(action: #selector(removeFirstResponder), style: .done)
        taglineTextView.setUpDoneToolbar(action: #selector(removeFirstResponder), style: .done)
        nameTextField.setUpDoneToolbar(action: #selector(removeFirstResponder), style: .done)
        servingsTextField.setUpDoneToolbar(action: #selector(removeFirstResponder), style: .done)
        cookTimeTextField.setUpDoneToolbar(action: #selector(removeFirstResponder), style: .done)
        prepTimeTextField.setUpDoneToolbar(action: #selector(removeFirstResponder), style: .done)
        caloriesTextField.setUpDoneToolbar(action: #selector(removeFirstResponder), style: .done)
        urlTextField.setUpDoneToolbar(action: #selector(removeFirstResponderURL), style: .done)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    // MARK: @IBAction funcs
    @IBAction func linkToRecipe(_ sender: Any) {
        urlView.isHidden = !urlView.isHidden
    }
    
    @IBAction func findUrlRecipe(_ sender: Any) {
        let stringRepresentation = String(urlTextField.text ?? "")
        Recipe.getRecipeInfoFromURLallRecipes(recipeURL: stringRepresentation)
    }
    
    @IBAction func infoAboutPrivateAndPublic(_ sender: Any) {
        let alert = UIAlertController(title: "Private vs. Public Recipes", message: "Select private if you want this recipe to be in your cookbook (you can navigate to your cookbook from the recipe home page by selecting cookbook on the bottom). Cookbook recipes will be only visible to you and will be saved on your device. Select public if you want this recipe to be viewed by everyone. This recipe would appear in the recipe home page once it is approved.", preferredStyle: .alert)
        alert.addAction(.init(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true)
    }
    
    @IBAction func segmentedControlPressed(_ sender: Any) {
        if segmentedControl.selectedSegmentIndex == 0 {
            forCookbook = true
        } else {
            forCookbook = false
        }
    }
    
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
        
        switch forCookbook {
        case false:
            if fromPlanner?.0 == true {
                forCookbook = true
                fallthrough
            }
            guard let img = image else {
                let alert = UIAlertController(title: "Error", message: "Missing recipe image", preferredStyle: .alert)
                alert.addAction(.init(title: "Ok", style: .default, handler: nil))
                present(alert, animated: true)
                return
            }
            
            guard taglineTextView.text != "" else {
                print("Missing tagline")
                let alert = UIAlertController(title: "Error", message: "Missing recipe tagline data", preferredStyle: .alert)
                alert.addAction(.init(title: "Ok", style: .default, handler: nil))
                present(alert, animated: true)
                return
            }
            
            guard let rType = recipeType, let cType = cuisineType, let cookTime = cookTimeTextField.toInt(), let prepTime = prepTimeTextField.toInt(), let servings = servingsTextField.toInt(), let uid = Auth.auth().currentUser?.uid else {
                let alert = UIAlertController(title: "Error", message: "Incomplete recipe data", preferredStyle: .alert)
                alert.addAction(.init(title: "Ok", style: .default, handler: nil))
                present(alert, animated: true)
                return
            }
            
            var recipe = Recipe(name: nameTextField.text!, recipeType: rType, cuisineType: cType, cookTime: cookTime, prepTime: prepTime, ingredients: IngredientView.getIngredients(stack: ingredientsStackView), instructions: InstructionView.getInstructions(stack: instructionsListStackView), calories: caloriesTextField.toInt(), numServes: servings, userID: uid, numReviews: nil, numStars: nil, notes: notesTextView.text, tagline: taglineTextView.text, recipeImage: img, mainImage: nil, reviewImagePaths: nil)
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
            
            
            if fromPlanner?.0 == true {
                if mealPlannerRecipeDelegate != nil {
                    print("This is being called")
                    mealPlannerRecipeDelegate.recipeCreated(recipe: cookbookRecipe)
                } else {
                    print("Something went wrong... mealPlannerRecipeDelegate is nil on CreateRecipeVC")
                }
                
            }
            
            
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
    // MARK: Functions
    private func createObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(recipeDataReceivedFromURL), name: .recipeDataFromURLReceived, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(noRecipeFound), name: .recipeNotFoundFromURLalert, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc private func noRecipeFound() {
        
        DispatchQueue.main.async {
            self.urlTextField.resignFirstResponder()
            self.urlTextField.text = ""
            let alert = UIAlertController(title: "Error", message: "No recipe found from your URL! Make sure the reciple URL you copied is from allrecipes.com", preferredStyle: .alert)
            alert.addAction(.init(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
        
    }
    
    @objc private func removeFirstResponder() {
        SharedValues.shared.currText?.resignFirstResponder()
    }
    
    @objc private func removeFirstResponderURL() {
        urlTextField.resignFirstResponder()
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
    
    @objc private func recipeDataReceivedFromURL(_ notification: NSNotification) {
        if let data = notification.userInfo as NSDictionary? {
            DispatchQueue.main.async {
                self.resetDataForNewRecipeFromURL()
                self.urlView.isHidden = true
                self.urlTextField.resignFirstResponder()
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
                    
                    let numIngredientViewsToAdd = Int((Double(ingredients.count) / 2.0).rounded(.up)) - 2
                    if numIngredientViewsToAdd >= 1 {
                        for _ in 1...numIngredientViewsToAdd {
                            let v = Bundle.main.loadNibNamed("IngredientView", owner: nil, options: nil)?.first as! IngredientView
                            self.ingredientsStackView.addArrangedSubview(v)
                        }
                    }
                    
                    var idx = 1
                    for ingredient in ingredients {
                        let currentView = self.ingredientsStackView.subviews[idx] as? IngredientView
                        if currentView?.left.text == "" {
                            currentView?.left.text = ingredient
                        } else {
                            currentView?.right.text = ingredient
                            idx += 1
                        }
                    }
                    
                }
                if let instructions = data["instructions"] as? [String] {
                    print(instructions)
                    if instructions.count > 1 {
                        for _ in 1...instructions.count - 1 {
                            self.insert()
                        }
                    }
                    
                    var idx = 1
                    if instructions.count > 1 {
                        for i in instructions {
                            (self.instructionsListStackView.subviews[idx] as? InstructionView)?.tv.text = i
                            idx += 1
                        }
                    } else {
                        (self.instructionsListStackView?.subviews[1] as? InstructionView)?.tv.text = instructions.first
                    }
                }
                if let servings = data["servings"] as? Int {
                    print(servings)
                    self.servingsTextField.text = "\(servings)"
                }
            }
        }
    }
    
    
    
    private func handleUI() {
        if forCookbook == true {
            stackViewsToHide.forEach { (sv) in
                sv.isHidden = true
            }
        } else {
            stackViewsToHide.forEach { (sv) in
                sv.isHidden = false
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
            if forCookbook == false {
                performSegue(withIdentifier: "recipeDetailSelection", sender: nil)
            }
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
        if textField != urlTextField {
            SharedValues.shared.currText = textField
        }
        
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


// MARK: Picker controller
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
        }
        dismiss(animated: true, completion: nil)
    }
}

