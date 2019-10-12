//
//  Category.swift
//  smartList
//
//  Created by Steven Dito on 10/8/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import Foundation



#warning("not using yet")



enum Category: String, CaseIterable {
    case bakery
    case beverages
    case breakfast
    case condimentsAndDressings
    case cookingBakingSpices
    case dairy
    case deli
    case frozenFoods
    case grainsPastaSides
    case meat
    case produce
    case seafood
    case snacks
    case canned
    case other
    
    var textDescription: String {
        switch self {
        case .bakery:
            return "Bakery"
        case .beverages:
            return "Beverages"
        case .breakfast:
            return "Breakfast"
        case .condimentsAndDressings:
            return "Condiments & Dressings"
        case .cookingBakingSpices:
            return "Cooking, Baking, & Spices"
        case .dairy:
            return "Dairy"
        case .deli:
            return "Deli"
        case .frozenFoods:
            return "Frozen"
        case .grainsPastaSides:
            return "Grains, Pasta, & Sides"
        case .meat:
            return "Meat"
        case .produce:
            return "Produce"
        case .seafood:
            return "Seafood"
        case .snacks:
            return "Snacks"
        case .canned:
            return "Canned"
        case .other:
            return "Other Category"
        }
    }
}
