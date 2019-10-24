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
    case julyFourth
    case birthday
    case christmas
    case christmasCookies
    case cincoDeMayo
    case easter
    case football
    case halloween
    case hanukkah
    case stPatricksDay
    case thanksgiving
    case valentines
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
        case .julyFourth:
            return "July 4th"
        case .birthday:
            return "Birthday"
        case .christmas:
            return "Christmas"
        case .christmasCookies:
            return "Christmas Cookies"
        case .cincoDeMayo:
            return "Cinco de Mayo"
        case .easter:
            return "Easter"
        case .football:
            return "Football"
        case .halloween:
            return "Halloween"
        case .hanukkah:
            return "Hanukkah"
        case .stPatricksDay:
            return "St. Patricks Day"
        case .thanksgiving:
            return "Thanksgiving"
        case .valentines:
            return "Valentine's Day"
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
        }
    }
    
    
    
    // all the cases in the enum represented in their clean string format
    static var allItems: [String] = RecipeType.allCases.map{$0.description}.sorted()
    
    
}
