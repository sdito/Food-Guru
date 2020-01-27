//
//  OutsideRecipesVC.swift
//  smartList
//
//  Created by Steven Dito on 12/19/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import UIKit
import SafariServices



class OutsideRecipesVC: UIViewController, SFSafariViewControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var puppyRecipes: [Recipe.Puppy]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    @IBAction func donePressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}

extension OutsideRecipesVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return puppyRecipes?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recipePuppyCell") as! RecipePuppyCell
        let recipe = puppyRecipes![indexPath.row]
        cell.setUI(recipe: recipe)
        cell.delegate = self
        return cell
    }
}


extension OutsideRecipesVC: RecipePuppyCellDelegate {
    func urlPressed(url: URL) {
        let vc = SFSafariViewController(url: url)
        vc.delegate = self
        present(vc, animated: true)
    }
}
