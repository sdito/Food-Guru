//
//  InstructionView.swift
//  smartList
//
//  Created by Steven Dito on 8/29/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import UIKit

class InstructionView: UIView {

    @IBOutlet weak var tv: UITextView!
    @IBOutlet weak var button: UIButton!
    
    func setUI(num: String) {
        tv.border()
        button.setTitle("\(num)", for: .normal)
        self.alpha = 0.4
        
    }
}
