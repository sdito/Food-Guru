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
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var items: UILabel!
    @IBOutlet weak var people: UILabel!
    
    
    func setUI(list: List) {
        name.text = list.name
        date.text = "May 20th"
        
        
        
        switch list.items?.count {
        case nil:
            items.text = "No items"
        case 0:
            items.text = "No items"
        case 1:
            items.text = "1 item"
        default:
            items.text = "\(list.items!.count) items"
        }
        
        //items.text = "\(list.items?.count ?? 0) \(itemItems)"
        people.text = "\(list.people?.count ?? 99)"
    }
}
