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
    @IBOutlet weak var viewHeightRatio: NSLayoutConstraint!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var addItemsToListOutlet: UIButton!
    
    var db: Firestore!
    private var selectedDayButton: UIButton?
    private var secondarySelectedButton: UIButton?
    private var realm: Realm?
    private var mealPlanner = MealPlanner()
    private var shortDate: String? {
        didSet {
            handleShortDateChange()
        }
    }
    
    private var dateRecipes: [MealPlanner.RecipeTransfer] = []
    private var monthsNeededToAdd = 2
    
    // MARK: Override funcs
    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Firestore.firestore()
        realm = try? Realm()
        mealPlanner.delegate = self; scrollView.delegate = self; tableView.delegate = self; tableView.dataSource = self
        mealPlanner.readIfUserHasMealPlanner()
        
        self.createLoadingView()
        
        mealPlanner.getMealPlannerRecipes { (done) in
            self.dismiss(animated: false, completion: nil)
            if done == true {
                self.setUpInitialUI()
            }
        }
        iPadUiIfApplicable()
        
        SharedValues.shared.mealPlannerHomeVC = self
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if mealPlanner.recipeListener == nil {
            print("Need to create new listener")
            mealPlanner.listenForMealPlanRecipes()
        }
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        // To not have any cells still be highlited for no reason
        tableView.visibleCells.forEach({$0.isSelected = false})
        if SharedValues.shared.mealPlannerID == nil {
            
            if SharedValues.shared.groupID == nil {
                print("Creating individual meal planner")
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
                let dayEnding = sd.shortDateGetDateEnding()
                return "Add meal on \(sd.shortDateToDisplay())\(dayEnding)"
            } else {
                return nil
            }
        }
        
        let actionSheet = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        
        
        actionSheet.addAction(.init(title: "Add note", style: .default, handler: { (action) in
            print("Add note")
            guard let sd = self.shortDate else { return }
            let alert = UIAlertController(title: "Add note on \(sd.shortDateToDisplay())\(sd.shortDateGetDateEnding())", message: nil, preferredStyle: .alert)
            alert.addTextField { (txtField) in
                txtField.textColor = Colors.main
            }
            alert.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(.init(title: "Done", style: .default, handler: { (action) in
                guard let note = alert.textFields?.first?.text else { return }
                self.mealPlanner.addNoteToPlanner(shortDate: sd, note: note)
            }))
            self.present(alert, animated: true)
        }))
        
        
        actionSheet.addAction(.init(title: "Browse recipes", style: .default, handler: { (action) in
            self.performSegue(withIdentifier: "selectMealPlanRecipe", sender: (RecipeSelection.all, self.shortDate))
        }))
        actionSheet.addAction(.init(title: "Cookbook", style: .default, handler: { action in
            self.performSegue(withIdentifier: "selectMealPlanRecipe", sender: (RecipeSelection.cookbook, self.shortDate))
        }))
        actionSheet.addAction(.init(title: "Saved recipes", style: .default, handler: { action in
            self.performSegue(withIdentifier: "selectMealPlanRecipe", sender: (RecipeSelection.saved, self.shortDate))
        }))
        actionSheet.addAction(.init(title: "Add new recipe", style: .default, handler: { action in
            let sb = UIStoryboard(name: "Recipes", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "cRecipe") as! CreateRecipeVC
            vc.fromPlanner = (true, self.shortDate)
            self.navigationController?.pushViewController(vc, animated: true)
            vc.mealPlannerRecipeDelegate = self
        }))
        actionSheet.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            present(actionSheet, animated: true)
        } else {
            actionSheet.popoverPresentationController?.sourceView = addRecipeButtonOutlet
            actionSheet.popoverPresentationController?.sourceRect = addRecipeButtonOutlet.bounds
            present(actionSheet, animated: true, completion: nil)
        }
    }
    
    @IBAction func addItemsToList(_ sender: Any) {
        if dateRecipes.count >= 1, let sd = shortDate {
            let dontAskBeforeAdding = UserDefaults.standard.bool(forKey: "dontAskBeforeAddingToMP")
            
            if dontAskBeforeAdding == false {
                let end = sd.shortDateGetDateEnding()
                let actionSheet = UIAlertController(title: "Do you want to add items from \(sd.shortDateToDisplay())\(end) to your grocery list?", message: nil, preferredStyle: .actionSheet)
                actionSheet.addAction(.init(title: "Add items", style: .default, handler: { action in
                    print("Add items")
                    self.mealPlanner.addItemsToListFromCertainDay(shortDate: sd, calledFrom: self)
                }))
                actionSheet.addAction(.init(title: "Add items, dont ask before adding", style: .default, handler: { action in
                    print("Add items, dont ask before adding")
                    UserDefaults.standard.set(true, forKey: "dontAskBeforeAddingToMP")
                    self.mealPlanner.addItemsToListFromCertainDay(shortDate: sd, calledFrom: self)
                }))
                actionSheet.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
                
                if UIDevice.current.userInterfaceIdiom == .phone {
                    present(actionSheet, animated: true)
                } else {
                    if let presenter = actionSheet.popoverPresentationController {
                        presenter.sourceView = addItemsToListOutlet
                        presenter.sourceRect = addItemsToListOutlet.bounds
                    }
                    present(actionSheet, animated: true)
                }
            } else {
                // Just add everything here, by doing the action from Add Items from the action sheet without asking before
                mealPlanner.addItemsToListFromCertainDay(shortDate: sd, calledFrom: self)
            }
            
            
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
        
        // to have a gesture recognizer to allow user to swipe to get to the next or previous day
        let swipeGestureRecognizerLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipeSwiped))
        let swipeGestureRecognizerRight = UISwipeGestureRecognizer(target: self, action: #selector(swipeSwiped))
        swipeGestureRecognizerLeft.direction = UISwipeGestureRecognizer.Direction.left
        swipeGestureRecognizerRight.direction = UISwipeGestureRecognizer.Direction.right
        tableView.addGestureRecognizer(swipeGestureRecognizerRight)
        tableView.addGestureRecognizer(swipeGestureRecognizerLeft)
    }
    
    func updateUiIfApplicable() {
        // first need to get what the current day is
        let currentDate = Date()
        let calendar = Calendar.current
        
        // would need to check the current month and the previous month (could be the first of the month)
        let currentMonthYear = (calendar.component(.month, from: currentDate), calendar.component(.year, from: currentDate))
        let monthBeforeDate = calendar.date(byAdding: .month, value: -1, to: currentDate)!
        let previousMonthYear = (calendar.component(.month, from: monthBeforeDate), calendar.component(.year, from: monthBeforeDate))
        
        
        // then need to update the UI with the current day from those views
        for v in calendarStackView.subviews {
            if let calendarView = v as? CalendarView, let cvMonthYear =  calendarView.monthYear {
                if cvMonthYear == currentMonthYear || cvMonthYear == previousMonthYear {
                    // Need to (potentially) update the UI for this month's view
                    calendarView.potentiallyUpdateUI(with: currentDate, isPreviousMonth: cvMonthYear == previousMonthYear)
                } else {
                    // Don't need to update the UI for this month's view
                }
            }
        }
        
    }
    
    private func iPadUiIfApplicable() {
        if !SharedValues.shared.isPhone {
            selectedDayLabel.font = UIFont(name: "futura", size: 22)
            viewHeightRatio.isActive = false
            bottomView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.3).isActive = true
            
        }
    }
    
    @objc private func swipeSwiped(_ recognizer: UISwipeGestureRecognizer) {
        // left direction for next day, right direction for previous day
        // get the alpha of the button, and then find the next button incremented with the same alpha, if no such button exists take the next alpha with next of '1', reverse for previous
        if let currCalendarView = selectedDayButton?.findCalendarView() {
            
            if recognizer.direction == .left {
                // Next day
                var nextDayFound = false
                for d in currCalendarView.day {
                    if d.tag == selectedDayButton?.tag && d.titleLabel?.text == selectedDayButton?.titleLabel?.text.plusOne() {
                        d.backgroundColor = Colors.secondarySystemBackground
                        d.layer.borderColor = UIColor.clear.cgColor
                        selectedDay(button: d)
                        currCalendarView.buttonPressedHelper(sender: d)
                        nextDayFound = true
                        break
                    }
                }
                
                if nextDayFound == false {
                    // was the last day of the month, see if day '1' for the next alpha exists
                    for d in currCalendarView.day {
                        if d.tag == (selectedDayButton?.tag ?? -3) + 1 && d.titleLabel?.text == "1" {
                            selectedDay(button: d)
                            currCalendarView.buttonPressedHelper(sender: d)
                            break
                        }
                    }
                }
                
            } else if recognizer.direction == .right {
                // Previous day
                var prevDayFound = false
                for d in currCalendarView.day {
                    if d.tag == selectedDayButton?.tag && d.titleLabel?.text == selectedDayButton?.titleLabel?.text.minusOne() {
                        d.backgroundColor = Colors.secondarySystemBackground
                        d.layer.borderColor = UIColor.clear.cgColor
                        selectedDay(button: d)
                        currCalendarView.buttonPressedHelper(sender: d)
                        prevDayFound = true
                        break
                    }
                }
                
                if prevDayFound == false {
                    var lastButton: (button: UIButton, date: Int)?
                    print("Need to get last day of previous month")
                    for d in currCalendarView.day {
                        if d.tag == (selectedDayButton?.tag ?? -3) - 1 {
                            if let str = d.titleLabel?.text, let int = Int(str) {
                                if int > lastButton?.date ?? 0 {
                                    lastButton = (d, int)
                                }
                            }
                        }
                    }
                    
                    if let d = lastButton?.button {
                        selectedDay(button: d)
                        currCalendarView.buttonPressedHelper(sender: d)
                    }
                    
                }
            }
        }
        
        
        
    }
    
    func handleShortDateChange() {
        if let sd = shortDate, let monthRecipes = mealPlanner.mealPlanDict[sd.shortDateToMonthYear()] {
            print(sd, monthRecipes)
            let newRecipes = Array<MealPlanner.RecipeTransfer>(monthRecipes.filter({$0.date == sd})).sortNoteFirstAlphabetical()
            if dateRecipes != newRecipes {
                dateRecipes = newRecipes
                tableView.reloadData()
                UIView.transition(with: tableView, duration: 0.2, options: .transitionCrossDissolve, animations: self.tableView.reloadData)
            }
        } else {
            dateRecipes = []
            tableView.reloadData()
        }
        
        if dateRecipes.filter({$0.metadata != "note"}).count >= 1 {
            addItemsToListOutlet.setIsHidden(false, animated: true, duration: 0.15)
        } else {
            addItemsToListOutlet.setIsHidden(true, animated: true, duration: 0.15)
        }
        
    }
    
}


