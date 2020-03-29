//
//  TabVC.swift
//  smartList
//
//  Created by Steven Dito on 9/5/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import UIKit
import FirebaseFirestore
import StoreKit
import RealmSwift
import FirebaseAuth



class TabVC: UITabBarController {
    
    var db: Firestore!

    override func viewDidLoad() {
        super.viewDidLoad()
        let listsTab = UIStoryboard(name: "Lists", bundle: nil).instantiateViewController(withIdentifier: "ListsTab")
        let recipesTab = UIStoryboard(name: "Recipes", bundle: nil).instantiateViewController(withIdentifier: "RecipesTab")
        let storageTab = UIStoryboard(name: "Storage", bundle: nil).instantiateViewController(withIdentifier: "StorageTab")
        let mealPlannerTab = UIStoryboard(name: "MealPlanner", bundle: nil).instantiateViewController(withIdentifier: "MealPlannerTab")
        let settingsTab = UIStoryboard(name: "Settings", bundle: nil).instantiateViewController(withIdentifier: "SettingsTab")
        
        self.setViewControllers([listsTab, recipesTab, storageTab, mealPlannerTab, settingsTab], animated: false)
        
        db = Firestore.firestore()
        User.writeNewUserDocumentIfApplicable(db: db)
        User.setAndPersistGroupDataInSharedValues(db: db)

        let defaults = UserDefaults.standard
        let numTimesRan = defaults.integer(forKey: "timesOpened")
        
        if numTimesRan < 2 {
            // Have a small pop up to alert the user that they can view the tutioral, center that view in the display and present it after two seconds
            let view = Bundle.main.loadNibNamed("SuggestTutorialView", owner: nil, options: nil)?.first as! SuggestTutorialView
            let width = view.bounds.width
            view.frame = CGRect(x: 0.0 - width, y: 37.5, width: width, height: view.bounds.height)
            view.border(cornerRadius: 5.0)
            self.view.addSubview(view)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                UIView.animate(withDuration: 0.3, animations: {
                    view.frame = CGRect(x: UIScreen.main.bounds.width/2 - width/2, y: 37.5, width: width, height: view.bounds.height)
                })
            }
        }
        
        if numTimesRan == 8 {
            SKStoreReviewController.requestReview()
            
        }
        print(numTimesRan)
        defaults.set(numTimesRan + 1, forKey: "timesOpened")
        
        
        
        
    }
    
}

