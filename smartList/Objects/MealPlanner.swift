//
//  MealPlanner.swift
//  smartList
//
//  Created by Steven Dito on 2/1/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import Foundation
import FirebaseFirestore
import RealmSwift

#warning("subclass cookbook recipe, add an enum for meal type with a var and have a new date variable, write to realm if not saved on device, otherwise just read from firebase, sync")




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
    
    
    
    func addRecipeToPlanner(recipe: MPCookbookRecipe, shortDate: String, mealType: MealType) {
        let date = shortDate.shortDateToMonthYear()
        let reference = db.collection("mealPlanners").document(id).collection(date)
            reference.addDocument(data: [
               "name": recipe.name,
               "ingredients": recipe.ingredients,
               "instructions": recipe.instructions,
               "cookTime": recipe.cookTime,
               "prepTime": recipe.prepTime,
               "numServes": recipe.servings,
               "calories": recipe.calories,
               "notes": recipe.notes as Any,
               "date": shortDate,
               "mealType": mealType.rawValue
        ])
    }
    
    
    class func createIndividualMealPlanner(db: Firestore) {
        if let id = SharedValues.shared.userID {
            let reference = db.collection("mealPlanners")
            reference.addDocument(data: [
                "userIDs": [id],
                "createdOn": Date().timeIntervalSince1970
            ]) { (error) in
                if error == nil {
                    // Write the data to the user's profile
                } else {
                    print("Error creating meal planner: \(String(describing: error))")
                }
            }
            
        }
        
    }
    
    
    // MARK: UI
    // To get the int value for the first day of the example month from the specific day and weekday from a selected date
    class func getWeekdayForFirstDay(dayNumber: Int, weekday: Int) -> Int {
        guard dayNumber > 7 else { return 1 + (((weekday + 7) - dayNumber) % 7) }
        return getWeekdayForFirstDay(dayNumber: dayNumber % 7, weekday: weekday)
        
    }
    
}
