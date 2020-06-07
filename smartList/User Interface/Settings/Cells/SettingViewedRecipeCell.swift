//
//  SettingViewedRecipeCell.swift
//  smartList
//
//  Created by Steven Dito on 12/20/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import UIKit



protocol SettingViewedRecipeCellDelegate {
    func recipeDocumentIdPressed(djangoID: Int)
}



class SettingViewedRecipeCell: UITableViewCell {
    var djangoID: String?
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
        djangoID = data["path"] as? String
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(recognizer))
        
        self.addGestureRecognizer(gestureRecognizer)
        
    }
    
    @objc func recognizer() {
        if let djangoIDint = Int(djangoID ?? "x") {
            #warning("should do something to signify that the recipe is loading here...")
            delegate.recipeDocumentIdPressed(djangoID: djangoIDint)
        }
        
    }
}
