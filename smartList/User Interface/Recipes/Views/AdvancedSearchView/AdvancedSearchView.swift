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
    
    
    @IBOutlet weak var caloriesSlider: UISlider!
    @IBOutlet weak var caloriesLabel: UILabel!
    @IBOutlet weak var readyInSlider: UISlider!
    @IBOutlet weak var readyInLabel: UILabel!
    @IBOutlet weak var ingredientsTF: UITextField!
    @IBOutlet weak var titleTF: UITextField!
    @IBOutlet weak var tagTF: UITextField!
    @IBOutlet weak var avoidIngsTF: UITextField!
    
    private var parentVC: UIViewController?
    private var delegate: SearchAssistantDelegate!
    private var createNewItemVC: CreateNewItemVC?
    private var activeTextField: UITextField?
    
    private let sliderMaxCalories: Float = 1000.0
    private let intervalSizeCalories = 100
    private let sliderMaxReadyIn: Float = 120.0
    private let intervalSizeReadyIn = 10
    
    weak var advancedSearchViewDelegate: AdvancedSearchViewDelegate!
    
    func setUI(vc: UIViewController) {
        advancedSearchViewDelegate = vc as? AdvancedSearchViewDelegate
        ingredientsTF.delegate = self
        tagTF.delegate = self
        avoidIngsTF.delegate = self
        self.parentVC = self.findViewController()
        
        ingredientsTF.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        tagTF.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        avoidIngsTF.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        
        readyInSlider.maximumValue = sliderMaxReadyIn
        readyInSlider.minimumValue = 0
        readyInSlider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        
        caloriesSlider.maximumValue = sliderMaxCalories
        caloriesSlider.minimumValue = 0
        caloriesSlider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
    }

    @IBAction func searchPressed(_ sender: Any) {
        self.findViewController()?.dismiss(animated: false, completion: nil)
        advancedSearchViewDelegate.searchesSent(searches: collectSearches())
        
    }
    
    @IBAction func infoButton(_ sender: Any) {
        
        let actionSheet = UIAlertController(title: nil, message: "Info for", preferredStyle: .actionSheet)
        actionSheet.addAction(.init(title: "Ingredients search", style: .default, handler: { (alert) in
            self.parentVC?.createAlertOkButton(title: "Info for ingredients search",
                                               body: "Searching for ingredients will find recipes that have all the ingredients that you have added. " +
                                               "Separate the ingredients you want to find with commas. An example query is:\n\n" +
                                               "'pasta, broccoli, peas'")
        }))
        actionSheet.addAction(.init(title: "Title search", style: .default, handler: { (alert) in
            self.parentVC?.createAlertOkButton(title: "Info for title search",
                                               body: "Searching for the title will match recipes that have the same text in the title. You do not need to worry about capitalization.")
        }))
        actionSheet.addAction(.init(title: "Tag/title search", style: .default, handler: { (alert) in
            self.parentVC?.createAlertOkButton(title: "Info for tag/title search",
                                               body: "Searching with a tag will help you find a recipe in a certain category. " +
                                               "For example, if you want a vegetarian recipe or an Italian recipe this would be the field to specify that.")
            
        }))
        actionSheet.addAction(.init(title: "Avoid ing search", style: .default, handler: { (alert) in
            self.parentVC?.createAlertOkButton(title: "Info for avoid ing search",
                                               body: "Searching with avoid ingredients will find recipes that do not have the ingredients in them. " +
                                               "For example, if you do not like mushrooms this is the field to specify that. An example query is:\n\n" +
                                               "'mushrooms, peanuts'")
        }))
        actionSheet.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            parentVC?.present(actionSheet, animated: true)
        } else {
            // do other stuff for iPad
            guard let viewRect = sender as? UIView else { return }
            if let presenter = actionSheet.popoverPresentationController {
                presenter.sourceView = viewRect
                presenter.sourceRect = viewRect.bounds
            }
            parentVC?.present(actionSheet, animated: true, completion: nil)
        }
    }

    
    @objc private func textFieldDidChange(textField: UITextField) {
        if let text = textField.text {
            delegate.searchTextChanged(text: text.getLastPartOfSearchForQuery())
            if textField == tagTF {
                if Network.shared.tags.map({$0.text.lowercased()}).contains(text.lowercased()) {
                    textField.textColor = Colors.main
                } else {
                    textField.textColor = .red
                }
            }
        }
    }
    
    @objc private func sliderValueChanged(sender: UISlider) {
        if sender == caloriesSlider {
            let value = Int(caloriesSlider.value)
            let calories = value.roundToInterval(interval: intervalSizeCalories)
            
            var display: String {
                if calories == 0 {
                    return "Any"
                } else {
                    return "< \(calories)"
                }
            }
            caloriesLabel.text = display
        } else if sender == readyInSlider {
            let value = Int(readyInSlider.value)
            let time = value.roundToInterval(interval: intervalSizeReadyIn) // get the time closest to each intervalSize block
            var display: String {
                if time == 0 {
                    return "Any"
                } else {
                    return time.getDisplayHoursAndMinutes()
                }
            }
            readyInLabel.text = display
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
        
        // Ready in
        let readyInValue = Int(readyInSlider.value).roundToInterval(interval: intervalSizeReadyIn)
        if readyInValue > 0 {
            let networkSearch = NetworkSearch(text: "Ready in \(readyInValue.getDisplayHoursAndMinutes())", type: .readyIn, associatedNumber: readyInValue)
            foundSearches.append(networkSearch)
        }
        
        // Calories
        let caloriesValue = Int(caloriesSlider.value).roundToInterval(interval: intervalSizeCalories)
        if caloriesValue > 0 {
            let networkSearch = NetworkSearch(text: "< \(caloriesValue) calories", type: .calories, associatedNumber: caloriesValue)
            foundSearches.append(networkSearch)
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
