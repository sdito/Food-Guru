//
//  RecipeType.swift
//  smartList
//
//  Created by Steven Dito on 8/26/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import Foundation


enum RecipeType: CaseIterable {
    case breakfast
    case brunch
    case lunch
    case dinner
    case snack
    case appetizer
    case dessert
    case vegan
    case vegetarian
    case drink
    case diabetic
    case lowCarb
    case dairyFree
    case glutenFree
    case healthy
    case heartHealthy
    case highFiber
    case lowCalorie
    case lowCholestorol
    case lowFat
    case weightLoss
    case christmas
    case christmasCookies
    case football
    case thanksgiving
    case bread
    case cake
    case candy
    case casserole
    case cookie
    case macAndCheese
    case mainDishes
    case pasta
    case pastaSalad
    case pie
    case pizza
    case sandwiches
    case saucesAndCondiments
    case smoothie
    case soupAndChili
    case seafood
    case slowCooker
    case salad
    case other
    
    var description: String {
        switch self {
        case .breakfast:
            return "Breakfast"
        case .brunch:
            return "Brunch"
        case .lunch:
            return "Lunch"
        case .dinner:
            return "Dinner"
        case .snack:
            return "Snack"
        case .appetizer:
            return "Appetizer"
        case .dessert:
            return "Dessert"
        case .vegan:
            return "Vegan"
        case .vegetarian:
            return "Vegetarian"
        case .drink:
            return "Drink"
        case .diabetic:
            return "Diabetic"
        case .lowCarb:
            return "Low Carb"
        case .dairyFree:
            return "Dairy Free"
        case .glutenFree:
            return "Gluten Free"
        case .healthy:
            return "Healthy"
        case .heartHealthy:
            return "Heart Healthy"
        case .highFiber:
            return "High Fiber"
        case .lowCalorie:
            return "Low Calorie"
        case .lowCholestorol:
            return "Low Cholestorol"
        case .lowFat:
            return "Low Fat"
        case .weightLoss:
            return "Weight Loss"
        case .christmas:
            return "Christmas"
        case .christmasCookies:
            return "Christmas Cookies"
        case .football:
            return "Football"
        case .thanksgiving:
            return "Thanksgiving"
        case .bread:
            return "Bread"
        case .cake:
            return "Cake"
        case .candy:
            return "Candy"
        case .casserole:
            return "Casserole"
        case .cookie:
            return "Cookies"
        case .macAndCheese:
            return "Mac and Cheese"
        case .mainDishes:
            return "Main Dish"
        case .pasta:
            return "Pasta"
        case .pastaSalad:
            return "Pasta Salad"
        case .pie:
            return "Pie"
        case .pizza:
            return "Pizza"
        case .sandwiches:
            return "Sandwich"
        case .saucesAndCondiments:
            return "Sauces and Condiments"
        case .smoothie:
            return "Smoothie"
        case .soupAndChili:
            return "Soup and Chili"
        case .seafood:
            return "Seafood"
        case .slowCooker:
            return "Slow Cooker"
        case .salad:
            return "Salad"
        case .other:
            return "Other"
        }
    }
    
    static func turnIntoEnumString(string: String) -> RecipeType {
        switch string {
        case "Breakfast":
            return .breakfast
        case "Lunch":
            return .lunch
        case "Dinner":
            return .dinner
        case "Snack":
            return .snack
        case "Appetizer":
            return .appetizer
        case "Healthy":
            return .healthy
        case "Dessert":
            return .dessert
        case "Salad":
            return .salad
        case "Seafood":
            return .seafood
        case "Casserole":
            return .casserole
        case "Vegan":
            return .vegan
        case "Vegetarian":
            return .vegetarian
        case "Slow cooker":
            return .slowCooker
        default:
            return .other
        }
    }
    
    
    // all the cases in the enum represented in their clean string format
    static var allItems: [String] = RecipeType.allCases.map{$0.description}.sorted()
    
    
}
