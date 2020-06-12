//
//  AdvancedSearchView.swift
//  smartList
//
//  Created by Steven Dito on 6/7/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit




protocol AdvancedSearchViewDelegate: class {
    func searchesSent(searches: [NetworkSearch])
}




class AdvancedSearchView: UIView {

    @IBOutlet weak var mainStackView: UIStackView!
    
    @IBOutlet weak var ingredientsTF: UITextField!
    @IBOutlet weak var titleTF: UITextField!
    @IBOutlet weak var tagTF: UITextField!
    @IBOutlet weak var avoidIngsTF: UITextField!
    
    private var parentVC: UIViewController?
    private var delegate: SearchAssistantDelegate!
    private var createNewItemVC: CreateNewItemVC?
    private var activeTextField: UITextField?
    
    weak var advancedSearchViewDelegate: AdvancedSearchViewDelegate!
    
    func setUI(vc: UIViewController) {
        advancedSearchViewDelegate = vc as? AdvancedSearchViewDelegate
        print("initial set up")
        ingredientsTF.delegate = self
        tagTF.delegate = self
        avoidIngsTF.delegate = self
        self.parentVC = self.findViewController()
        
        ingredientsTF.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        tagTF.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        avoidIngsTF.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
    }

    @IBAction func searchPressed(_ sender: Any) {
        print("search has been pressed")
        #error("some black magic stuff is happening when searching on the server for this with title, *ingredient")
        self.findViewController()?.dismiss(animated: false, completion: nil)
        advancedSearchViewDelegate.searchesSent(searches: collectSearches())
        
    }
    
    @IBAction func infoButton(_ sender: Any) {
        #warning("need to complete")
    }

    
    @objc private func textFieldDidChange(textField: UITextField) {
        if let text = textField.text {
            delegate.searchTextChanged(text: text.getLastPartOfSearchForQuery())
            
            if textField == tagTF {
                #warning("left off here")
                if Network.shared.tags.map({$0.text.lowercased()}).contains(text.lowercased()) {
                    textField.textColor = Colors.main
                } else {
                    textField.textColor = .red
                }
            }
            
        }
        
        
        
    }
    
    private func collectSearches() -> [NetworkSearch] {
        var foundSearches: [NetworkSearch] = []
        // Ingredients
        if let ingredientsText = ingredientsTF.text, ingredientsText != "" {
            let strIngs = ingredientsText.splitCommaAndQuotes()
            strIngs.forEach {
                let ns = NetworkSearch(text: $0, type: .ingredient)
                foundSearches.append(ns)
            }
        }
        // Title
        if let titleText = titleTF.text, titleText != "" {
            print("adding title text: \(titleText)")
            foundSearches.append(NetworkSearch(text: titleText, type: .title))
        }
        
        // Avoid ingredients
        if let avoidIngredientsText = avoidIngsTF.text, avoidIngredientsText != "" {
            let strAvoidIngs = avoidIngredientsText.splitCommaAndQuotes()
            strAvoidIngs.forEach {
                let ns = NetworkSearch(text: $0, type: .avoidIngredient)
                foundSearches.append(ns)
            }
        }
        
        // Tag
        if let tagText = tagTF.text, tagText != "" {
            foundSearches.append(NetworkSearch(text: tagText, type: .tag))
        }
        
        return foundSearches
    }
    
}


extension AdvancedSearchView: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
        addSuggestions(below: textField, forIngredients: textField == avoidIngsTF || textField == ingredientsTF)
    }
    
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("Textfield did end editing")
        if let createNewItemVC = createNewItemVC {
            createNewItemVC.willMove(toParent: nil)
            createNewItemVC.view.removeFromSuperview()
            createNewItemVC.removeFromParent()
        }
    }
}

// MARK: Handle suggested searches
extension AdvancedSearchView {
    private func addSuggestions(below view: UIView, forIngredients: Bool) {
        if let parentVC = parentVC {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "createNewItemVC") as! CreateNewItemVC
            self.createNewItemVC = vc
            parentVC.addChild(vc)
            parentVC.view.addSubview(vc.tableView)
            vc.didMove(toParent: parentVC)
            
            if forIngredients {
                vc.isForIngredients = true
            } else {
                vc.isForTags = true
            }
            
            vc.tableView.translatesAutoresizingMaskIntoConstraints = false
            
            vc.tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            vc.tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            vc.tableView.topAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            
            vc.tableView.heightAnchor.constraint(equalToConstant: 200).isActive = true
            
            vc.delegate = self as CreateNewItemDelegate
            delegate = vc
            delegate.searchTextChanged(text: "")
            
        }
    }
    
}

extension AdvancedSearchView: CreateNewItemDelegate {
    func itemCreated(item: Item) {}
    
    func searchCreated(search: NetworkSearch) {
        print("search created: \(search.text)")
        if let string = activeTextField?.text {
            if activeTextField == tagTF {
                activeTextField?.textColor = Colors.main
                activeTextField?.text = search.text
                activeTextField?.resignFirstResponder()
                
            } else {
                activeTextField?.text = string.updateSearchText(newItem: search.text)
            }
            
        }
        
    }
    
}
