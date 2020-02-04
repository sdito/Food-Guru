//
//  MealPlannerHomeVC.swift
//  smartList
//
//  Created by Steven Dito on 1/26/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit
import Foundation


class MealPlannerHomeVC: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var calendarStackView: UIStackView!
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var selectedDayLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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

}



// MARK: CalendarViewDelegate
extension MealPlannerHomeVC: CalendarViewDelegate {
    func dateButtonSelected(month: Month, day: Int, year: Int) {
        let shortDate = "\(month.int).\(day).\(year)"
        print(shortDate)
        selectedDayLabel.text = "\(month.description) \(day)"
        #warning("need to use these values to pull the recipes and set the UI")
    }
    
    
}
