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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let view = Bundle.main.loadNibNamed("CalendarView", owner: nil, options: nil)!.first as! CalendarView
        let view2 = Bundle.main.loadNibNamed("CalendarView", owner: nil, options: nil)!.first as! CalendarView
        
        calendarStackView.addArrangedSubview(view)
        calendarStackView.addArrangedSubview(view2)
        
        view.heightAnchor.constraint(equalTo: scrollView.heightAnchor, multiplier: 1.0).isActive = true
        view.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 1.0).isActive = true
        
        view.setUI(monthsInFuture: 0)
        view2.setUI(monthsInFuture: 1)
        
        
        
        baseView.removeFromSuperview()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        let calendar = Calendar.autoupdatingCurrent
        
        print(calendar.monthSymbols)
        print(calendar.weekdaySymbols)
//        print(calendar.range(of: .day, in: .month, for: Date()))
        
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        
    }

}
