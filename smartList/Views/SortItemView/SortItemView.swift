//
//  SortItemView.swift
//  smartList
//
//  Created by Steven Dito on 10/4/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import UIKit

class SortItemView: UIView {
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var doneButton: UIButton!
    
    func setUI() {
        pickerView.delegate = self
        pickerView.dataSource = self
    }
    
}

extension SortItemView: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 4
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "Title here"
    }
    
}
