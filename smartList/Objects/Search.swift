//
//  Search.swift
//  smartList
//
//  Created by Steven Dito on 10/8/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import Foundation
import FirebaseFirestore

struct Search {
    static func find(from info: [(String, SearchType)], db: Firestore, recipesReturned: @escaping(_ rs: [Recipe]?) -> Void) {
        print(info.map({$0.0}))
        var recipes: [Recipe] = []
        let reference = db.collection("recipes")
        let types = info.map({$0.1})
        
        let ingredientCount = types.filter({$0 == .ingredient}).count
        let recipeCount = types.filter({$0 == .recipe}).count
        let cuisineCount = types.filter({$0 == .cuisine}).count
        let otherCount = types.filter({$0 == .other}).count
        
        let ingredientText = info.filter({$0.1 == .ingredient}).map({$0.0})
        let recipeText = info.filter({$0.1 == .recipe}).map({$0.0})
        let cuisineText = info.filter({$0.1 == .cuisine}).map({$0.0})
        let otherText = info.filter({$0.1 == .other}).map({$0.0})
        
        if otherCount != 0 {
            switch otherText.first {
            case "Simple":
                print("Find simple recipes, (with few ingredients)")
                reference.whereField("numberIngredients", isLessThanOrEqualTo: 5).getDocuments { (querySnapshot, error) in
                    guard let documents = querySnapshot?.documents else {
                        print("Error retrieving documents: \(String(describing: error))")
                        return
                    }
                    
                    for doc in documents {
                        recipes.append(doc.recipe())
                    }
                    print(recipes.map({$0.name}))
                    recipesReturned(recipes)
                }
                return
            case "Quick":
                reference.whereField("totalTime", isLessThanOrEqualTo: 25).getDocuments { (querySnapshot, error) in
                    guard let documents = querySnapshot?.documents else {
                        print("Error retrieving documents: \(String(describing: error))")
                        return
                    }
                    
                    for doc in documents {
                        recipes.append(doc.recipe())
                    }
                    print(recipes.map({$0.name}))
                    recipesReturned(recipes)
                }
            case "Expiring":
                print("Recommended time for recipes")
                var systemItemsExpiring: [String] = []
                let timeIntervalForSearch = Date().timeIntervalSince1970 + (86_400 * 2)
                let foodStorageReference = db.collection("storages").document(SharedValues.shared.foodStorageID ?? " ").collection("items").whereField("timeExpires", isLessThan: timeIntervalForSearch)
                foodStorageReference.getDocuments { (querySnapshot, error) in
                    guard let documents = querySnapshot?.documents else {
                        print("Error retreiving documents: \(String(describing: error))")
                        return
                    }
                    for doc in documents {
                        let itm = doc.get("systemItem") as? String
                        if let itm = itm {
                            systemItemsExpiring.append(itm)
                        }
                    }
                    print(systemItemsExpiring)
                    NotificationCenter.default.post(name: .expiringItemsFromFoodStorage, object: nil, userInfo: ["items":systemItemsExpiring])
                    
                    switch systemItemsExpiring.count {
                    case 0:
                        print("No items expiring")
                        let alert = UIAlertController(title: "No items expiring soon!", message: nil, preferredStyle: .alert)
                        alert.addAction(.init(title: "Ok", style: .default, handler: nil))
                        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true)
                    case 1:
                        print("One item expiring")
                        reference.whereField("has_\(systemItemsExpiring[0])", isEqualTo: true).getDocuments { (querySnapshot, error) in
                            guard let documents = querySnapshot?.documents else {
                                print("Error retrieving documents: \(String(describing: error))")
                                return
                            }
                            
                            for doc in documents {
                                recipes.append(doc.recipe())
                            }
                            recipesReturned(recipes)
                        }
                    case 2:
                        print("Two items expiring")
                        reference.whereField("has_\(systemItemsExpiring[0])", isEqualTo: true).whereField("has_\(systemItemsExpiring[1])", isEqualTo: true).getDocuments { (querySnapshot, error) in
                            guard let documents = querySnapshot?.documents else {
                                print("Error retrieving documents: \(String(describing: error))")
                                return
                            }
                            
                            for doc in documents {
                                recipes.append(doc.recipe())
                            }
                            recipesReturned(recipes)
                        }
                    case 3:
                        print("Three items expiring")
                        reference.whereField("has_\(systemItemsExpiring[0])", isEqualTo: true).whereField("has_\(systemItemsExpiring[1])", isEqualTo: true).whereField("has_\(systemItemsExpiring[2])", isEqualTo: true).getDocuments { (querySnapshot, error) in
                            guard let documents = querySnapshot?.documents else {
                                print("Error retrieving documents: \(String(describing: error))")
                                return
                            }
                            
                            for doc in documents {
                                recipes.append(doc.recipe())
                            }
                            recipesReturned(recipes)
                        }
                        
                    default:
                        print("many items expiring, just take a random 3")
                        if systemItemsExpiring.count >= 4 {
                            let threeRandom = systemItemsExpiring.shuffled().prefix(3)
                            reference.whereField("has_\(threeRandom[0])", isEqualTo: true).whereField("has_\(threeRandom[1])", isEqualTo: true).whereField("has_\(threeRandom[2])", isEqualTo: true).getDocuments { (querySnapshot, error) in
                                guard let documents = querySnapshot?.documents else {
                                    print("Error retrieving documents: \(String(describing: error))")
                                    return
                                }
                                
                                for doc in documents {
                                    recipes.append(doc.recipe())
                                }
                                recipesReturned(recipes)
                            }
                        }
                        
                    }
                    
                }
                
                
            default:
                print("getting to this point")
                recipesReturned(recipes)
            }
        } else {
            switch (ingredientCount, recipeCount, cuisineCount) {
            case (0, 0, 0):
                reference.limit(to: 50).getDocuments { (querySnapshot, error) in
                    guard let documents = querySnapshot?.documents else {
                        print("Error retrieving documents: \(String(describing: error))")
                        return
                    }
                    for doc in documents.shuffled() {
                        recipes.append(doc.recipe())
                    }
                    recipesReturned(recipes)
                }
            case (1, 0, 0):
                reference.whereField("has_\(ingredientText[0])", isEqualTo: true).getDocuments { (querySnapshot, error) in
                    guard let documents = querySnapshot?.documents else {
                        print("Error retrieving documents: \(String(describing: error))")
                        return
                    }
                    
                    for doc in documents {
                        recipes.append(doc.recipe())
                    }
                    recipesReturned(recipes)
                }
            case (2, 0, 0):
                
                reference.whereField("has_\(ingredientText[0])", isEqualTo: true).whereField("has_\(ingredientText[1])", isEqualTo: true).getDocuments { (querySnapshot, error) in
                    guard let documents = querySnapshot?.documents else {
                        print("Error retrieving documents: \(String(describing: error))")
                        return
                    }
                    for doc in documents {
                        recipes.append(doc.recipe())
                    }
                    recipesReturned(recipes)
                }
            case (3, 0, 0):
                reference.whereField("has_\(ingredientText[0])", isEqualTo: true).whereField("has_\(ingredientText[1])", isEqualTo: true).whereField("has_\(ingredientText[2])", isEqualTo: true).getDocuments { (querySnapshot, error) in
                    guard let documents = querySnapshot?.documents else {
                        print("Error retrieving documents: \(String(describing: error))")
                        return
                    }
                    
                    for doc in documents {
                        recipes.append(doc.recipe())
                    }
                    recipesReturned(recipes)
                }
            case (4, 0, 0):
                reference.whereField("has_\(ingredientText[0])", isEqualTo: true).whereField("has_\(ingredientText[1])", isEqualTo: true).whereField("has_\(ingredientText[2])", isEqualTo: true).whereField("has_\(ingredientText[3])", isEqualTo: true).getDocuments { (querySnapshot, error) in
                    guard let documents = querySnapshot?.documents else {
                        print("Error retrieving documents: \(String(describing: error))")
                        return
                    }
                    
                    for doc in documents {
                        recipes.append(doc.recipe())
                    }
                    recipesReturned(recipes)
                }
            case (5, 0, 0):
                reference.whereField("has_\(ingredientText[0])", isEqualTo: true).whereField("has_\(ingredientText[1])", isEqualTo: true).whereField("has_\(ingredientText[2])", isEqualTo: true).whereField("has_\(ingredientText[3])", isEqualTo: true).whereField("has_\(ingredientText[4])", isEqualTo: true).getDocuments { (querySnapshot, error) in
                    guard let documents = querySnapshot?.documents else {
                        print("Error retrieving documents: \(String(describing: error))")
                        return
                    }
                    
                    for doc in documents {
                        recipes.append(doc.recipe())
                    }
                    recipesReturned(recipes)
                }
            case (0, 1, 0):
                reference.whereField("recipeType", arrayContains: recipeText[0]).getDocuments { (querySnapshot, error) in
                    guard let documents = querySnapshot?.documents else {
                        print("Error retrieving documents: \(String(describing: error))")
                        return
                    }
                    
                    for doc in documents {
                        recipes.append(doc.recipe())
                    }
                    recipesReturned(recipes)
                }
            case (1, 1, 0):
                reference.whereField("has_\(ingredientText[0])", isEqualTo: true).whereField("recipeType", arrayContains: recipeText[0]).getDocuments { (querySnapshot, error) in
                    guard let documents = querySnapshot?.documents else {
                        print("Error retrieving documents: \(String(describing: error))")
                        return
                    }
                    
                    for doc in documents {
                        recipes.append(doc.recipe())
                    }
                    recipesReturned(recipes)
                }
            case (2, 1, 0):
                reference.whereField("has_\(ingredientText[0])", isEqualTo: true).whereField("has_\(ingredientText[1])", isEqualTo: true).whereField("recipeType", arrayContains: recipeText[0]).getDocuments { (querySnapshot, error) in
                    guard let documents = querySnapshot?.documents else {
                        print("Error retrieving documents: \(String(describing: error))")
                        return
                    }
                    
                    for doc in documents {
                        recipes.append(doc.recipe())
                    }
                    recipesReturned(recipes)
                }
                
                
                
                
            case (3, 1, 0):
                reference.whereField("has_\(ingredientText[0])", isEqualTo: true).whereField("has_\(ingredientText[1])", isEqualTo: true).whereField("has_\(ingredientText[2])", isEqualTo: true).whereField("recipeType", arrayContains: recipeText[0]).getDocuments { (querySnapshot, error) in
                    guard let documents = querySnapshot?.documents else {
                        print("Error retrieving documents: \(String(describing: error))")
                        return
                    }
                    
                    for doc in documents {
                        recipes.append(doc.recipe())
                    }
                    recipesReturned(recipes)
                }
            case (4, 1, 0):
                reference.whereField("has_\(ingredientText[0])", isEqualTo: true).whereField("has_\(ingredientText[1])", isEqualTo: true).whereField("has_\(ingredientText[2])", isEqualTo: true).whereField("has_\(ingredientText[3])", isEqualTo: true).whereField("recipeType", arrayContains: recipeText[0]).getDocuments { (querySnapshot, error) in
                    guard let documents = querySnapshot?.documents else {
                        print("Error retrieving documents: \(String(describing: error))")
                        return
                    }
                    
                    for doc in documents {
                        recipes.append(doc.recipe())
                    }
                    recipesReturned(recipes)
                }
            case (5, 1, 0):
                reference.whereField("has_\(ingredientText[0])", isEqualTo: true).whereField("has_\(ingredientText[1])", isEqualTo: true).whereField("has_\(ingredientText[2])", isEqualTo: true).whereField("has_\(ingredientText[3])", isEqualTo: true).whereField("has_\(ingredientText[4])", isEqualTo: true).whereField("recipeType", arrayContains: recipeText[0]).getDocuments { (querySnapshot, error) in
                    guard let documents = querySnapshot?.documents else {
                        print("Error retrieving documents: \(String(describing: error))")
                        return
                    }
                    
                    for doc in documents {
                        recipes.append(doc.recipe())
                    }
                    recipesReturned(recipes)
                }
            case (0, 0, 1):
                reference.whereField("cuisineType", isEqualTo: cuisineText[0]).getDocuments { (querySnapshot, error) in
                    guard let documents = querySnapshot?.documents else {
                        print("Error retrieving documents: \(String(describing: error))")
                        return
                    }
                    for doc in documents {
                        recipes.append(doc.recipe())
                    }
                    recipesReturned(recipes)
                }
            case (1, 0, 1):
                reference.whereField("has_\(ingredientText[0])", isEqualTo: true).whereField("cuisineType", isEqualTo: cuisineText[0]).getDocuments { (querySnapshot, error) in
                    guard let documents = querySnapshot?.documents else {
                        print("Error retrieving documents: \(String(describing: error))")
                        return
                    }
                    
                    for doc in documents {
                        recipes.append(doc.recipe())
                    }
                    recipesReturned(recipes)
                }
            case (2, 0, 1):
                reference.whereField("has_\(ingredientText[0])", isEqualTo: true).whereField("has_\(ingredientText[1])", isEqualTo: true).whereField("cuisineType", isEqualTo: cuisineText[0]).getDocuments { (querySnapshot, error) in
                    guard let documents = querySnapshot?.documents else {
                        print("Error retrieving documents: \(String(describing: error))")
                        return
                    }
                    
                    for doc in documents {
                        recipes.append(doc.recipe())
                    }
                    recipesReturned(recipes)
                }
            case (3, 0, 1):
                reference.whereField("has_\(ingredientText[0])", isEqualTo: true).whereField("has_\(ingredientText[1])", isEqualTo: true).whereField("has_\(ingredientText[2])", isEqualTo: true).whereField("cuisineType", isEqualTo: cuisineText[0]).getDocuments { (querySnapshot, error) in
                    guard let documents = querySnapshot?.documents else {
                        print("Error retrieving documents: \(String(describing: error))")
                        return
                    }
                    
                    for doc in documents {
                        recipes.append(doc.recipe())
                    }
                    recipesReturned(recipes)
                }
            case (4, 0, 1):
                reference.whereField("has_\(ingredientText[0])", isEqualTo: true).whereField("has_\(ingredientText[1])", isEqualTo: true).whereField("has_\(ingredientText[2])", isEqualTo: true).whereField("has_\(ingredientText[3])", isEqualTo: true).whereField("cuisineType", isEqualTo: cuisineText[0]).getDocuments { (querySnapshot, error) in
                    guard let documents = querySnapshot?.documents else {
                        print("Error retrieving documents: \(String(describing: error))")
                        return
                    }
                    
                    for doc in documents {
                        recipes.append(doc.recipe())
                    }
                    recipesReturned(recipes)
                }
            case (5, 0, 1):
                reference.whereField("has_\(ingredientText[0])", isEqualTo: true).whereField("has_\(ingredientText[1])", isEqualTo: true).whereField("has_\(ingredientText[2])", isEqualTo: true).whereField("has_\(ingredientText[3])", isEqualTo: true).whereField("has_\(ingredientText[4])", isEqualTo: true).whereField("cuisineType", isEqualTo: cuisineText[0]).getDocuments { (querySnapshot, error) in
                    guard let documents = querySnapshot?.documents else {
                        print("Error retrieving documents: \(String(describing: error))")
                        return
                    }
                    
                    for doc in documents {
                        recipes.append(doc.recipe())
                    }
                    recipesReturned(recipes)
                }
            case (0, 1, 1):
                reference.whereField("recipeType", arrayContains: recipeText[0]).whereField("cuisineType", isEqualTo: cuisineText[0]).getDocuments { (querySnapshot, error) in
                    guard let documents = querySnapshot?.documents else {
                        print("Error retrieving documents: \(String(describing: error))")
                        return
                    }
                    for doc in documents {
                        recipes.append(doc.recipe())
                    }
                    recipesReturned(recipes)
                }
            case (1, 1, 1):
                reference.whereField("has_\(ingredientText[0])", isEqualTo: true).whereField("recipeType", arrayContains: recipeText[0]).whereField("cuisineType", isEqualTo: cuisineText[0]).getDocuments { (querySnapshot, error) in
                    guard let documents = querySnapshot?.documents else {
                        print("Error retrieving documents: \(String(describing: error))")
                        return
                    }
                    for doc in documents {
                        recipes.append(doc.recipe())
                    }
                    recipesReturned(recipes)
                }
            case (2, 1, 1):
                reference.whereField("has_\(ingredientText[0])", isEqualTo: true).whereField("has_\(ingredientText[1])", isEqualTo: true).whereField("recipeType", arrayContains: recipeText[0]).whereField("cuisineType", isEqualTo: cuisineText[0]).getDocuments { (querySnapshot, error) in
                    guard let documents = querySnapshot?.documents else {
                        print("Error retrieving documents: \(String(describing: error))")
                        return
                    }
                    for doc in documents {
                        recipes.append(doc.recipe())
                    }
                    recipesReturned(recipes)
                }
            case (3, 1, 1):
                reference.whereField("has_\(ingredientText[0])", isEqualTo: true).whereField("has_\(ingredientText[1])", isEqualTo: true).whereField("has_\(ingredientText[2])", isEqualTo: true).whereField("recipeType", arrayContains: recipeText[0]).whereField("cuisineType", isEqualTo: cuisineText[0]).getDocuments { (querySnapshot, error) in
                    guard let documents = querySnapshot?.documents else {
                        print("Error retrieving documents: \(String(describing: error))")
                        return
                    }
                    for doc in documents {
                        recipes.append(doc.recipe())
                    }
                    recipesReturned(recipes)
                }
            case (4, 1, 1):
                reference.whereField("has_\(ingredientText[0])", isEqualTo: true).whereField("has_\(ingredientText[1])", isEqualTo: true).whereField("has_\(ingredientText[2])", isEqualTo: true).whereField("has_\(ingredientText[3])", isEqualTo: true).whereField("recipeType", arrayContains: recipeText[0]).whereField("cuisineType", isEqualTo: cuisineText[0]).getDocuments { (querySnapshot, error) in
                    guard let documents = querySnapshot?.documents else {
                        print("Error retrieving documents: \(String(describing: error))")
                        return
                    }
                    for doc in documents {
                        recipes.append(doc.recipe())
                    }
                    recipesReturned(recipes)
                }
            case (5, 1, 1):
                reference.whereField("has_\(ingredientText[0])", isEqualTo: true).whereField("has_\(ingredientText[1])", isEqualTo: true).whereField("has_\(ingredientText[2])", isEqualTo: true).whereField("has_\(ingredientText[3])", isEqualTo: true).whereField("has_\(ingredientText[4])", isEqualTo: true).whereField("recipeType", arrayContains: recipeText[0]).whereField("cuisineType", isEqualTo: cuisineText[0]).getDocuments { (querySnapshot, error) in
                    guard let documents = querySnapshot?.documents else {
                        print("Error retrieving documents: \(String(describing: error))")
                        return
                    }
                    for doc in documents {
                        recipes.append(doc.recipe())
                    }
                    recipesReturned(recipes)
                }
            default:
                return
            }
        }
        
        
        
    }
    
    static func searchFromSearchBar(string: String) -> [(String, SearchType)] {
        var currentSearches: [(String, SearchType)] = []
        let cuisine = Search.turnIntoSystemCuisineType(string: string)
        let recipe = Search.turnIntoSystemRecipeType(string: string)
        let ingredient = Search.turnIntoSystemItem(string: string)
        
        if recipe != .other {
            currentSearches.append(("\(recipe.description)", .recipe))
        } else if ingredient != .other {
            currentSearches.append(("\(ingredient)", .ingredient))
        } else if cuisine != .other {
            currentSearches.append(("\(cuisine.description)", .cuisine))
        }
        
        
        if currentSearches.isEmpty {
            return [(string, .other)]
        }
        
        else {
            return currentSearches
        }
        
    }
    
    
    static func getRecipesFromIngredients(db: Firestore, ingredients: [String], recipesReturned: @escaping(_ recipes: [Recipe]?) -> Void) {
        var recipes: [Recipe] = []
        let reference = db.collection("recipes")
        
        
        switch ingredients.count {
        case 0:
            return
        case 1:
            reference.whereField("has_\(ingredients.first!)", isEqualTo: true).getDocuments { (querySnapshot, error) in
                guard let documents = querySnapshot?.documents else {
                    print("Error retrieving documents: \(String(describing: error))")
                    return
                }

                for doc in documents {
                    recipes.append(doc.recipe())
                }
                recipesReturned(recipes)
            }
        case 2:
            reference.whereField("has_\(ingredients[0])", isEqualTo: true).whereField("has_\(ingredients[1])", isEqualTo: true).getDocuments { (querySnapshot, error) in
                guard let documents = querySnapshot?.documents else {
                    print("Error retrieving documents: \(String(describing: error))")
                    return
                }

                for doc in documents {
                    recipes.append(doc.recipe())
                }
                recipesReturned(recipes)
            }
        case 3:
            reference.whereField("has_\(ingredients[0])", isEqualTo: true).whereField("has_\(ingredients[1])", isEqualTo: true).whereField("has_\(ingredients[2])", isEqualTo: true).getDocuments { (querySnapshot, error) in
                guard let documents = querySnapshot?.documents else {
                    print("Error retrieving documents: \(String(describing: error))")
                    return
                }

                for doc in documents {
                    recipes.append(doc.recipe())
                }
                recipesReturned(recipes)
            }
        case 4:
            reference.whereField("has_\(ingredients[0])", isEqualTo: true).whereField("has_\(ingredients[1])", isEqualTo: true).whereField("has_\(ingredients[2])", isEqualTo: true).whereField("has_\(ingredients[3])", isEqualTo: true).getDocuments { (querySnapshot, error) in
                guard let documents = querySnapshot?.documents else {
                    print("Error retrieving documents: \(String(describing: error))")
                    return
                }

                for doc in documents {
                    recipes.append(doc.recipe())
                }
                recipesReturned(recipes)
            }
        default:
            reference.whereField("has_\(ingredients[0])", isEqualTo: true).whereField("has_\(ingredients[1])", isEqualTo: true).whereField("has_\(ingredients[2])", isEqualTo: true).whereField("has_\(ingredients[3])", isEqualTo: true).whereField("has_\(ingredients[4])", isEqualTo: true).getDocuments { (querySnapshot, error) in
                guard let documents = querySnapshot?.documents else {
                    print("Error retrieving documents: \(String(describing: error))")
                    return
                }

                for doc in documents {
                    recipes.append(doc.recipe())
                }
                recipesReturned(recipes)
            }
        }
    }
    
    static func turnIntoSystemRecipeType(string: String) -> RecipeType {
        let lower = string.lowercased()
        var words: [Substring] {
            return lower.split{ !$0.isLetter }
        }
        
        let item = words.map { (sStr) -> String in
            return String(sStr)
        }
        
        if item.contains("dinner") {
            return .dinner
        } else if item.contains("breakfast") {
            return .breakfast
        } else if item.contains("brunch") {
            return .brunch
        } else if item.contains("lunch") {
            return .lunch
        } else if item.contains("appetizer") || item.contains("starter") {
            return .appetizer
        } else if item.contains("vegan") {
            return .vegan
        } else if item.contains("vegetarian") {
            return .vegetarian
        } else if item.contains("dessert") || item.contains("desert") {
            return .dessert
        } else if item.contains("snack") {
            return .snack
        } else if item.contains("diabetic") {
            return .diabetic
        } else if item.contains("healthy") || item.contains("nutritious") {
            if item.contains("heart") {
                return .heartHealthy
            } else {
                return .healthy
            }
        } else if item.contains("casserole") {
            return .casserole
        } else if (item.contains("dairy") && (item.contains("free") || item.contains("no"))) || item.contains("lactose") {
            return .dairyFree
        } else if item.contains("pizza") {
            return .pizza
        } else if item.contains("pasta") && item.contains("salad") {
            return .pastaSalad
        } else if item.contains("seafood") {
            return .seafood
        } else if item.contains("low") {
            if item.contains("calorie") || item.contains("calories") {
                return .lowCalorie
            } else if item.contains("carb") || item.contains("carbs") || item.contains("carbohydrates") {
                return .lowCarb
            } else if item.contains("fat") && item.contains("milk") == false {
                return .lowFat
            } else if item.contains("cholestorol") {
                return .lowCholestorol
            }
        } else if (item.contains("gluten") && (item.contains("no") || item.contains("free"))) || item.contains("celiac") {
            return .glutenFree
        } else if item.contains("bread") || item.contains("baguette") {
            return .bread
        } else if item.contains("cake") {
            return .cake
        } else if item.contains("soup") || item.contains("chili") {
            return .soupAndChili
        } else if item.contains("sandwich") || item.contains("sandwiches") {
            return .sandwiches
        } else if item.contains("drink") || item.contains("beverage") {
            return .drink
        } else if item.contains("weight") && item.contains("loss") {
            return .weightLoss
        } else if item.contains("cookie") || item.contains("cookies") {
            if item.contains("christmas") {
                return .christmasCookies
            } else {
                return .cookie
            }
        } else if item.contains("christmas") {
            return .christmas
        } else if item.contains("pie") {
            return .pie
        } else if item.contains("main") {
            return .mainDishes
        } else if item.contains("thanksgiving") {
            return .thanksgiving
        } else if item.contains("fiber") {
            return .highFiber
        } else if item.contains("candy") {
            return .candy
        } else if item.contains("smoothie") {
            return .smoothie
        } else if item.contains("football") {
            return .football
        } else if ((item.contains("macaroni") || item.contains("mac")) && (item.contains("cheese"))) {
            return .macAndCheese
        } else if ((item.contains("slow") && item.contains("cooker")) || (item.contains("crock") && item.contains("pot"))) {
            return .slowCooker
        } else if item.contains("condiment") || item.contains("sauce") {
            return .saucesAndCondiments
        }
        
        return .other
    }
    
    static func turnIntoSystemCuisineType(string: String) -> CuisineType {
        let lower = string.lowercased()
        var words: [Substring] {
            return lower.split{ !$0.isLetter }
        }
        
        let item = words.map { (sStr) -> String in
            return String(sStr)
        }
        
        if item.contains("italian") {
            return .italian
        } else if item.contains("mexican") {
            return .mexican
        } else if item.contains("chinese") {
            return .chinese
        } else if item.contains("indian") {
            return .indian
        } else if item.contains("thai") {
            return .thai
        } else if item.contains("asian") {
            return .asian
        } else if item.contains("american") {
            if item.contains("latin") {
                return .latinAmerican
            } else {
                return .ameircan
            }
        } else if item.contains("middle") && item.contains("eastern") {
            return .middleEastern
        } else if item.contains("african") {
            return .african
        } else if item.contains("european") {
            return .european
        } else if item.contains("australian") || item.contains("zealand") {
            return .australianAndNZ
        } else if item.contains("french") {
            return .french
        } else if item.contains("japanese") {
            return .japanese
        } else if item.contains("korean") {
            return .korean
        } else if item.contains("mediterranean") {
            return .mediterranean
        } else if item.contains("vietnamese") {
            return .vietnamese
        } else if item.contains("greek") {
            return .greek
        } else if item.contains("german") {
            return .german
        } else if item.contains("brazilian") {
            return .brazilian
        }
        
        return .other
    }
    
    static func turnIntoSystemItem(string: String) -> GenericItem {
        let descriptors: Set<String> = ["chopped", "minced", "chunks", "cut into", "cubed", "shredded", "melted", "diced", "divided", "to taste", "or more to taste", "or more as needed", "grated", "crushed", "pounded", "boneless", "skinless", "fresh", "sliced", "thinly", "halves", "halved", "seeded", "with", "and", "finely", "optional", "taste"]
        let measurements: Set<String> = ["pound", "pounds", "envelope", "cup", "cups", "tablespoons", "packet", "ounce", "large", "small", "medium", "package", "teaspoons", "teaspoon", "tablespoon", "pinch", "t.", "ts.", "tspn", "tbsp", "tbls", "bag", "cubes", "cube", "ounces", "quart"]
        
        let lower = string.lowercased()
        var words: [Substring] {
            return lower.split{ !$0.isLetter }
        }
        
        var item = words.map { (sStr) -> String in
            return String(sStr)
        }
        // first need to trim the item from the amount
        var index: Int?
        
        var measurementUsed = false
        for word in item {
            if measurementUsed == false {
                if measurements.contains(word) {
                    index = item.firstIndex(of: word)
                    index! += 1
                    measurementUsed = true
                }
            }
        }
        
        if index != nil {
            let splice = item[index!...]
            item = Array(splice)
        }
        
        // second need to trim the item from the description, i.e. get rid of cubed or grated
        item = item.filter({descriptors.contains($0) == false})
        
        
        if item.contains("chicken") {
            if item.contains("soup") && item.contains("cream") {
                return .creamOfChickenSoup
            } else if  item.contains("stock") || item.contains("broth") || item.contains("bouillon") {
                return .broth
            } else if item.contains("sausage") {
                return .sausage
            } else if item.contains("wings") || item.contains("drummettes") {
                return .chickenWings
            } else {
                return .chicken
            }
        } else if item.contains("bread") || item.contains("roll") || item.contains("bun") {
            if item.contains("crumbs") {
                return .breadCrumbs
            } else if item.contains("garlic") {
                return .garlicBread
            } else if item.contains("pita") || item.contains("flat") {
                return .pitaBread
            } else if item.contains("flour") {
                return .breadFlour
            } else {
                return .bread
            }
        } else if item.contains("yogurt") {
            if item.contains("greek") {
                return .greekYogurt
            } else {
                return .yogurt
            }
            
        } else if item.contains("salt") {
            return .salt
        } else if item.contains("beef") {
            if item.contains("ground") {
                return .groundBeef
            } else if item.contains("broth") || item.contains("bouillon") || item.contains("stock") {
                return .broth
            } else if item.contains("corned") {
                return .cornedBeef
            } else if item.contains("jerky") {
                return .beefJerky
            } else if item.contains("steak") {
                return .steak
            } else {
                return .beef
            }
        } else if item.contains("pork") {
            if item.contains("sausage") {
                return .sausage
            } else if item.contains("rinds") {
                return .porkRinds
            } else if item.contains("ground") {
                return .groundPork
            } else if item.contains("ribs") || item.contains("rib") {
                return .ribs
            } else {
                return .pork
            }
        } else if item.contains("pasta") || item.contains("macaroni") || item.contains("spaghetti") || item.contains("noodles") {
            if item.contains("sauce") {
                return .marinara
            } else if item.contains("squash") {
                return .squash
            } else {
                return .pasta
            }
            
        } else if item.contains("tofu") {
            return .tofu
        } else if item.contains("sausage") {
            if item.contains("breakfast") {
                return .breakfastSausage
            } else {
                return .sausage
            }
        } else if item.contains("milk") {
            if item.contains("coconut") {
                return .coconutMilk
            } else if item.contains("almond") {
                return .almondMilk
            } else if item.contains("soy") {
                return .soyMilk
            } else if item.contains("chocolate") {
                if item.contains("hazelnut") && item.contains("spread") {
                    return .nutella
                } else {
                    return .chocolate
                }
            } else if item.contains("evaporated") {
                return .evaporatedMilk
            } else if item.contains("condensed") {
                return .condensedMilk
            } else {
                return .milk
            }
        } else if item.contains("crab") || item.contains("crabmeat") {
            return .crab
        } else if item.contains("egg") || item.contains("eggs") {
            if item.contains("noodle") || item.contains("noodles") {
                return .eggNoodles
            } else {
                return .egg
            }
        } else if item.contains("kale") {
            return .kale
        } else if item.contains("cod") {
            return .cod
        } else if item.contains("cilantro") {
            return .cilantro
        } else if item.contains("cinnamon") {
            return .cinnamon
        } else if item.contains("honey") {
            return .honey
        } else if item.contains("jam") || item.contains("jelly") || item.contains("preserves") {
            return .jelly
        } else if item.contains("halibut") {
            return .halibut
        } else if item.contains("ginger") {
            if item.contains("root") {
                return .gingerRoot
            } else {
                return .ginger
            }
        } else if item.contains("mozzarella") {
            return .mozzarella
        } else if item.contains("provolone") {
            return .provolone
        } else if item.contains("ricotta") {
            return .ricotta
        } else if item.contains("cheddar") {
            return .cheddar
        } else if item.contains("swiss") {
            if item.contains("chard") {
                return .chard
            } else {
                return .swiss
            }
        }
        else if item.contains("celery") {
            return .celery
        } else if item.contains("cauliflower") {
            return .cauliflower
        } else if item.contains("butter") {
            if item.contains("peanut") {
                return .peanutButter
            } else if item.contains("almond") {
                return .almondButter
            } else if item.contains("cashew") {
                return .cashewButter
            } else if item.contains("apple") {
                return .appleButter
            } else if item.contains("sunflower") {
                return .sunflowerButter
            } else {
                return .butter
            }
        } else if item.contains("turkey") {
            if item.contains("ground") {
                return .groundTurkey
            } else if item.contains("stock") || item.contains("broth") {
                return .broth
            } else if item.contains("jerky") {
                return .turkeyJerky
            } else if item.contains("liver") {
                return .other
            } else {
                return .turkey
            }
        } else if item.contains("tuna") {
            return .tuna
        } else if item.contains("trout") {
            return .trout
        } else if item.contains("spinach") {
            if item.contains("baby") {
                return .babySpinach
            } else {
                return .spinach
            }
        } else if item.contains("shrimp") {
            if item.contains("paste") {
                return .fishSauce
            } else {
                return .shrimp
            }
        } else if item.contains("tilapia") {
            return .tilapia
        } else if item.contains("onion") || item.contains("onions") {
            if item.contains("powder") {
                return .onionPowder
            } else if item.contains("green") {
                return .greenOnion
            } else if item.contains("soup") {
                return .other
            } else {
                return .onion
            }
            
        } else if item.contains("mushroom") || item.contains("mushrooms") {
            if item.contains("cream") && item.contains("soup") {
                return .creamOfMushroomSoup
            } else if item.contains("portobello") {
                return .portobelloMushroom
            } else {
                return .mushroom
            }
        } else if item.contains("garlic") {
            if item.contains("salt") {
                return .salt
            } else if item.contains("powder") {
                return .garlicPowder
            } else if item.contains("pepper") {
                return .other
            } else if item.contains("bread") {
                return .garlicBread
            } else {
                return .garlic
            }
        } else if (item.contains("olive") || item.contains("olives")) && item.contains("oil") == false {
            if item.contains("green") {
                return .greenOlive
            } else {
                return .blackOlive
            }
        } else if item.contains("haddock") {
            return .haddock
        } else if item.contains("avocado") || item.contains("avocados") {
            if item.contains("oil") {
                return .avocadoOil
            } else {
                return .avocado
            }
        } else if item.contains("bacon") {
            return .bacon
        } else if item.contains("broccoli") {
            return .broccoli
        } else if item.contains("broth") {
            return .broth
        } else if item.contains("snapper") {
            return .snapper
        } else if item.contains("salmon") {
            return .salmon
        } else if item.contains("sole") {
            return .sole
        } else if item.contains("venison") {
            return .venison
        } else if item.contains("watermelon") {
            return .watermelon
        } else if item.contains("zucchini") {
            return .zucchini
        } else if item.contains("quinoa") {
            return .quinoa
        } else if item.contains("salami") {
            return .salami
        } else if item.contains("parmesan") {
            return .parmesan
        } else if item.contains("lemon") || item.contains("lemons") {
            if item.contains("juice") {
                return .lemonJuice
            } else if item.contains("herb") {
                return .other
            } else {
                return .lemon
            }
        } else if item.contains("lime") || item.contains("limes") {
            if item.contains("juice") {
                return .limeJuice
            } else if item.contains("leaves") {
                return .other
            } else {
                return .lime
            }
        } else if item.contains("mahi") {
            return .mahiMahi
        } else if item.contains("marinara") {
            return .marinara
        }
        
        else if item.contains("juice") {
            if item.contains("apple") {
                return .appleJuice
            } else if item.contains("orange") {
                return .orangeJuice
            } else if item.contains("cranberry") {
                return .cranberryJuice
            } else if item.contains("clam") {
                return .clamJuice
            } else {
                return .juice
            }
            
        } else if item.contains("lamb") {
            return .lamb
        } else if item.contains("orange") || item.contains("oranges") {
            return .orange
        } else if item.contains("oregano") {
            return .oregano
        } else if item.contains("mayonnaise") || item.contains("mayo") {
            return .mayonnaise
        } else if item.contains("sriracha") {
            return .sriracha
        } else if item.contains("margarine") || item.contains("shortening") {
            return .margarine
        } else if item.contains("parsley") {
            if item.contains("dried") {
                return .driedParsley
            } else {
                return .parsley
            }
        } else if item.contains("turmeric") {
            return .turmeric
        } else if item.contains("swordfish") {
            return .swordfish
        } else if item.contains("syrup") {
            if item.contains("peaches") {
                return .peach
            } else {
                return .syrup
            }
        } else if item.contains("cream") {
            if item.contains("whipped") {
                if item.contains("cheese") {
                    return .creamCheese
                } else {
                    return .whippedCream
                }
            } else if item.contains("heavy") {
                return .heavyCream
            } else if item.contains("ice") {
                return .iceCream
            } else if item.contains("sour") {
                return .sourCream
            } else if item.contains("cheese") {
                return .creamCheese
            }
            else {
                return .cream
            }
        } else if item.contains("gelato") || item.contains("sorbet") {
            return .iceCream
        }
        else if item.contains("sauce") {
            if item.contains("worcestershire") {
                return .worcestershireSauce
            } else if item.contains("apple") {
                return .appleSauce
            } else if item.contains("bbq") || item.contains("barbecue") || item.contains("barbeque") {
                return .bbqSauce
            } else if item.contains("hot") {
                return .hotSauce
            } else if item.contains("soy") {
                return .soySauce
            } else if item.contains("steak") {
                return .steakSauce
            } else if item.contains("tomato") {
                return .tomatoSauce
            } else if item.contains("alfredo") {
                return .alfredoSauce
            } else if item.contains("pesto") {
                return .pestoSauce
            } else if item.contains("oyster") {
                return .oysterSauce
            } else if item.contains("tartar") {
                return .tartarSauce
            } else if item.contains("teriyaki") {
                return .teriyakiSauce
            } else if item.contains("fish") {
                return .fishSauce
            } else if item.contains("cranberry") {
                return .cranberrySauce
            } else if item.contains("enchilada") {
                return .enchiladaSauce
            }
        } else if item.contains("apple") || item.contains("apples") {
            if item.contains("vinegar") {
                return .appleCiderVinegar
            } else if item.contains("cider") {
                return .appleJuice
            } else {
                return .apple
            }
        } else if item.contains("beans") {
            if item.contains("baked") {
                return .bakedBeans
            } else if item.contains("black") {
                return .blackBeans
            } else if item.contains("pinto") {
                return .pintoBeans
            } else if item.contains("kidney") {
                return .kidneyBeans
            } else if item.contains("lima") {
                return .limaBeans
            } else if item.contains("cannellini") || item.contains("white") {
                return .cannelliniBeans
            } else if item.contains("fava") {
                return .favaBeans
            } else if item.contains("green") {
                return .greenBeans
            } else if item.contains("garbanzo") {
                return .garbanzoBeans
            }
        } else if item.contains("wine") {
            if item.contains("red") {
                return .vinegar
            } else if item.contains("red") {
                return .redWine
            } else if item.contains("white") {
                return .whiteWine
            } else {
                return .cookingWine
            }
        } else if item.contains("sugar") {
            if item.contains("brown") {
                return .brownSugar
            } else if item.contains("powdered") || item.contains("confectioners") {
                return .powderedSugar
            } else {
                return .sugar
            }
        } else if item.contains("potato") || item.contains("potatoes") {
            if item.contains("sweet") {
                return .sweetPotato
            } else {
                return .potato
            }
        } else if item.contains("yam") || item.contains("yams") {
            return .sweetPotato
        } else if item.contains("salsa") || (item.contains("gallo") && item.contains("pico")) {
            return .salsa
        } else if item.contains("rosemary") {
            return .rosemary
        } else if item.contains("peach") || item.contains("peaches") {
            return .peach
        } else if item.contains("strawberry") || item.contains("strawberries") {
            return .strawberry
        } else if item.contains("banana") || item.contains("bananas") {
            return .banana
        } else if item.contains("grapes") {
            return .grape
        } else if item.contains("kiwi") || item.contains("kiwis") {
            return .kiwi
        } else if item.contains("pear") || item.contains("pears") {
            return .pear
        } else if item.contains("apricot") || item.contains("apricots") {
            return .apricot
        } else if item.contains("blackberries") {
            return .blackberry
        } else if item.contains("blueberries") {
            return .blueberries
        } else if item.contains("capers") {
            return .capers
        } else if item.contains("cherries") || item.contains("cherry") {
            if item.contains("tomatoes") || item.contains("tomato") {
                return .cherryTomato
            } else if item.contains("pie") {
                return .other
            } else {
                return .cherries
            }
        } else if item.contains("cranberry") || item.contains("cranberries") {
            if item.contains("sauce") {
                return .cranberrySauce
            } else {
                return .cranberry
            }
        } else if item.contains("grapefruit") || item.contains("grapefruits") {
            return .grapefruit
        } else if item.contains("guava") || item.contains("guavas") {
            return .guava
        } else if item.contains("mango") || item.contains("mangoes") || item.contains("mangos") {
            if item.contains("dried") {
                return .driedMango
            } else if item.contains("chutney") {
                return .chutney
            } else {
                return .mango
            }
        } else if item.contains("melon") || item.contains("melons") {
            return .melon
        } else if item.contains("pineapple") || item.contains("pineapples") {
            return .pineapple
        } else if item.contains("pomegranate") || item.contains("pomegranates") {
            if item.contains("seeds") {
                return .pomegranateSeeds
            } else {
                return .pomegranate
            }
        } else if item.contains("raspberry") || item.contains("raspberries") {
            if item.contains("vinaigrette") {
                return .saladDressing
            } else {
                return .raspberry
            }
        } else if item.contains("tomato") || item.contains("tomatoes") || item.contains("tomatos") {
            if item.contains("paste") {
                return .tomatoPaste
            } else if item.contains("can") || item.contains("cans") || item.contains("canned") {
                return .cannedTomato
            } else if item.contains("sun") && item.contains("dried") {
                return .sunDriedTomato
            } else if item.contains("cherries") || item.contains("cherry") {
                return .cherryTomato
            } else {
                return .tomato
            }
        } else if item.contains("plum") || item.contains("plums") {
            return .plum
        } else if item.contains("tortilla") || item.contains("tortillas") {
            if item.contains("chips") {
                return .chips
            } else {
                return .tortilla
            }
        } else if item.contains("duck") {
            return .duck
        } else if item.contains("feta") {
            return .feta
        } else if item.contains("flour") {
            return .flour
        } else if item.contains("flounder") {
            return .flounder
        } else if item.contains("ham") {
            return .ham
        } else if item.contains("gruyere") {
            return .gruyere
        }
        else if item.contains("cheese") {
            if item.contains("goat") {
                return .goatCheese
            } else if item.contains("mac") || item.contains("macaroni") {
                return .macAndCheese
            } else if item.contains("asiago") {
                return .asiagoCheese
            } else if item.contains("bleu") || item.contains("blue") {
                return .bleuCheese
            } else if item.contains("cottage") {
                return .cottageCheese
            } else if item.contains("romano") {
                return .romanoCheese
            } else if item.contains("cream") {
                return .creamCheese
            } else if item.contains("american") {
                return .americanCheese
            } else if item.contains("jack") && item.contains("monterey") {
                return .montereyJackCheese
            } else if item.contains("ravioli") {
                return .ravioli
            } else if item.contains("tortellini") {
                return .tortellini
            } else if item.contains("burrata") {
                return .burrataCheese
            } else if item.contains("mascarpone") {
                return .mascarpone
            } else if item.contains("pepperjack") || ( item.contains("pepper") && item.contains("jack") ) {
                return .pepperjack
            }
            
            else {
                return .cheese
            }
        } else if item.contains("pizza") {
            return .pizza
        } else if item.contains("relish") {
            return .relish
        } else if item.contains("pickle") || item.contains("pickles") {
            return .pickle
        } else if item.contains("pepper") || item.contains("peppers") {
            if item.contains("bell") {
                return .bellPepper
            } else if item.contains("red") {
                return .redPepper
            } else if item.contains("black") {
                return .blackPepper
            } else if item.contains("white") {
                return .whitePepper
            } else if item.contains("jalapeno") || item.contains("jalapeño") {
                return .jalapeno
            } else if item.contains("cayenne") {
                return .cayenne
            } else {
                return .pepper
            }
        } else if item.contains("peanut") || item.contains("peanuts") {
            if item.contains("oil") {
                return .peanutOil
            } else {
                return .peanut
            }
        } else if item.contains("rice") {
            if item.contains("arborio") {
                return .arborioRice
            } else if item.contains("vinegar") {
                return .vinegar
            } else {
                return .rice
            }
        } else if item.contains("squash") {
            return .squash
        } else if item.contains("oil") {
            if item.contains("vegetable") {
                return .vegetableOil
            } else if item.contains("olive") {
                return .oliveOil
            } else if item.contains("canola") {
                return .canolaOil
            } else if item.contains("sesame") {
                return .sesameOil
            } else if item.contains("coconut") {
                return .coconutOil
            } else {
                return .oil
            }
        } else if item.contains("rum") {
            return .rum
        } else if item.contains("sage") {
            return .sage
        } else if item.contains("vodka") {
            return .vodka
        } else if item.contains("bourbon") {
            return .bourbon
        } else if item.contains("whiskey") {
            return .whiskey
        } else if item.contains("yeast") {
            return .yeast
        } else if item.contains("gin") {
            return .gin
        } else if item.contains("cumin") {
            return .cumin
        } else if item.contains("cucumber") || item.contains("cucumbers") {
            return .cucumber
        } else if item.contains("coffee") {
            if item.contains("creamer") {
                return .cream
            } else {
                return .coffee
            }
        } else if item.contains("corn") {
            return .corn
        } else if item.contains("chocolate") {
            return .chocolate
        } else if item.contains("chili") {
            if item.contains("powder") {
                return .chiliPowder
            } else {
                return .chili
            }
        } else if item.contains("cabbage") {
            return .cabbage
        } else if item.contains("basil") {
            if item.contains("dried") {
                return .driedBasil
            } else {
                return .basil
            }
        } else if item.contains("vinegar") {
            if item.contains("balsamic") {
                return .balsamicVinegar
            } else {
                return .vinegar
            }
        } else if item.contains("vanilla") {
            return .vanilla
        } else if item.contains("almond") || item.contains("almonds") {
            if item.contains("extract") {
                return .almondExtract
            } else {
                return .almond
            }
        } else if item.contains("baking") && item.contains("soda") {
            return .bakingSoda
        } else if item.contains("baking") && item.contains("powder") {
            return .bakingPowder
        } else if item.contains("bay") && (item.contains("leaf") || item.contains("leaves")) {
            return .bayLeaf
        } else if item.contains("beer") {
            if item.contains("root") {
                return .soda
            } else {
                return .beer
            }
        } else if item.contains("asparagus") {
            return .asparagus
        } else if item.contains("anchovy") || item.contains("anchovies") {
            return .anchovy
        } else if item.contains("bagel") || item.contains("bagels") {
            return .bagel
        } else if item.contains("barley") {
            return .barley
        } else if item.contains("carrot") || item.contains("carrots") {
            return .carrot
        } else if item.contains("cayenne") {
            return .cayenne
        } else if item.contains("catfish") {
            return .catfish
        } else if item.contains("cereal") {
            return .cereal
        } else if item.contains("champagne") {
            return .champagne
        } else if item.contains("curry") {
            if item.contains("powder") {
                return .curryPowder
            } else if item.contains("paste") {
                return .curryPaste
            }
            
        } else if item.contains("jalapeno") || item.contains("jalapeño") {
            return .jalapeno
        } else if item.contains("ketchup") {
            return .ketchup
        } else if item.contains("lobster") {
            return .lobster
        } else if item.contains("lettuce") {
            return .lettuce
        } else if item.contains("lasagna") && item.contains("noodles") {
            return .lasagnaNoodles
        } else if item.contains("mustard") {
            if item.contains("dijon") {
                return .dijonMustard
            } else if item.contains("ground") || item.contains("dry") {
                return .groundMustard
            } else if item.contains("green") || item.contains("greens") {
                return .mustardGreens
            }
            else {
                return .mustard
            }
        } else if item.contains("nutmeg") {
            return .nutmeg
        } else if item.contains("oysters") || item.contains("oyster") {
            return .oyster
        } else if item.contains("paprika") {
            return .paprika
        } else if item.contains("granola") {
            if item.contains("bar") || item.contains("bars") {
                return .granolaBars
            } else {
                return .granola
            }
        } else if item.contains("cashew") || item.contains("cashews") {
            return .cashew
        } else if item.contains("tea") {
            return .tea
        } else if item.contains("thyme") {
            return .thyme
        } else if item.contains("sardine") || item.contains("sardines") {
            return .sardine
        } else if item.contains("soda") || item.contains("pop") || item.contains("cola") || item.contains("coke") {
            return .soda
        } else if item.contains("pot") && item.contains("roast") {
            return .potRoast
        } else if item.contains("popcorn") {
            return .popcorn
        } else if item.contains("oats") || item.contains("oat") {
            return .oats
        } else if item.contains("oatmeal") {
            return .oatmeal
        } else if item.contains("mussels") {
            return .mussels
        } else if item.contains("nectarines") {
            return .nectarine
        } else if item.contains("italian") && item.contains("seasoning") {
            return .italianSeasoning
        } else if item.contains("hummus"){
            return .hummus
        } else if item.contains("dip") {
            return .dip
        } else if item.contains("tater") && item.contains("tots") {
            return .taterTots
        } else if item.contains("hot") && (item.contains("dog") || item.contains("dogs")) {
            if item.contains("bun") || item.contains("buns") {
                return .hotDogBuns
            } else {
                return .hotDogs
            }
        } else if item.contains("hamburger") || item.contains("hamburgers") || item.contains("slider") || item.contains("sliders") {
            if item.contains("bun") || item.contains("buns") {
                return .hamburgerBuns
            } else {
                return .hamburgerPatties
            }
        } else if item.contains("icing") || item.contains("frosting") {
            return .icing
        } else if item.contains("crackers") || item.contains("cracker") {
            if item.contains("graham") {
                return .grahamCracker
            } else {
                return .cracker
            }
        } else if item.contains("fennel") {
            return .fennelSeeds
        } else if item.contains("half") && item.count > 1 {
            return .halfAndHalf
        } else if item.contains("pecan") || item.contains("pecans") {
            return .pecan
        } else if item.contains("walnut") || item.contains("walnuts") {
            return .walnuts
        } else if item.contains("raisins") {
            return .raisin
        } else if item.contains("sunflower") && item.contains("seeds") {
            return .sunflowerSeeds
        } else if item.contains("sesame") {
            if item.contains("oil") {
                return .sesameOil
            } else {
                return .sesame
            }
        } else if item.contains("eggplant") || item.contains("eggplants") {
            return .eggplant
        } else if item.contains("lentil") || item.contains("lentils") {
            return .lentil
        } else if item.contains("cornstarch") {
            return .cornstarch
        } else if item.contains("sherry") {
            return .sherry
        } else if item.contains("sprouts") && (item.contains("brussels") || item.contains("brussel")) {
            return .brusselsSprouts
        } else if item.contains("artichoke") || item.contains("artichokes") {
            if item.contains("heart") || item.contains("hearts") {
                return .artichokeHeart
            } else {
                return .artichoke
            }
        } else if item.contains("poppy") && item.contains("seeds") {
            return .poppySeed
        } else if item.contains("dill") && item.contains("weed") {
            return .dillWeed
        } else if item.contains("tortellini") {
            return .tortellini
        } else if item.contains("ravioli") {
            return .ravioli
        } else if item.contains("peas") {
            if item.contains("black") && item.contains("eyes") {
                return .blackEyedPeas
            } else {
                return .peas
            }
            
        } else if item.contains("chives") {
            return .chives
        } else if item.contains("shallot") || item.contains("shallots") {
            return .shallot
        } else if item.contains("alfredo") {
            return .alfredoSauce
        } else if item.contains("pesto") {
            return .pestoSauce
        } else if item.contains("scallops") {
            return .scallops
        } else if item.contains("clams") {
            return .clam
        } else if item.contains("water") && (item.count == 1) {
            return .water
        } else if item.contains("sparkling") && item.contains("water") {
            return .sparklingWater
        } else if item.contains("buttermilk") {
            if item.contains("baking") {
                return .other
            } else {
                return .buttermilk
            }
            
        } else if item.contains("vegetable") && item.contains("broth") {
            return .broth
        } else if item.contains("ranch") {
            return .ranch
        } else if item.contains("salad") {
            if item.contains("dressing") {
                return .saladDressing
            } else {
                return .salad
            }
        } else if item.contains("pastrami") {
            return .pastrami
        } else if item.contains("pepperoni") {
            return .pepperoni
        } else if item.contains("bison") {
            return .bison
        } else if item.contains("monterey") || item.contains("jack") || item.contains("colby") {
            return .montereyJackCheese
        } else if item.contains("cornmeal") {
            return .cornmeal
        } else if item.contains("saltines") || item.contains("saltine") {
            return .saltines
        } else if item.contains("oreo") || item.contains("oreos") {
            return .oreoCookies
        } else if item.contains("applesauce") {
            return .appleSauce
        } else if item.contains("nutella") {
            return .nutella
        } else if item.contains("cornbread") {
            return .cornbread
        } else if item.contains("honeydew") {
            return .honeydew
        } else if item.contains("cantaloupe") {
            return .cantaloupe
        } else if item.contains("taco") && item.contains("seasoning") {
            return .tacoSeasoning
        } else if item.contains("prawns") || item.contains("prawn") {
            return .prawn
        } else if item.contains("dough") {
            return .dough
        } else if item.contains("chestnuts") || item.contains("chestnut") {
            if item.contains("water") {
                return .waterChestnuts
            } else {
                return .chestnuts
            }
        } else if item.contains("tarragon") {
            return .tarragon
        } else if item.contains("pie") && item.contains("crust") {
            return .pieCrust
        } else if item.contains("marshmallows") {
            return .marshmallows
        } else if item.contains("coriander") {
            return .coriander
        } else if item.contains("mint") {
            return .mint
        } else if item.contains("garam") && item.contains("masala") {
            return .garamMasala
        } else if item.contains("coconut") {
            return .coconut
        } else if item.contains("wings") {
            return .chickenWings
        } else if item.contains("rhubarb") {
            return .rhubarb
        } else if item.contains("saffron") {
            return .saffron
        } else if item.contains("kefir") {
            return .kefir
        } else if item.contains("pumpkin") {
            if item.contains("pie") {
                return .other
            } else if item.contains("seeds") {
                return .pumpkinSeeds
            } else {
                return .pumpkin
            }
        } else if item.contains("pepita") || item.contains("pepitas") {
            return .pumpkinSeeds
        } else if item.contains("scallions") || item.contains("scallion") {
            return .greenOnion
        } else if item.contains("cocoa") && item.contains("powder") {
            return .cocoaPowder
        } else if item.contains("broth") || item.contains("stock") || item.contains("bouillon") {
            return .broth
        } else if item.contains("tahini") {
            return .tahini
        } else if item.contains("dates") || item.contains("date") {
            return .dates
        } else if item.contains("spray") && item.contains("cooking") {
            return .cookingSpray
        } else if item.contains("pastry") && item.contains("puff") {
            return .puffPastry
        } else if item.contains("hazelnuts") {
            return .hazelnuts
        } else if item.contains("tequila") {
            return .tequila
        } else if item.contains("chickpeas") {
            return .garbanzoBeans
        } else if item.contains("lemongrass") {
            return .lemongrass
        } else if item.contains("peppercorns") {
            return .blackPepper
        } else if item.contains("elk") {
            return .elk
        } else if item.contains("octopus") {
            return .octopus
        } else if item.contains("flax") || item.contains("flaxseed") || item.contains("flaxseeds") {
            return .flax
        } else if item.contains("pistachio") || item.contains("pistachios") {
            if item.contains("pudding") {
                return .other
            } else {
                return .pistachio
            }
        } else if item.contains("chia") {
            return .chiaSeeds
        } else if item.contains("ground") && item.contains("cloves") {
            return .groundCloves
        } else if item.contains("chard") {
            return .chard
        } else if item.contains("mascarpone") {
            return .mascarpone
        } else if item.contains("flatbread") {
            return .pitaBread
        } else if item.contains("chutney") {
            return .chutney
        } else if item.contains("parsnip") || item.contains("parsnips") {
            return .parsnips
        } else if item.contains("nuts") && item.contains("pine") {
            return .pineNuts
        } else if item.contains("coleslaw") {
            return .coleslaw
        } else if item.contains("couscous") {
            return .couscous
        } else if item.contains("currants") || item.contains("currant") {
            return .currants
        } else if item.contains("wasabi") {
            return .wasabi
        } else if item.contains("macadamia") {
            return .macadamiaNuts
        } else if item.contains("squid") {
            return .squid
        } else if item.contains("calamari") {
            return .calamari
        } else if item.contains("ribs") || item.contains("rib") {
            return .ribs
        } else if item.contains("germ") {
            return .wheatGerm
        } else if item.contains("steak") {
            return .steak
        } else if item.contains("great") && item.contains("northern") {
            return .cannelliniBeans
        }
        
        else {
            return .other
        }
        return .other
    }
}


extension QueryDocumentSnapshot {
    func recipe() -> Recipe {
        let recipe = Recipe(name: self.get("name") as! String, recipeType: self.get("recipeType") as! [String], cuisineType: self.get("cuisineType") as! String, cookTime: self.get("cookTime") as! Int, prepTime: self.get("prepTime") as! Int, ingredients: self.get("ingredients") as! [String], instructions: self.get("instructions") as! [String], calories: self.get("calories") as? Int, numServes: self.get("numServes") as! Int, userID: self.get("userID") as? String, numReviews: self.get("numReviews") as? Int, numStars: self.get("numStars") as? Int, notes: self.get("notes") as? String, tagline: self.get("tagline") as? String, recipeImage: nil, imagePath: self.get("path") as? String, reviewImagePaths: self.get("reviewImagePaths") as? [String])
        return recipe
    }
}
