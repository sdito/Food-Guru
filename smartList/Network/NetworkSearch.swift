//
//  NetworkSearch.swift
//  smartList
//
//  Created by Steven Dito on 6/3/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import Foundation


struct NetworkSearch {
    
    var text: String
    var type: NetworkSearchType
    
    enum NetworkSearchType: CaseIterable {
        case ingredient
        case tag
        case title
        case avoidIngredient
        case unknown
        
        func getParam() -> String {
            switch self {
                case .ingredient:
                    return Network.ingredientsParam
                case .tag:
                    return Network.tagsParam
                case .title:
                    return Network.titleParam
                case .avoidIngredient:
                    return Network.avoidIngredientsParam
                case .unknown:
                    return Network.unknownParam
            }
        }
        
        func takesMultiple() -> Bool {
            switch self {
                case .ingredient:
                    return true
                case .tag:
                    return false
                case .title:
                    return false
                case .avoidIngredient:
                    return true
                case .unknown:
                    return true
            }
        }
        
        
    }
}
