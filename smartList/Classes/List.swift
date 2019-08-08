//
//  List.swift
//  smartList
//
//  Created by Steven Dito on 8/6/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import Foundation

class List {
    var name: String
    var stores: [String]?
    var categories: [String]?
    var people: [String]?
    var items: [Item]?
    
    init(name: String, stores: [String]?, categories: [String]?, people: [String]?, items: [Item]?) {
        self.name = name
        self.stores = stores
        self.categories = categories
        self.people = people
        self.items = items
    }
}

