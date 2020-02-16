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
    var id: String?
    var exists: Bool?
    var userIDs: [String]?
    var group: Bool?
    private var db = Firestore.firestore()
    
    func addRecipeToPlanner(recipe: MPCookbookRecipe, shortDate: String, mealType: MealType) {
        let date = shortDate.shortDateToMonthYear()
        if let id = id {
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
        
    }
    
    
    func readIfUserHasMealPlanner() {
        if let id = SharedValues.shared.userID {
            let reference = db.collection("users").document(id)
            reference.getDocument { (documentSnapshot, error) in
                guard let docSnapshot = documentSnapshot else { self.exists = false; return }
                if let mealPlannerID = docSnapshot.get("mealPlannerID") as? String {
                    self.exists = true
                    let ref = self.db.collection("mealPlanners").document(mealPlannerID)
                    ref.getDocument { (mealPlannerSnapshot, error) in
                        guard let mp = mealPlannerSnapshot else { self.exists = false; return }
                        if let uids = mp.get("userIDs") as? [String], let isGroup = mp.get("group") as? Bool {
                            self.id = mp.documentID
                            self.userIDs = uids
                            self.group = isGroup
                            self.exists = true
                        } else {
                            self.exists = false
                        }
                    }
                } else {
                    self.exists = false
                }
            }
        }
    }
    
    func createIndividualMealPlanner(db: Firestore) {
        if let id = SharedValues.shared.userID {
            let reference = db.collection("mealPlanners")
            reference.addDocument(data: [
                "userIDs": [id],
                "group": false
            ]) { (error) in
                if error == nil {
                    self.exists = true
                    self.userIDs = [id]
                    self.group = false
                    let reference = db.collection("users").document(id)
                    reference.updateData([
                        "mealPlannerID": reference.documentID
                    ])
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
