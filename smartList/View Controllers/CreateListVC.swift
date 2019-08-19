//
//  CreateListVC.swift
//  smartList
//
//  Created by Steven Dito on 8/3/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import UIKit

//import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

class CreateListVC: UIViewController {
    
    
    
    
    var listToEdit: List?
    
    
    
    
    var db: Firestore!
    var all = ListOrganizer.createListViews()
    
    private var section: Section?
    private var textFieldCombo: [UITextField:Section] = [:]
    private var w: CGFloat!
    private var h: CGFloat!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var nameOutlet: UIButton!
    @IBOutlet weak var storesOutlet: UIButton!
    @IBOutlet weak var categoriesOutlet: UIButton!
    @IBOutlet weak var peopleOutlet: UIButton!
    
    lazy private var buttons: [UIButton] = [nameOutlet, storesOutlet, categoriesOutlet, peopleOutlet]
    
    override func viewDidLoad() {
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        
        super.viewDidLoad()
        nameTextField.delegate = self
        scrollView.delegate = self
        nameTextField.becomeFirstResponder()
        nameTextField!.insertToolBar()
        for i in all {
            i.listView.textField.delegate = self
            i.listView.setUI(title: i.title, list: i.items)
            stackView.insertArrangedSubview(i.listView, at: 1)
        }
        textFieldCombo = [nameTextField:.name, all[2].listView.textField:.stores, all[1].listView.textField:.categories, all[0].listView.textField:.people]
        w = stackView.subviews[0].frame.width
        h = stackView.subviews[0].frame.height
        
        buttons.setSelected(selected: nameOutlet)
        
        
        setUIforEditingList(list: listToEdit)

    }
    @IBAction func nameButton(_ sender: Any) {
        scrollView.scrollRectToVisible(CGRect(x: 0, y: 0, width: w, height: h), animated: true)
        section = .name
    }
    @IBAction func storesButton(_ sender: Any) {
        scrollView.scrollRectToVisible(CGRect(x: w, y: 0, width: w, height: h), animated: true)
        section = .stores
    }
    @IBAction func categoriesButton(_ sender: Any) {
        scrollView.scrollRectToVisible(CGRect(x: w*2, y: 0, width: w, height: h), animated: true)
        section = .categories
    }
    @IBAction func peopleButton(_ sender: Any) {
        scrollView.scrollRectToVisible(CGRect(x: w*3, y: 0, width: w, height: h), animated: true)
        section = .people
        
    }
    
    private enum Section {
        case name
        case stores
        case categories
        case people
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addItems" {
            let destVC = segue.destination as! AddItemsVC
            destVC.list = sender as? List
        }
    }
    
    private func setUIforEditingList(list: List?) {
        if list != nil {
            nameTextField.text = list?.name
            all[2].items = list?.stores ?? [""]
            all[1].items = list?.categories ?? [""]
            all[0].items = list?.people ?? [""]
        }
    }
}


extension CreateListVC: CreateListViewDelegate {
    func setUpToolbar() {
        for tf in textFieldCombo {
            if tf.key.isFirstResponder {
                switch tf.value {
                case .name:
                    fallthrough
                case .stores:
                    all[2].items.append(tf.key.text!)
                case .categories:
                    all[1].items.append(tf.key.text!)
                case .people:
                    all[0].items.append(tf.key.text!)
                }
                tf.key.text = ""
            }
        }
    }
}

extension CreateListVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let w = stackView.subviews[0].frame.width
        let h = stackView.subviews[0].frame.height
        if textField == nameTextField {
            scrollView.scrollRectToVisible(CGRect(x: w, y: 0, width: w, height: h), animated: true)
            section = .stores
        } else if textField == all[2].listView.textField {
            scrollView.scrollRectToVisible(CGRect(x: w*2, y: 0, width: w, height: h), animated: true)
            section = .categories
        } else if textField == all[1].listView.textField {
            scrollView.scrollRectToVisible(CGRect(x: w*3, y: 0, width: w, height: h), animated: true)
            section = .people
        } else if textField == all[0].listView.textField {
            var list = List(name: nameTextField.text!, stores: all[2].items, categories: all[1].items, people: all[0].items, items: nil, numItems: nil, docID: nil)
            
            let email = (Auth.auth().currentUser?.email)!
            list.people?.append(email)
            
            list.categories = list.categories?.removeBlanks()
            list.people = list.people?.removeBlanks()
            list.stores = list.stores?.removeBlanks()
            
            // writeToFirestore for a brand new list; editListToFirestore for editing a preexisting list
            if listToEdit == nil {
                list.writeToFirestore(db: db)
            } else {
                list.editListToFirestore(db: db, listID: listToEdit!.docID!)
            }
            
            
            performSegue(withIdentifier: "addItems", sender: list)
        }
        return true
    }
}


extension CreateListVC: UIScrollViewDelegate {
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        UITextField().resignFirstResponder()
        switch section! {
        case .name:
            nameTextField.becomeFirstResponder()
            buttons.setSelected(selected: nameOutlet)
        case .stores:
            all[2].listView.textField.becomeFirstResponder()
            buttons.setSelected(selected: storesOutlet)
        case .categories:
            all[1].listView.textField.becomeFirstResponder()
            buttons.setSelected(selected: categoriesOutlet)
        case .people:
            all[0].listView.textField.becomeFirstResponder()
            buttons.setSelected(selected: peopleOutlet)
        }
    }
}
