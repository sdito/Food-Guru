//
//  StorageCell.swift
//  smartList
//
//  Created by Steven Dito on 9/8/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import UIKit





class StorageCell: UITableViewCell {
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var added: UILabel!
    @IBOutlet weak var expires: UILabel!
    @IBOutlet weak var viewForCircle: UIView!
    @IBOutlet weak var quantity: UILabel!
    
    var item: Item?
    
    
    func setUI(item: Item) {
        self.item = item
        name.text = item.name
        let pct = item.timeExpires?.getPercentageUntilExpiringFromExpirationDate(timeAdded: item.timeAdded ?? 0) ?? 1
        viewForCircle.layer.sublayers = nil
        if item.timeExpires != nil {
            viewForCircle.isHidden = false
        } else {
            viewForCircle.isHidden = true
        }
        
        
        if let time = item.timeAdded {
            added.text = "Added - \(time.dateFormatted(style: .short))"
        } else {
            added.text = ""
        }
        
        if let time = item.timeExpires {
            // first, if item expires today
            if time.dateFormatted(style: .short) == Date().timeIntervalSince1970.dateFormatted(style: .short) {
                expires.text = "Expires today"
                expires.textColor = .darkGray
                viewForCircle.circularPercentageView(endStrokeAt: 0.2, color: Colors.getRGBcolorFromPercentage(double: pct).cgColor)
            //second, if item is already expired
            } else if time < Date().timeIntervalSince1970 {
                expires.text = "Expired on \(time.dateFormatted(style: .short))"
                expires.textColor = .red
                viewForCircle.circularPercentageView(endStrokeAt: 1, color: UIColor.red.cgColor)
            //third, if item is still fine, then show the date
            } else {
               expires.text = "Expires - \(time.dateFormatted(style: .short))"
                if #available(iOS 13.0, *) {
                    expires.textColor = .tertiaryLabel
                } else {
                    expires.textColor = .lightGray
                }
               viewForCircle.circularPercentageView(endStrokeAt: CGFloat(pct), color: Colors.getRGBcolorFromPercentage(double: pct).cgColor)
            }
 
        } else {
            expires.text = ""
        }
        
        if SharedValues.shared.isPhone == false {
            name.font = UIFont(name: "futura", size: 30)
            quantity.font = UIFont(name: "futura", size: 20)
            added.font = UIFont(name: "futura", size: 20)
            expires.font = UIFont(name: "futura", size: 20)
        }
        
        if let q = item.quantity {
            if q != "" {
                quantity.isHidden = false
                quantity.text = "(\(q))"
            } else {
                quantity.isHidden = true
            }
        } else {
            quantity.isHidden = true
        }
        
    }
    
    
}
