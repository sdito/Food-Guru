//
//  CurrentSearchesView.swift
//  smartList
//
//  Created by Steven Dito on 10/24/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import UIKit


#warning("do i need class here idk")
protocol CurrentSearchesViewDelegate: class {
    func buttonPressedToDeleteSearch(name: String)
}



class CurrentSearchesView: UIView {
    
    weak var delegate: CurrentSearchesViewDelegate!
    
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
            //b.setTitleColor(Colors.main, for: .normal)
            b.titleLabel?.font = UIFont(name: "futura", size: 15)
            b.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
            b.layer.cornerRadius = 5
            if #available(iOS 13.0, *) {
                b.backgroundColor = .systemGray6
                b.setTitleColor(.systemGray, for: .normal)
            } else {
                b.backgroundColor = .lightGray
                b.setTitleColor(Colors.main, for: .normal)
            }
            b.clipsToBounds = true

            stackView.insertArrangedSubview(b, at: stackView.subviews.count)
            
        }
    }
    @objc func buttonAction(sender: UIButton) {
        print(sender.titleLabel?.text as Any)
        if let text = sender.titleLabel?.text {
            delegate.buttonPressedToDeleteSearch(name: text)
        }
        
    }

}
