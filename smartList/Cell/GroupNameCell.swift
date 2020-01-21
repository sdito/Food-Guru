//
//  GroupNameCell.swift
//  smartList
//
//  Created by Steven Dito on 9/10/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import UIKit


class GroupNameCell: UICollectionViewCell {
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    
    func setUI(str: String, selectedEmail: String?) {
        name.text = str
//        name.layer.cornerRadius = 10
//        name.clipsToBounds = true
        
        switch str == selectedEmail {
        case true:
            deleteButton.isHidden = false
        case false:
            deleteButton.isHidden = true
        }
        
    }
    
}
