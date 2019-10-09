//
//  Search.swift
//  smartList
//
//  Created by Steven Dito on 10/8/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import Foundation
import FirebaseFirestore


#warning("not used at all for anything yet, probably dont need this function to be in here also")
struct Search {
    static func turnIntoSystemItem(string: String) -> GenericItem {
        let descriptors: Set<String> = ["chopped", "minced", "chunks", "cut into", "cubed", "shredded", "melted", "diced", "divided", "to taste", "or more to taste", "or more as needed", "grated", "crushed", "pounded", "boneless", "skinless", "fresh", "sliced", "thinly", "halves", "half"]
        let measurements: Set<String> = ["pound", "pounds", "envelope", "cup", "tablespoons", "packet", "ounce", "large", "small", "medium", "package", "teaspoons", "teaspoon", "tablespoon", "pinch", "t.", "ts.", "tspn", "tbsp", "tbls", "bag", "seeded", "cubes", "cube", "clove", "cloves", "can", "cans", "ounces"]
        var words: [Substring] {
            return string.split{ !$0.isLetter }
        }
        var item = words.map { (sStr) -> String in
            return String(sStr)
        }
        
        // first need to trim the item from the amount
        var index: Int?
        for word in item {
            if measurements.contains(word) {
                index = item.firstIndex(of: word)
                index! += 1
            }
        }
        
        if index != nil {
            let splice = item[index!...]
            item = Array(splice)
        }
        
        // second need to trim the item from the description, i.e. onions, cubed
        item = item.filter({descriptors.contains($0) == false})
        
        #error("left off here")
        switch item {
        case <#pattern#>:
            <#code#>
        default:
            return .other
        }
        
    }
}
