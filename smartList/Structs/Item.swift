//
//  Item.swift
//  smartList
//
//  Created by Steven Dito on 8/6/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import Foundation


struct Item {
    var name: String
    var category: String
    var store: String
    
    init(name: String, category: String, store: String) {
        self.name = name
        self.category = category
        self.store = store
    }
}