// MARK: MealPlanRecipeChangedDelegate
extension MealPlannerHomeVC: MealPlanDelegate {
    
    
    func mealPlannerCreated() {
        setUpInitialUI()
    }
    
    func recipesChanged(month: String) {
        
        handleShortDateChange()
        let previous = month.getPreviousMonth()
        let next = month.getNextMonth()
        print(previous, next)
        for calendarView in calendarStackView.subviews {
            guard let view = calendarView as? CalendarView else { continue }
            
            if let dateTuple = view.monthYear {
                let dateTupleFormatted = "\(dateTuple.0).\(dateTuple.1)"
                print(dateTupleFormatted, month, previous, next)
                if month == dateTupleFormatted || previous == dateTupleFormatted || next == dateTupleFormatted {
                    
                    print("Need to update UI for \(dateTupleFormatted)")
                    view.updateUI(recipes: mealPlanner.mealPlanDict)

                }
            }
        }
        
    }
    
    
}

// MARK: CreateRecipeForMealPlannerDelegate
extension MealPlannerHomeVC: CreateRecipeForMealPlannerDelegate {
    func recipeCreated(recipe: CookbookRecipe) {
        if let shortDate = shortDate {
            let mpcbr = MPCookbookRecipe()
            mpcbr.set(cookbookRecipe: recipe, date: shortDate)
            MealPlanner.addRecipeToPlanner(db: db, recipe: mpcbr, shortDate: shortDate, mealType: .none, previousID: nil)
        }
    }
}

