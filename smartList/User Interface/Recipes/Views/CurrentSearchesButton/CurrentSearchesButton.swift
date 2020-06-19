//
//  CurrentSearchesButton.swift
//  smartList
//
//  Created by Steven Dito on 6/18/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit

class CurrentSearchesButton: UIView {
    
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var bottomLabel: UILabel!
    private var networkSearch: NetworkSearch?
    private var currSearchesView: CurrentSearchesView?
    
    func setUI(search: NetworkSearch, currSearchesView: CurrentSearchesView) {
        self.networkSearch = search
        self.currSearchesView = currSearchesView
        topLabel.text = search.text
        bottomLabel.text = search.type.toString()
        
        self.layer.cornerRadius = 8.0
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        self.addGestureRecognizer(gesture)
    }
    
    @objc private func viewTapped() {
        print("The view is being tapped")
        if let ns = networkSearch, let csv = currSearchesView {
            csv.delegate.buttonPressedToDeleteSearch(search: ns)
        }
    }
    
}
