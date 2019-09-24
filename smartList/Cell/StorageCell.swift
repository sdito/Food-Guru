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
    
    func setUI(item: Item) {
        name.text = item.name
        
        #warning("still need to make sure it handles expired items for the circle")
        viewForCircle.layer.sublayers = nil
        if item.timeExpires != nil {
            let pct = item.timeExpires!.getPercentageUntilExpiringFromExpirationDate(timeAdded: item.timeAdded ?? 0)
            viewForCircle.isHidden = false
            viewForCircle.circularPercentageView(endStrokeAt: CGFloat(pct), color: Colors.getRGBcolorFromPercentage(double: pct).cgColor)
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
                
            //second, if item is already expired
            } else if time < Date().timeIntervalSince1970 {
                expires.text = "Expired on \(time.dateFormatted(style: .short))"
                expires.textColor = .red
            //third, if item is still fine, then show the date
            } else {
               expires.text = "Expires - \(time.dateFormatted(style: .short))"
               expires.textColor = .lightGray
            }
            
            
            
            
            
        } else {
            expires.text = ""
        }
    }
}