// MARK: MealPlannerCellDelegate
extension MealPlannerHomeVC: MealPlannerCellDelegate {
    func cellSelected(recipe: MealPlanner.RecipeTransfer?, sender: UIView) {
        // Need to have a pop up or action sheet here for editing, deleting, shareing recipe (i.e. have pdf show up)
        
        if let recipe = recipe {
            var beginning: String {
                if recipe.metadata == "note" {
                    return "Note: "
                } else {
                    return "Recipe: "
                }
            }
            let actionSheet = UIAlertController(title: "\(beginning)\(recipe.name)", message: nil, preferredStyle: .actionSheet)
        
            actionSheet.addAction(.init(title: "Copy to another date", style: .default, handler: { action in
                self.createDatePickerView(delegateVC: self, recipe: recipe, copyRecipe: true)
            }))
            actionSheet.addAction(.init(title: "Change date", style: .default, handler: { action in
                print("Need to offer date picker to change the date here")
                self.createDatePickerView(delegateVC: self, recipe: recipe, copyRecipe: false)
                
            }))
            var recipeOrNote: String {
                if recipe.metadata == "note" {
                    return "note"
                } else {
                    return "recipe"
                }
            }
            actionSheet.addAction(.init(title: "Delete \(recipeOrNote)", style: .destructive, handler: { action in
                self.mealPlanner.removeRecipeFromPlanner(recipe: recipe)
            }))
            actionSheet.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
            
            if UIDevice.current.userInterfaceIdiom == .phone {
                present(actionSheet, animated: true)
            } else {
                actionSheet.popoverPresentationController?.sourceView = sender
                actionSheet.popoverPresentationController?.sourceRect = sender.bounds
                present(actionSheet, animated: true, completion: nil)
            }
//            present(actionSheet, animated: true)
        }
        
    }
}

