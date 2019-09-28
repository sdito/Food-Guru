//
//  SelectRecipeTypeVC.swift
//  smartList
//
//  Created by Steven Dito on 8/26/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import UIKit



class SelectRecipeTypeVC: UIViewController {
    
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var secondTopView: UIView!
    
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var cuisineLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    
    private var cuisineType: String?
    private var recipeType: Set<String> = [] {
        didSet {
            descriptionLabel.text = self.recipeType.sorted().joined(separator: ", ")
        }
    }
    
    private var allTypes: [String] = RecipeType.allItems {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillDisappear(animated)
        searchBar.resignFirstResponder()
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        pickerView.delegate = self
        pickerView.dataSource = self
        searchBar.setTextProperties()
        topView.setGradientBackground(colorOne: Colors.main, colorTwo: Colors.mainGradient)
        secondTopView.setGradientBackground(colorOne: Colors.main, colorTwo: Colors.mainGradient)
    }
    
    @IBAction func exit(_ sender: Any) {
        // collect the RecipeType and CuisineType from storyboard here before removeFromSuperview -- should be in enum type
        
        if cuisineType != nil && recipeType.isEmpty == false && cuisineType != " - " {
            //delegate = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "cRecipe") as! CreateRecipeVC
            //delegate.transferValues(cuisine: cuisineType ?? "", description: recipeType.sorted())
            
            //self.dismiss(animated: true, completion: nil)
            SharedValues.shared.cuisineType = cuisineType
            SharedValues.shared.recipeType = recipeType.sorted()
            
            back()
            
        } else {
            let alrt = UIAlertController(title: "Incomplete data", message: "Please make sure both cuisine type and reciple type are filled out", preferredStyle: .alert)
            alrt.addAction(.init(title: "Ok", style: .default, handler: nil))
            alrt.addAction(.init(title: "Exit", style: .destructive, handler: {(alert: UIAlertAction!) in self.back()}))
            present(alrt, animated: true)
        }
        
    }
    
//    struct popUp {
//        static let popOverVC = UIStoryboard(name: "main", bundle: nil).instantiateViewController(withIdentifier: "recipeType") as! SelectRecipeTypeVC
//    }
    
    private func back() {
        //let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "cRecipe") as! CreateRecipeVC
        //present(vc, animated: false, completion: nil)
        navigationController?.popViewController(animated: true)
    }

}



extension SelectRecipeTypeVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        allTypes = RecipeType.allItems
        allTypes = allTypes.filter({ (type) -> Bool in
            type.starts(with: searchBar.text!)
        })
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

extension SelectRecipeTypeVC: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return CuisineType.allItems.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return CuisineType.allItems[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row == 0 {
            cuisineLabel.text = "Select cuisine type"
            
        } else {
            cuisineLabel.text = CuisineType.allItems[row]
            
        }
        cuisineType = CuisineType.allItems[row]
    }
}

extension SelectRecipeTypeVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allTypes.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recipeType") as! RecipeTypeCell
        let type = allTypes[indexPath.row]
        cell.setUI(type: type, set: recipeType)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let item = allTypes[indexPath.row]
        if recipeType.contains(item) == false {
            recipeType.insert(allTypes[indexPath.row])
        } else {
            recipeType.remove(allTypes[indexPath.row])
        }
        
        searchBar.text = ""
        allTypes = RecipeType.allItems
    }
    
    
}
