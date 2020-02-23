//
//  MealPlannerHomeVC.swift
//  smartList
//
//  Created by Steven Dito on 1/26/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit
import Foundation
import FirebaseFirestore
import RealmSwift

#warning("need to address issue of the UI for the current day not resetting when app is kept in memory")

class MealPlannerHomeVC: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var calendarStackView: UIStackView!
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var selectedDayLabel: UILabel!
    @IBOutlet weak var addRecipeButtonOutlet: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var db: Firestore!
    private var realm: Realm?
    private var mealPlanner = MealPlanner()
    private var shortDate: String?
    private var monthsNeededToAdd = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Firestore.firestore()
        realm = try? Realm()
        scrollView.delegate = self; tableView.delegate = self; tableView.dataSource = self
        
        
        let view = Bundle.main.loadNibNamed("CalendarView", owner: nil, options: nil)!.first as! CalendarView
        let view2 = Bundle.main.loadNibNamed("CalendarView", owner: nil, options: nil)!.first as! CalendarView
        let view3 = Bundle.main.loadNibNamed("CalendarView", owner: nil, options: nil)!.first as! CalendarView
        
        calendarStackView.addArrangedSubview(view)
        calendarStackView.addArrangedSubview(view2)
        calendarStackView.addArrangedSubview(view3)
        
        view.delegate = self; view2.delegate = self; view3.delegate = self
        
        view2.heightAnchor.constraint(equalTo: scrollView.heightAnchor, multiplier: 1.0).isActive = true
        view2.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 1.0).isActive = true
        
        
        mealPlanner.getMealPlannerRecipes()
        
        view.setUI(monthsInFuture: -1, recipes: mealPlanner.recipes)
        view2.setUI(monthsInFuture: 0, recipes: mealPlanner.recipes)
        view3.setUI(monthsInFuture: 1, recipes: mealPlanner.recipes)
        
        baseView.removeFromSuperview()
        
        DispatchQueue.main.async {
            self.scrollView.setContentOffset(CGPoint(x: self.view.bounds.width, y: 0), animated: false)
        }
        mealPlanner.readIfUserHasMealPlanner()
        mealPlanner.listenForNewRecipesAddedToMealPlannerToWriteToRealm()
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
        
        if SharedValues.shared.mealPlannerID == nil {
            
            if SharedValues.shared.groupID == nil {
                #warning("need to initialize new meal planner with individual here")
                
                
                mealPlanner.createIndividualMealPlanner()
            } else {
                print("Creating group meal planner automatically")
                mealPlanner.createGroupMealPlanner()
            }
            
        } else {
            print("Already has meal planner")
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "selectMealPlanRecipe" {
            let destVC = segue.destination as! SelectMealPlanRecipeVC
            destVC.recipeSelection = sender as! (RecipeSelection, String?)
            destVC.mealPlanner = mealPlanner
        }
    }
    
    
    // MARK: IBAction funcs
    @IBAction func addRecipePressed(_ sender: Any) {
        
        var title: String? {
            if let sd = shortDate {
                return "Add meal on \(sd.shortDateToDisplay()) to planner"
            } else {
                return nil
            }
        }
        
        let actionSheet = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(.init(title: "Add new recipe", style: .default, handler: { action in
            let sb = UIStoryboard(name: "Recipes", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "cRecipe") as! CreateRecipeVC
            vc.fromPlanner = (true, self.shortDate)
            self.navigationController?.pushViewController(vc, animated: true)
            #warning("need to implement the adding of the recipe once its created")
        }))
        actionSheet.addAction(.init(title: "Cookbook", style: .default, handler: { action in
            self.performSegue(withIdentifier: "selectMealPlanRecipe", sender: (RecipeSelection.cookbook, self.shortDate))
        }))
        actionSheet.addAction(.init(title: "Saved recipes", style: .default, handler: { action in
            self.performSegue(withIdentifier: "selectMealPlanRecipe", sender: (RecipeSelection.saved, self.shortDate))
        }))
        actionSheet.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            present(actionSheet, animated: true)
        } else {
            actionSheet.popoverPresentationController?.sourceView = self.view
            actionSheet.popoverPresentationController?.sourceRect = addRecipeButtonOutlet.frame
            present(actionSheet, animated: true, completion: nil)
        }
    }
}



// MARK: CalendarViewDelegate
extension MealPlannerHomeVC: CalendarViewDelegate {
    func dateButtonSelected(month: Month, day: Int, year: Int) {
        shortDate = "\(month.int).\(day).\(year)"
        // use short date for database, load the associated recipes into the table view here
        print(shortDate ?? "")
        selectedDayLabel.text = "\(month.description) \(day)"
    }
    
}

extension MealPlannerHomeVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = "\(indexPath.row)"
        return cell
    }
}


// MARK: Scroll view
extension MealPlannerHomeVC: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let bounds = scrollView.bounds.minX
        let size = scrollView.frame.width
        let count = CGFloat(calendarStackView.subviews.count - 1)
        
        if bounds == size * count {
            let view = Bundle.main.loadNibNamed("CalendarView", owner: nil, options: nil)?.first as! CalendarView
            view.setUI(monthsInFuture: monthsNeededToAdd, recipes: mealPlanner.recipes)
            view.delegate = self
            calendarStackView.addArrangedSubview(view)
            monthsNeededToAdd += 1
        } else if size * count - bounds >= size*2 && calendarStackView.subviews.count > 2  {
            calendarStackView.subviews.last?.removeFromSuperview()
            monthsNeededToAdd -= 1
        }
        
        
    }
}
