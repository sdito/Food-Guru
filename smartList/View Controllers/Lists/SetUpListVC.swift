//
//  SetUpListVC.swift
//  smartList
//
//  Created by Steven Dito on 9/12/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class SetUpListVC: UIViewController {
    private var listToEdit: List?
    private var db: Firestore!
    
    //start list data
    private var name: String?
    private var stores: [String]?
    private var categories: [String]?
    private var isGroup: Bool?
    private var groupID: String? {
        if isGroup == true {
            return SharedValues.shared.groupID
        } else {
            return nil
        }
    }
    private var people: [String]?
    // end list data
    
    private var currentTextField: UITextField?
    
    @IBOutlet weak var topView: UIView!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var storesTextField: UITextField!
    @IBOutlet weak var categoriesTextField: UITextField!
    @IBOutlet weak var peopleTextField: UITextField!
    
    @IBOutlet weak var storesStackView: UIStackView!
    @IBOutlet weak var categoriesStackView: UIStackView!
    @IBOutlet weak var peopleStackView: UIStackView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        nameTextField.delegate = self
        storesTextField.delegate = self
        categoriesTextField.delegate = self
        peopleTextField.delegate = self
        
        nameTextField.setUpListToolbar(action: #selector(handleTextFieldForPlus), arrowAction: #selector(handleTextFieldForArrow))
        storesTextField.setUpListToolbar(action: #selector(handleTextFieldForPlus), arrowAction: #selector(handleTextFieldForArrow))
        categoriesTextField.setUpListToolbar(action: #selector(handleTextFieldForPlus), arrowAction: #selector(handleTextFieldForArrow))
        peopleTextField.setUpListToolbar(action: #selector(handleTextFieldForPlus), arrowAction: #selector(handleTextFieldForArrow))
        
        nameTextField.becomeFirstResponder()
        
        if listToEdit != nil {
            setUIifListIsBeingEdited(list: listToEdit!)
        }
        
    }
    
    @IBAction func writeToFirestoreIfValid() {
        gatherListData()
        let list = List(name: name ?? "", stores: stores, categories: categories, people: people, items: nil, numItems: nil, docID: nil, timeIntervalSince1970: Date().timeIntervalSince1970)
        
        if name != "" {
            if listToEdit == nil {
                list.writeToFirestore(db: db)
            } else {
                list.editListToFirestore(db: db, listID: listToEdit!.docID!)
            }
        } else {
            let alert = UIAlertController(title: "Missing name", message: "Please enter a name to finish creating the list", preferredStyle: .alert)
            alert.addAction(.init(title: "Ok", style: .cancel, handler: nil))
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func dismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        topView.setGradientBackground(colorOne: Colors.main, colorTwo: Colors.mainGradient)
    }
    
    private func gatherListData() {
        name = nil; stores = nil; categories = nil; isGroup = nil; people = nil
        name = nameTextField.text ?? ""
        stores = storesStackView.extractDataFromStackView()
        categories = categoriesStackView.extractDataFromStackView()
        people = peopleStackView.extractDataFromStackView()
        stores = stores?.removeBlanks(); categories = categories?.removeBlanks(); people = people?.removeBlanks()
        people?.append(Auth.auth().currentUser?.email ?? "")
    }
    
    
    private func setUIifListIsBeingEdited(list: List) {
        nameTextField.text = list.name
        
    }
    
    private func insertTextFieldInCorrectSpot(currentTextField: UITextField) {
        let textField = UITextField()
        //textField.border()
        textField.font = UIFont(name: "futura", size: 16)
        textField.textColor = Colors.main
        textField.delegate = self
        textField.borderStyle = .roundedRect
        textField.setUpListToolbar(action: #selector(handleTextFieldForPlus), arrowAction: #selector(handleTextFieldForArrow))
        
        if let stackView = (currentTextField.superview as? UIStackView), currentTextField != nameTextField {
            if currentTextField == stackView.subviews.last {
                print("got to this point")
                print(stackView.subviews.count)
                stackView.insertArrangedSubview(textField, at: stackView.subviews.count)
                currentTextField.resignFirstResponder()
                textField.becomeFirstResponder()
            } else {
                currentTextField.resignFirstResponder()
                if let index = stackView.subviews.firstIndex(of: currentTextField) {
                    if let tf = (stackView.subviews[index + 1] as? UITextField) {
                        tf.becomeFirstResponder()
                    }
                }
            }
        }
    }
    @objc func handleTextFieldForPlus() {
        insertTextFieldInCorrectSpot(currentTextField: currentTextField ?? nameTextField)
        if currentTextField == nameTextField {
            nameTextField.resignFirstResponder()
            storesTextField.becomeFirstResponder()
        }
    }
    @objc func handleTextFieldForArrow() {
        if currentTextField == nameTextField {
            currentTextField?.resignFirstResponder()
            storesTextField.becomeFirstResponder()
        } else if currentTextField?.superview == storesStackView {
            currentTextField?.resignFirstResponder()
            (categoriesStackView.subviews.last as? UITextField)?.becomeFirstResponder()
        } else if currentTextField?.superview == categoriesStackView {
            currentTextField?.resignFirstResponder()
            (peopleStackView.subviews.last as? UITextField)?.becomeFirstResponder()
        }
    }
    
}


extension SetUpListVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        insertTextFieldInCorrectSpot(currentTextField: textField)
        if textField == nameTextField {
            textField.resignFirstResponder()
            storesTextField.becomeFirstResponder()
        }
        
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        currentTextField = textField
    }
}
