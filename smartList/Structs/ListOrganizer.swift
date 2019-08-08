//
//  ListOrganizer.swift
//  
//
//  Created by Steven Dito on 8/4/19.
//

import Foundation
import UIKit

struct ListOrganizer {
    var listView: CreateListView
    
    var title: String {
        didSet {
            listView.setUI(title: self.title, list: items)
        }
    }
    
    var items: [String] {
        didSet {
            listView.setUI(title: title, list: self.items)
        }
    }
    
    init(title: String, items: [String], listView: CreateListView) {
        self.title = title
        self.items = items
        self.listView = listView
    }
    
    
    static func createListViews() -> [ListOrganizer] {
        var all: [ListOrganizer] = []
        
        let storesView = Bundle.main.loadNibNamed("CreateListView", owner: nil, options: nil)?.first as? CreateListView
        let stores = ListOrganizer(title: "Stores", items: [""], listView: storesView!)
        all.insert(stores, at: 0)
        
        let categoriesView = Bundle.main.loadNibNamed("CreateListView", owner: nil, options: nil)?.first as? CreateListView
        let categories = ListOrganizer(title: "Categories", items: [""], listView: categoriesView!)
        all.insert(categories, at: 0)
        
        let peopleView = Bundle.main.loadNibNamed("CreateListView", owner: nil, options: nil)?.first as? CreateListView
        let people = ListOrganizer(title: "People", items: [""], listView: peopleView!)
        all.insert(people, at: 0)
        
        return all
    }

}

