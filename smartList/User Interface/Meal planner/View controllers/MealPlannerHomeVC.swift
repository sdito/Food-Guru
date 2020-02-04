//
//  MealPlannerHomeVC.swift
//  smartList
//
//  Created by Steven Dito on 1/26/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit
import Foundation


class MealPlannerHomeVC: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var calendarStackView: UIStackView!
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var selectedDayLabel: UILabel!
    
    private var shortDate: String?
    private var monthsNeededToAdd = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        let view = Bundle.main.loadNibNamed("CalendarView", owner: nil, options: nil)!.first as! CalendarView
        let view2 = Bundle.main.loadNibNamed("CalendarView", owner: nil, options: nil)!.first as! CalendarView
        let view3 = Bundle.main.loadNibNamed("CalendarView", owner: nil, options: nil)!.first as! CalendarView
        
        calendarStackView.addArrangedSubview(view)
        calendarStackView.addArrangedSubview(view2)
        calendarStackView.addArrangedSubview(view3)
        
        view.delegate = self
        view2.delegate = self
        view3.delegate = self
        
        view2.heightAnchor.constraint(equalTo: scrollView.heightAnchor, multiplier: 1.0).isActive = true
        view2.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 1.0).isActive = true
        
        view.setUI(monthsInFuture: -1)
        view2.setUI(monthsInFuture: 0)
        view3.setUI(monthsInFuture: 1)
        
        baseView.removeFromSuperview()
        
        DispatchQueue.main.async {
            self.scrollView.setContentOffset(CGPoint(x: self.view.bounds.width, y: 0), animated: false)
        }
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addRecipe" {
            let destVC = segue.destination as! AddRecipeToMealPlannerVC
            destVC.shortDate = shortDate
        }
    }
    
    // MARK: IBAction funcs
    @IBAction func addRecipePressed(_ sender: Any) {
        print("add recipe pressed")
        performSegue(withIdentifier: "addRecipe", sender: shortDate)
        
    }
    
}



// MARK: CalendarViewDelegate
extension MealPlannerHomeVC: CalendarViewDelegate {
    func dateButtonSelected(month: Month, day: Int, year: Int) {
        shortDate = "\(month.int).\(day).\(year)"
        // use short date for database
        print(shortDate ?? "")
        selectedDayLabel.text = "\(month.description) \(day)"
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
            view.setUI(monthsInFuture: monthsNeededToAdd)
            view.delegate = self
            calendarStackView.addArrangedSubview(view)
            monthsNeededToAdd += 1
        } else if size * count - bounds >= size*2 && calendarStackView.subviews.count > 2  {
            calendarStackView.subviews.last?.removeFromSuperview()
            monthsNeededToAdd -= 1
        }
        
        
    }
}
