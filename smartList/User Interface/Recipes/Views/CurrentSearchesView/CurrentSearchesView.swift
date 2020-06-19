//
//  CurrentSearchesView.swift
//  smartList
//
//  Created by Steven Dito on 10/24/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import UIKit



protocol CurrentSearchesViewDelegate: class {
    func buttonPressedToDeleteSearch(search: NetworkSearch)
    func clearAllSearches()
}



class CurrentSearchesView: UIView {
    
    weak var delegate: CurrentSearchesViewDelegate!
    
    @IBOutlet weak var stackView: UIStackView!
    
    func setUI(searches: [NetworkSearch], viewController: UIViewController) {
        stackView.subviews.forEach { (v) in
            if type(of: v) == UIButton.self || type(of: v) == UILabel.self || type(of: v) == CurrentSearchesButton.self {
                v.removeFromSuperview()
            }
        }
        
        if !searches.isEmpty {
            for search in searches {
                let currentSearchButton = Bundle.main.loadNibNamed("CurrentSearchesButton", owner: nil, options: nil)?.first as! CurrentSearchesButton
                currentSearchButton.setUI(search: search, currSearchesView: self)
                //b.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
                stackView.addArrangedSubview(currentSearchButton)
            }
            
            if searches.count >= 2 {
                // Add a clear all button
                let b = UIButton()
                b.clearAllCurrentSearchesStyle()
                b.addTarget(self, action: #selector(clear), for: .touchUpInside)
                stackView.insertArrangedSubview(b, at: 1)
            }
            
        } else {
            stackView.addArrangedSubview(UILabel())
        }
        
    }
    
    @objc func clear() {
        delegate.clearAllSearches()
    }
    
    @objc func buttonAction(sender: UIButton) {
        let text = sender.titleLabel?.text
        let tag = sender.tag
        delegate.buttonPressedToDeleteSearch(search: NetworkSearch(text: text!, type: NetworkSearch.NetworkSearchType.toNetworkSearchTypeRepresentation(tag: tag)))
    }

}