// MARK: SelectDateViewDelegate
extension MealPlannerHomeVC: SelectDateViewDelegate {
    func dateSelected(date: Date, recipe: MealPlanner.RecipeTransfer?, copyRecipe: Bool) {
        
        if let recipe = recipe {
            mealPlanner.changeDateForRecipe(recipe: recipe, newDate: date, copyRecipe: copyRecipe)
        }
        
        
    }
    
}

// MARK: CalendarViewDelegate
extension MealPlannerHomeVC: CalendarViewDelegate {
    func dateButtonSelected(month: Month, day: Int, year: Int, buttonTag: Int) {
        let newDate = "\(month.int).\(day).\(year)"
        print(newDate)
        if shortDate != newDate {
            shortDate = newDate
            // to reset the value of the other button that was in 'selected' mode
            secondarySelectedButton?.backgroundColor = Colors.systemBackground
            secondarySelectedButton?.layer.borderColor = Colors.label.cgColor
            
            NotificationCenter.default.post(.init(name: .dayButtonSelectedFromCalendar, object: nil, userInfo: ["shortDate": shortDate as Any, "tagFromNoti": buttonTag]))
            
                if selectedDayLabel.text != "Date" {
                    UIView.animate(withDuration: 0.1, animations: {
                        self.selectedDayLabel.alpha = 0.55
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
            
            selectedDayButton?.layer.borderColor = Colors.label.cgColor
            selectedDayButton?.backgroundColor = Colors.systemBackground
            
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
        cell.setUI(recipe: recipe)
        cell.delegate = self
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let mealPlanRecipe = dateRecipes[indexPath.row]
        
        guard mealPlanRecipe.metadata != "note" else {
            tableView.deselectRow(at: indexPath, animated: false)
            return
        }
        
        let mealPlanRecipeID = mealPlanRecipe.id
        let sb = UIStoryboard(name: "Recipes", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "recipeDetailVC") as! RecipeDetailVC
        
        if let realmMealPlanRecipe = realm?.object(ofType: MPCookbookRecipe.self, forPrimaryKey: mealPlanRecipeID) {
            
            print("Already have recipe downloaded, need to present from Realm")
            vc.cookbookRecipe = realmMealPlanRecipe.toCookbookRecipe()
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            // need to download the recipe, then write it to realm, then push the VC
            print("Need to download the recipe from Firebase")
            self.createLoadingView()
            if let id = SharedValues.shared.mealPlannerID {
                let refernece = db.collection("mealPlanners").document(id).collection("recipes").document(mealPlanRecipeID)
                refernece.getDocument { (documentSnapshot, error) in
                    guard let doc = documentSnapshot else { return }
                    let recipe = doc.getMPCookbookRecipe()
                    recipe.write()
                    vc.cookbookRecipe = recipe
                    self.dismiss(animated: false) {
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                    
                }
            } else {
                self.dismiss(animated: false, completion: nil)
            }
        }
        
        
        
    }
    
    
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



