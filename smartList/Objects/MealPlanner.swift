//
//  MealPlanner.swift
//  smartList
//
//  Created by Steven Dito on 2/1/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import Foundation
import FirebaseFirestore



class MealPlanner {
    
    let id: String
    var userIDs: [String]
    var group: Bool
    private var db = Firestore.firestore()
    
    init(userIDs: [String], group: Bool, id: String) {
        self.userIDs = userIDs
        self.group = group
        self.id = id
    }
    
    
    
    func addRecipeToPlanner(recipe: CookbookRecipe) {
        #warning("need to have something with recipe ID")
        for uid in userIDs {
            let reference = db.collection("mealPlanners").document(id).collection("\(uid)-add")
            reference.addDocument(data: [
                "name": recipe.name,
                "ingredients": recipe.ingredients,
                "instructions": recipe.instructions,
                "cookTime": recipe.cookTime,
                "prepTime": recipe.prepTime,
                "numServes": recipe.servings,
                "calories": recipe.calories,
                "notes": recipe.notes as Any
            ])
        }
    }
    
    
    // MARK: UI
    // To get the int value for the first day of the example month from the specific day and weekday from a selected date
    class func getWeekdayForFirstDay(dayNumber: Int, weekday: Int) -> Int {
        guard dayNumber > 7 else { return 1 + (((weekday + 7) - dayNumber) % 7) }
        return getWeekdayForFirstDay(dayNumber: dayNumber % 7, weekday: weekday)
        
    }
    
}
