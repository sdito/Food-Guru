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
        stackView.subviews.forEach { (v) in
            if type(of: v) == UIButton.self {
                v.removeFromSuperview()
            }
        }
        for search in searches {
            let b = UIButton()
            b.setTitle(search, for: .normal)
            b.setTitleColor(Colors.main, for: .normal)
            b.titleLabel?.font = UIFont(name: "futura", size: 15)
            b.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
            //b.setGradientBackground(colorOne: .gray, colorTwo: .darkGray)
            //b.titleLabel?.setGradientBackground(colorOne: .gray, colorTwo: .darkGray)
            b.layer.cornerRadius = 5
            b.clipsToBounds = true
            
            stackView.insertArrangedSubview(b, at: stackView.subviews.count)
        }
    }
    @objc func buttonAction(sender: UIButton) {
        print(sender.titleLabel?.text)
    }

}
