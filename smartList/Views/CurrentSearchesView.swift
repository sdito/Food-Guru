//
//  CurrentSearchesView.swift
//  smartList
//
//  Created by Steven Dito on 10/24/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import UIKit

class CurrentSearchesView: UIView {

    @IBOutlet weak var stackView: UIStackView!
    
    func setUI(searches: [String]) {
        for search in searches {
            let b = UIButton()
            b.setTitle(search, for: .normal)
            b.setTitleColor(Colors.main, for: .normal)
            b.setGradientBackground(colorOne: .darkGray, colorTwo: .gray)
            stackView.insertArrangedSubview(b, at: stackView.subviews.count)
        }
    }

}
