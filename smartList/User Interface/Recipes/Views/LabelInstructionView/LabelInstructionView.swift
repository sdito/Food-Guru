//
//  LabelInstructionView.swift
//  smartList
//
//  Created by Steven Dito on 10/1/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import UIKit

class LabelInstructionView: UIView {
    
    @IBOutlet weak var number: UILabel!
    @IBOutlet weak var instruction: UILabel!
    
    func setUI(num: Int, instr: String) {
        number.text = "\(num)."
        instruction.text = instr
    }
}
