//
//  CreateListView.swift
//  smartList
//
//  Created by Steven Dito on 8/4/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import UIKit


@objc protocol CreateListViewDelegate {
    @objc func setUpToolbar()
}


class CreateListView: UIView {

    @IBOutlet weak var typeTitle: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var listLabel: UILabel!
    
    var deleg: CreateListViewDelegate!
    // can use the code from the extension for this toolbar adding

    func setUI(title: String, list: [String]) {
        let toolbar = UIToolbar()
        let one = UIBarButtonItem(barButtonSystemItem: .rewind, target: nil, action: nil)
        let two = UIBarButtonItem(barButtonSystemItem: .fastForward, target: nil, action: nil)
        let three = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let four = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: #selector(deleg.setUpToolbar))
        
        
        typeTitle.text = title
        listLabel.text = list.joined(separator: "\n")
        one.tintColor = Colors.main; two.tintColor = Colors.main; three.tintColor = Colors.main; four.tintColor = Colors.main
        toolbar.autoresizingMask = .flexibleHeight
        if title == "People" {toolbar.setItems([one, three, four], animated: false)}
        else {toolbar.setItems([one, two, three, four], animated: false)}
        textField.inputAccessoryView = toolbar
        
        
        if title == "People" {
            textField.returnKeyType = .go
        }
    }
    
}

