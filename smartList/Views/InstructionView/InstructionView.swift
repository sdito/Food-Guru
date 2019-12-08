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
    
    
    override func awakeFromNib() {
        tv.setUpDoneToolbar(action: #selector(doneAction), style: .done)
    }
    
    @objc func doneAction() {
        self.tv.resignFirstResponder()
    }
    
    class func getInstructions(stack: UIStackView) -> [String] {
        var instructions: [String] = []
        for view in stack.subviews {
            if type(of: view) == InstructionView.self {
                if let instruction = (view as! InstructionView).tv.text {
                    instructions.append(instruction)
                }
            }
        }
        instructions = instructions.filter({$0 != ""})
        return instructions
    }
    
    func setUI(num: String) {
        tv.border(cornerRadius: 5.0)
        button.setTitle("\(num)", for: .normal)
        self.alpha = 0.4
        
    }
}

//
//extension InstructionView: UITextViewDelegate {
//    func textViewDidBeginEditing(_ textView: UITextView) {
//        SharedValues.shared.currText = textView
//    }
//}
