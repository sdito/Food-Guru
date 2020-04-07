//
//  EditQuantityView.swift
//  smartList
//
//  Created by Steven Dito on 4/4/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import UIKit



protocol EditQuantityViewDelegate: class {
    func newQuantity(item: Item, quantity: String?)
}



class EditQuantityView: UIView {
    
    private var wholeNumberPart: String?
    private var fractionPart: String?
    private var quantityPart: String = ""
    private var item: Item!
    private let defaults = UserDefaults.standard ;#warning("make sure this is being used, will be used for metric or imperial")
    
    weak var delegate: EditQuantityViewDelegate!
    
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var cancelOutlet: UIButton!
    @IBOutlet weak var doneOutlet: UIButton!
    
    
    @IBOutlet var wholeNumberButtons: [UIButton]!
    @IBOutlet var quantityButtons: [UIButton]!
    @IBOutlet var measurementButtons: [UIButton]!
    
    
    func setUI(item: Item, fromVC: UIViewController) {
        self.item = item
        if let quantity = item.quantity, quantity != "" {
            (wholeNumberPart, fractionPart, quantityPart) = quantity.splitIngredientToNumberAndQuantity()
            setTextFieldText()
        } else {
            wholeNumberPart = "0"
        }
        self.delegate = fromVC as? EditQuantityViewDelegate
        
        [cancelOutlet, doneOutlet].forEach { (btn) in
            btn?.layer.cornerRadius = 5.0
            btn?.layer.borderWidth = 1.0
            btn?.layer.borderColor = Colors.secondary.cgColor
            btn?.clipsToBounds = true
        }
        quantityButtons.forEach { (btn) in
            btn.layer.cornerRadius = 5.0
            btn.addTarget(self, action: #selector(fractionOutlet(_:)), for: .touchUpInside)
        }
        measurementButtons.forEach { (btn) in
            btn.layer.cornerRadius = 5.0
            btn.addTarget(self, action: #selector(measurementOutlet(_:)), for: .touchUpInside)
        }
        wholeNumberButtons.forEach { (btn) in
            btn.layer.cornerRadius = 5.0
            btn.addTarget(self, action: #selector(wholeNumberAction(_:)), for: .touchUpInside)
        }
        
        let useMetricForQuantity = defaults.bool(forKey: "useMetricForQuantity")
        if useMetricForQuantity {
            turnToMetric()
        }
        topLabel.text = "Set quantity for \(item.name)"
    }
    
    // MARK: IBAction funcs
    
    @IBAction func plusQuantity(_ sender: Any) {
        if wholeNumberPart == "" || wholeNumberPart == nil {
            wholeNumberPart = "2"
        } else if let text = wholeNumberPart, let number = Int(text) {
            wholeNumberPart = "\(number + 1)"
            setTextFieldText()
        }
    }
    
    @IBAction func minusQuantity(_ sender: Any) {
        if let text = wholeNumberPart, let number = Int(text), number != 0 {
            wholeNumberPart = "\(number - 1)"
            setTextFieldText()
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        dismissView()
    }
    
    @IBAction func done(_ sender: Any) {
        delegate.newQuantity(item: item, quantity: textField.text)
        dismissView()
    }
    
    @objc private func fractionOutlet(_ sender: UIButton) {
        if let fraction = sender.titleLabel?.text {
            if fractionPart == fraction {
                fractionPart = nil
            } else {
                fractionPart = fraction
            }
            setTextFieldText()
        }
    }
    
    @IBAction func changeSystemPressed(_ sender: Any) {
        print("Change the system")
        let bool = defaults.bool(forKey: "useMetricForQuantity")
        defaults.set(!bool, forKey: "useMetricForQuantity")
        
        if !bool == true {
            // Use metric
            turnToMetric()
        } else {
            // Dont use metric
            turnToStandard()
        }
    }
    
    // MARK: Functions
    
    private func turnToMetric() {
        for btn in measurementButtons {
            if btn.titleLabel?.text == "oz" {
                btn.setTitle("g", for: .normal)
            } else if btn.titleLabel?.text == "gal" {
                btn.setTitle("L", for: .normal)
            } else if btn.titleLabel?.text == "lb" {
                btn.setTitle("kg", for: .normal)
            }
        }
        
    }
    
    private func turnToStandard() {
        for btn in measurementButtons {
            if btn.titleLabel?.text == "g" {
                btn.setTitle("oz", for: .normal)
            } else if btn.titleLabel?.text == "L" {
                btn.setTitle("gal", for: .normal)
            } else if btn.titleLabel?.text == "kg" {
                btn.setTitle("lb", for: .normal)
            }
        }
        
    }
    
    @objc private func wholeNumberAction(_ sender: UIButton) {
        // each button's tag represents the number, tag of 10 is for the delete button
        let tag = sender.tag
        if tag == 10 {
            if wholeNumberPart != nil && wholeNumberPart!.count > 0 {
                wholeNumberPart?.removeLast()
                if wholeNumberPart == "" {
                    wholeNumberPart = "0"
                }
                setTextFieldText()
            }
        } else {
            if wholeNumberPart != nil {
                wholeNumberPart?.append("\(tag)")
                if wholeNumberPart?.first == "0" {
                    wholeNumberPart?.removeFirst()
                }
                setTextFieldText()
            } else {
                wholeNumberPart = "\(tag)"
                setTextFieldText()
            }
        }
        
    }
    
    @objc private func measurementOutlet(_ sender: UIButton) {
        if let measurement = sender.titleLabel?.text {
            if quantityPart == measurement {
                quantityPart = ""
            } else {
                quantityPart = measurement
            }
            setTextFieldText()
        }
    }
    
    private func dismissView() {
        let vc = self.findViewController()
        if let vc = vc {
            UIView.animate(withDuration: 0.3, animations: {
                vc.view.alpha = 0.0
            }) { (true) in
                vc.dismiss(animated: false, completion: nil)
            }
        }
    }
    
    private func setTextFieldText() {
        var str = ""
        if let partOne = wholeNumberPart, partOne != "0" {
            str = partOne
        }
        if let partTwo = fractionPart {
            if str == "" {
                str = partTwo
            } else {
                str = "\(str) \(partTwo)"
            }
        }

        let displayQuantity = quantityPart.getMeasurement(wholeNumber: wholeNumberPart, fraction: fractionPart)
        if str == "" {
            str = displayQuantity
        } else {
            str = "\(str) \(displayQuantity)"
        }
        str = str.trimmingCharacters(in: .whitespacesAndNewlines)
        textField.text = str
    }
    
}
