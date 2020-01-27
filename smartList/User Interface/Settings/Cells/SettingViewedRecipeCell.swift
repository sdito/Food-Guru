//
//  SettingViewedRecipeCell.swift
//  smartList
//
//  Created by Steven Dito on 12/20/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import UIKit



protocol SettingViewedRecipeCellDelegate {
    func recipeDocumentIdPressed(id: String)
}



class SettingViewedRecipeCell: UITableViewCell {
    var path: String?
    var delegate: SettingViewedRecipeCellDelegate!
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var time: UILabel!
    
    
    override func awakeFromNib() {
        if SharedValues.shared.isPhone == false {
            name.font = UIFont(name: "futura", size: 20)
            time.font = UIFont(name: "futura", size: 16)
            
        }
    }
    
    func setUIfromData(data: [String:Any]) {
        name.text = data["name"] as? String
        time.text = (data["timeIntervalSince1970"] as? TimeInterval)?.timeSince()
        path = data["path"] as? String
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(recognizer))
        
        self.addGestureRecognizer(gestureRecognizer)
        
    }
    
    @objc func recognizer() {
        if let path = path?.imagePathToDocID() {
            delegate.recipeDocumentIdPressed(id: path)
        }
        
    }
}
