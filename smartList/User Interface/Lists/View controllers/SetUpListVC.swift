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
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var storesTextField: UITextField!
    @IBOutlet weak var storesStackView: UIStackView!
    @IBOutlet weak var peopleStackView: UIStackView!
    @IBOutlet weak var finishCreatingOrEditing: UIButton!
    @IBOutlet weak var groupOrNotLabel: UILabel!
    @IBOutlet weak var switchOutlet: UISwitch!
    
    var listToEdit: GroceryList?
    private var db: Firestore!
    private var currentOffset: CGFloat?
    
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
    private var returnGroupID: String?
    private var usingGroup: Bool? {
        didSet {
            handleGroupChangeOrSet()
        }
    }
    // MARK: override funcs
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        nameTextField.delegate = self; storesTextField.delegate = self
        
        nameTextField.setUpListToolbar(action: #selector(handleTextFieldForPlus), arrowAction: #selector(handleTextFieldForArrow))
        storesTextField.setUpListToolbar(action: #selector(handleTextFieldForPlus), arrowAction: #selector(handleTextFieldForArrow))
        
        nameTextField.becomeFirstResponder()
        
        if listToEdit != nil {
            setUIifListIsBeingEdited(list: listToEdit!)
        }
        
        if SharedValues.shared.groupID == nil || listToEdit?.isGroup == false {
            usingGroup = false
        } else {
            usingGroup = true
        }
        if SharedValues.shared.anonymousUser == true {
            switchOutlet.isUserInteractionEnabled = false
        }
    }

    // MARK: @IBAction funcs
    @IBAction func writeToFirestoreIfValid() {
        gatherListData()
        
        
        if name != "" {
            if listToEdit == nil {
                let list = GroceryList(name: name ?? "", isGroup: usingGroup, stores: stores, people: people, items: nil, numItems: nil, docID: nil, timeIntervalSince1970: Date().timeIntervalSince1970, groupID: returnGroupID, ownID: "")
                list.writeToFirestore(db: db)
            } else {
                listToEdit?.stores = stores
                listToEdit?.people = people
                listToEdit?.isGroup = usingGroup
                listToEdit?.name = name ?? listToEdit?.name ?? "Grocery List"
                listToEdit?.editListToFirestore(db: db, listID: listToEdit!.docID!)
            }
            self.dismiss(animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Missing name", message: "Please enter a name to finish creating the list", preferredStyle: .alert)
            alert.addAction(.init(title: "Ok", style: .cancel, handler: nil))
            present(alert, animated: true)
        }
        
    }
    
    @IBAction func dismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func switchAction(_ sender: Any) {
        
        if SharedValues.shared.groupID != nil {
            if switchOutlet.isOn == true {
                usingGroup = true
            } else if switchOutlet.isOn == false {
                usingGroup = false
            }
        } else {
            switchOutlet.isOn = false
            let alert = UIAlertController(title: "Error", message: "Can't use group for your list since you are not in a group.", preferredStyle: .alert)
            alert.addAction(.init(title: "Create group", style: .default, handler: { (action) in
                self.createGroupPopUp()
            }))
            alert.addAction(.init(title: "Ok", style: .default, handler: nil))
            present(alert, animated: true)
        }
    }
    
    // MARK: functions
    private func gatherListData() {
        name = nil; stores = nil; categories = nil; isGroup = nil; people = nil
        name = nameTextField.text ?? ""
        stores = storesStackView.extractDataFromStackView()
        //categories = categoriesStackView.extractDataFromStackView()
        people = peopleStackView.extractDataFromStackView()
        stores = stores?.removeBlanks(); categories = categories?.removeBlanks(); people = people?.removeBlanks()
        people?.append(Auth.auth().currentUser?.email ?? "")
        if usingGroup == true {
            returnGroupID = SharedValues.shared.groupID
        }
    }
    
    
    private func setUIifListIsBeingEdited(list: GroceryList) {
        nameTextField.text = list.name
        finishCreatingOrEditing.setTitle("Save changes", for: .normal)
        
        
        list.stores?.forEach({ (store) in
            if storesTextField.text == "" {
                storesTextField.text = store
            } else {
                insertTextFieldIn(stackView: storesStackView, text: store, userInteraction: true)
            }

        })
        
    }
    
    private func handleGroupChangeOrSet() {
        if self.usingGroup == true {
            switchOutlet.isOn = true
        } else if self.usingGroup == false {
            switchOutlet.isOn = false
        }
        switch self.usingGroup {
        case true:
            peopleStackView.subviews.forEach { (view) in
                if peopleStackView.subviews.firstIndex(of: view)! > 0 {
                    view.removeFromSuperview()
                }
            }
            groupOrNotLabel.text = "Using group"
            for person in SharedValues.shared.groupEmails ?? [""] {
                print(person)
                insertTextFieldIn(stackView: peopleStackView, text: person, userInteraction: false)
            }
            for view in peopleStackView.subviews {
                if (view as? UITextField)?.text == "" {
                    view.removeFromSuperview()
                }
            }
        default:
            groupOrNotLabel.text = "Not using group"
            peopleStackView.subviews.forEach { (view) in
                if peopleStackView.subviews.firstIndex(of: view)! > 0 {
                    view.removeFromSuperview()
                    
                } else {
                    if type(of: view) == UITextField.self {
                        (view as! UITextField).text = ""
                        (view as! UITextField).isUserInteractionEnabled = true
                        (view as! UITextField).setUpListToolbar(action: #selector(handleTextFieldForPlus), arrowAction: #selector(handleTextFieldForArrow))
                    }
                }
            }
            for person in listToEdit?.people ?? [] {
                insertTextFieldIn(stackView: peopleStackView, text: person, userInteraction: true)
            }
            insertTextFieldIn(stackView: peopleStackView, text: "", userInteraction: true)
        }
    }
    
    private func insertTextFieldIn(stackView: UIStackView, text: String, userInteraction: Bool) {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.font = UIFont(name: "futura", size: 15)
        textField.textColor = Colors.main
        textField.delegate = self
        textField.text = text
        stackView.addArrangedSubview(textField)
        textField.isUserInteractionEnabled = userInteraction
        if stackView == peopleStackView {
            textField.placeholder = "Enter user's email"
        }
        textField.setUpListToolbar(action: #selector(handleTextFieldForPlus), arrowAction: #selector(handleTextFieldForArrow))
    }
    
    
    private func insertTextFieldInCorrectSpot(currentTextField: UITextField) {
        let textField = UITextField()
        //textField.border()
        textField.font = UIFont(name: "futura", size: 15)
        textField.textColor = Colors.main
        textField.delegate = self
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        textField.setUpListToolbar(action: #selector(handleTextFieldForPlus), arrowAction: #selector(handleTextFieldForArrow))
        
        if let stackView = (currentTextField.superview as? UIStackView), currentTextField != nameTextField {
            if stackView == peopleStackView {
                textField.placeholder = "Enter user's email"
            }
            if currentTextField == stackView.subviews.last {
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
            (peopleStackView.subviews.last as? UITextField)?.becomeFirstResponder()
        }
    }
    
}

// MARK: Text field delegate
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
        if SharedValues.shared.anonymousUser == true && textField.superview == peopleStackView {
            textField.resignFirstResponder()
            currentTextField = nil
            let alert = UIAlertController(title: "Error", message: "Need to create a free account in order share your list with others.", preferredStyle: .alert)
            alert.addAction(.init(title: "Ok", style: .default, handler: nil))
            present(alert, animated: true)
            
        }
        
    }
    
    
}
