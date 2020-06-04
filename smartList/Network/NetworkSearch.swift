//
//  NetworkSearch.swift
//  smartList
//
//  Created by Steven Dito on 6/3/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import Foundation


struct NetworkSearch: Equatable {
    
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
        
        func toTagRepresentation() -> Int {
            switch self {
            case .ingredient:
                return 71
            case .tag:
                return 72
            case .title:
                return 73
            case .avoidIngredient:
                return 74
            case .unknown:
                return 75
            }
        }
        
        static func toNetworkSearchTypeRepresentation(tag: Int) -> NetworkSearchType {
            // Don't need to update this if new searches are added, based on toTagRepresentation
            for type in self.allCases {
                let int = type.toTagRepresentation()
                if int == tag {
                    return type
                }
            }
            // something went wrong
            fatalError()
        }
        
        
    }
}
