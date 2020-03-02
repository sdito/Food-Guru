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


class MealPlannerHomeVC: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var calendarStackView: UIStackView!
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var selectedDayLabel: UILabel!
    @IBOutlet weak var addRecipeButtonOutlet: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var db: Firestore!
    private var selectedDayButton: UIButton?
    private var secondarySelectedButton: UIButton?
    private var realm: Realm?
    private var mealPlanner = MealPlanner()
    private var shortDate: String? {
        didSet {
            //let newRecipes = mealPlanner.recipes?.filter({$0.date == self.shortDate})
//            let newRecipes = Array<MealPlanner.RecipeTransfer>(mealPlanner.mealPlanDict[self.shortDate!.shortDateToMonthYear()]?.filter({$0.date == self.shortDate}))
            if let monthRecipes = mealPlanner.mealPlanDict[self.shortDate!.shortDateToMonthYear()] {
                
                let newRecipes = Array<MealPlanner.RecipeTransfer>(monthRecipes.filter({$0.date == self.shortDate!}))
                
                if dateRecipes != newRecipes {
                    dateRecipes = newRecipes
                    UIView.transition(with: tableView, duration: 0.4, options: .transitionFlipFromTop, animations: self.tableView.reloadData)
                }
            }
            
            
            
        }
    }
    
    private var dateRecipes: [MealPlanner.RecipeTransfer] = []
    private var monthsNeededToAdd = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Firestore.firestore()
        realm = try? Realm()
        scrollView.delegate = self; tableView.delegate = self; tableView.dataSource = self
        mealPlanner.readIfUserHasMealPlanner()
        
        mealPlanner.listenForMealPlannerRecipes { (done) in
            if done == true {
                self.setUpInitialUI()
            }
        }
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
        
        if SharedValues.shared.mealPlannerID == nil {
            
            if SharedValues.shared.groupID == nil {
                
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
    
    // MARK: Funcs
    private func setUpInitialUI() {
        let view = Bundle.main.loadNibNamed("CalendarView", owner: nil, options: nil)!.first as! CalendarView
        let view2 = Bundle.main.loadNibNamed("CalendarView", owner: nil, options: nil)!.first as! CalendarView
        let view3 = Bundle.main.loadNibNamed("CalendarView", owner: nil, options: nil)!.first as! CalendarView
        
        calendarStackView.addArrangedSubview(view)
        calendarStackView.addArrangedSubview(view2)
        calendarStackView.addArrangedSubview(view3)
        
        view.delegate = self; view2.delegate = self; view3.delegate = self
        
        view2.heightAnchor.constraint(equalTo: scrollView.heightAnchor, multiplier: 1.0).isActive = true
        view2.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 1.0).isActive = true
        
        view.setUI(monthsInFuture: -1, recipes: mealPlanner.mealPlanDict)
        view2.setUI(monthsInFuture: 0, recipes: mealPlanner.mealPlanDict)
        view3.setUI(monthsInFuture: 1, recipes: mealPlanner.mealPlanDict)
        
        baseView.removeFromSuperview()
        
        DispatchQueue.main.async {
            self.scrollView.setContentOffset(CGPoint(x: self.view.bounds.width, y: 0), animated: false)
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
            vc.mealPlannerRecipeDelegate = self
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

// MARK: CreateRecipeForMealPlannerDelegate
extension MealPlannerHomeVC: CreateRecipeForMealPlannerDelegate {
    func recipeCreated(recipe: CookbookRecipe) {
        
        if let shortDate = shortDate {
            let mpcbr = MPCookbookRecipe()
            mpcbr.set(cookbookRecipe: recipe, date: shortDate)
            mealPlanner.addRecipeToPlanner(recipe: mpcbr, shortDate: shortDate, mealType: .none)
        }
        
    }
}


// MARK: CalendarViewDelegate
extension MealPlannerHomeVC: CalendarViewDelegate {
    func dateButtonSelected(month: Month, day: Int, year: Int, buttonTag: Int) {
        let newDate = "\(month.int).\(day).\(year)"
        
        if shortDate != newDate {
            shortDate = newDate
            // to reset the value of the other button that was in 'selected' mode
            secondarySelectedButton?.backgroundColor = Colors.systemBackground
            secondarySelectedButton?.layer.borderColor = Colors.label.cgColor
            NotificationCenter.default.post(.init(name: .dayButtonSelectedFromCalendar, object: nil, userInfo: ["shortDate": shortDate as Any, "tagFromNoti": buttonTag]))
            
                if selectedDayLabel.text != "Date" {
                    UIView.animate(withDuration: 0.1, animations: {
                        self.selectedDayLabel.alpha = 0.3
                    }) { (complete) in
                        self.selectedDayLabel.text = "\(month.description) \(day)"
                        UIView.animate(withDuration: 0.1) {
                            self.selectedDayLabel.alpha = 1.0
                        }
                    }
                } else {
                    selectedDayLabel.text = "\(month.description) \(day)"
                }
        }
    }
    
    func selectedDay(button: UIButton) {
        if selectedDayButton != button {
            selectedDayButton?.backgroundColor = Colors.systemBackground
            selectedDayButton?.layer.borderColor = Colors.label.cgColor
            selectedDayButton = button
            
        }
        
    }
    
    func associatedToSelectedDay(button: UIButton) {
        
        UIView.animate(withDuration: 0.2) {
            button.backgroundColor = Colors.secondarySystemBackground
            button.layer.borderColor = UIColor.clear.cgColor
            
        }
        // UI resetting for secondarySelectionButton happens before notification is posted in dateButtonSelected
        secondarySelectedButton = button
        
    }
    
    
}

// MARK: Table view
extension MealPlannerHomeVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dateRecipes.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mealPlannerCell") as! MealPlannerCell
        let recipe = dateRecipes[indexPath.row]
        cell.setUI(recipeName: recipe.name)
        return cell
    }
    
    #warning("need to re-implement")
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.cellForRow(at: indexPath)?.isSelected = false
//        let recipe = dateRecipes[indexPath.row].toCookbookRecipe()
//        let sb = UIStoryboard(name: "Recipes", bundle: nil)
//        let vc = sb.instantiateViewController(withIdentifier: "recipeDetailVC") as! RecipeDetailVC
//        vc.cookbookRecipe = recipe
//        self.navigationController?.pushViewController(vc, animated: true)
//
//    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }
}


// MARK: Scroll view
extension MealPlannerHomeVC: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if scrollView != tableView {
            let bounds = scrollView.bounds.minX
            let size = scrollView.frame.width
            let count = CGFloat(calendarStackView.subviews.count - 1)
            
            if bounds == size * count {
                let view = Bundle.main.loadNibNamed("CalendarView", owner: nil, options: nil)?.first as! CalendarView
                view.setUI(monthsInFuture: monthsNeededToAdd, recipes: mealPlanner.mealPlanDict)
                view.delegate = self
                calendarStackView.addArrangedSubview(view)
                monthsNeededToAdd += 1
            } else if size * count - bounds >= size*2 && calendarStackView.subviews.count > 2  {
                calendarStackView.subviews.last?.removeFromSuperview()
                monthsNeededToAdd -= 1
            }
            
            
            
        }
    }
    
}
