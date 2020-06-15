//
//  NoConnectionView.swift
//  smartList
//
//  Created by Steven Dito on 6/11/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit



protocol NoConnectionViewDelegate: class {
    func tryAgain()
}



class NoConnectionView: UIView {
    
    weak var delegate: NoConnectionViewDelegate!

    @IBAction func tryAgainPressed(_ sender: Any) {
        delegate.tryAgain()
    }
    
    
    
    
    static func show(vc: UIViewController) -> NoConnectionView {
        let noConnectionView = Bundle.main.loadNibNamed("NoConnectionView", owner: nil, options: nil)?.first as! NoConnectionView
        noConnectionView.delegate = vc as? NoConnectionViewDelegate
        noConnectionView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(noConnectionView)
        
        noConnectionView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor).isActive = true
        noConnectionView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor).isActive = true
        
        noConnectionView.layoutIfNeeded()
        noConnectionView.shadowAndRounded(cornerRadius: 15.0, border: false)
        return noConnectionView
    }
    
    
    
    
}
