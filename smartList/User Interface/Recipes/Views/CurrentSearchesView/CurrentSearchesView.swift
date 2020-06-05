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
}



class CurrentSearchesView: UIView {
    
    weak var delegate: CurrentSearchesViewDelegate!
    
    @IBOutlet weak var stackView: UIStackView!
    
    func setUI(searches: [NetworkSearch]) {
        stackView.subviews.forEach { (v) in
            if type(of: v) == UIButton.self || type(of: v) == UILabel.self {
                v.removeFromSuperview()
            }
        }
        
        if !searches.isEmpty {
            for search in searches {
                let b = UIButton()
                let buttonText: String = search.text
                b.tag = search.type.toTagRepresentation()
                b.setTitle(buttonText, for: .normal)
                b.contentEdgeInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
                b.titleLabel?.font = UIFont(name: "futura", size: 13)
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
        } else {
            stackView.addArrangedSubview(UILabel())
        }
        
    }
    
    @objc func buttonAction(sender: UIButton) {
        let text = sender.titleLabel?.text
        let tag = sender.tag
        delegate.buttonPressedToDeleteSearch(search: NetworkSearch(text: text!, type: NetworkSearch.NetworkSearchType.toNetworkSearchTypeRepresentation(tag: tag)))
    }

}
