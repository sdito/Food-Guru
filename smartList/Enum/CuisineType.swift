//
//  CuisineType.swift
//  smartList
//
//  Created by Steven Dito on 8/26/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import Foundation


enum CuisineType: CaseIterable {
    case italian
    case mexican
    case chinese
    case indian
    case thai
    case asian
    case latinAmerican
    case middleEastern
    case african
    case european
    case australianAndNZ
    case french
    case japanese
    case korean
    case mediterranean
    case ameircan
    case vietnamese
    case greek
    case german
    case brazilian
    case other
    
    
    
    var description: String {
        switch self {
        case .italian:
            return "Italian"
        case .mexican:
            return "Mexican"
        case .chinese:
            return "Chinese"
        case .indian:
            return "Indian"
        case .thai:
            return "Thai"
        case .asian:
            return "Asian"
        case .latinAmerican:
            return "Latin American"
        case .middleEastern:
            return "Middle Eastern"
        case .african:
            return "African"
        case .european:
            return "European"
        case .australianAndNZ:
            return "Australian and New Zealander"
        case .french:
            return "French"
        case .japanese:
            return "Japanese"
        case .korean:
            return "Korean"
        case .mediterranean:
            return "Mediterranean"
        case .ameircan:
            return "American"
        case .vietnamese:
            return "Vietnamese"
        case .greek:
            return "Greek"
        case .german:
            return "German"
        case .brazilian:
            return "Brazilian"
        case .other:
            return "Other"
        }
    }
    
    static var allItems: [String] {
        var list = CuisineType.allCases.map{$0.description}.sorted()
        list = list.filter({$0 != "Other"})
        list.append("Other")
        list.insert(" - ", at: 0)
        return list
    }
    
}
