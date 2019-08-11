//
//  ListCell.swift
//  smartList
//
//  Created by Steven Dito on 8/10/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import UIKit



class ListCell: UICollectionViewCell {
    @IBOutlet weak var name: UILabel!
    
    func setUI(str: String) {
        name.text = str
    }
}
