//
//  CuisineType.swift
//  smartList
//
//  Created by Steven Dito on 8/26/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import Foundation


enum CuisineType {
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
    case canadian
    case french
    case japanese
    case korean
    case mediterranean
    case ameircan
    case vietnamese
    case soul
    case greek
    case caribbean
    case german
    case cajun
    case moroccan
    case peruvian
    case british
    case filipino
    case brazilian
    
    
    
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
        case .canadian:
            return "Canadian"
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
        case .soul:
            return "Soul"
        case .greek:
            return "Greek"
        case .caribbean:
            return "Caribbean"
        case .german:
            return "German"
        case .cajun:
            return "Cajun"
        case .moroccan:
            return "Moroccan"
        case .peruvian:
            return "Peruvian"
        case .british:
            return "British"
        case .filipino:
            return "Filipino"
        case .brazilian:
            return "Brazilian"
        }
    }
}
