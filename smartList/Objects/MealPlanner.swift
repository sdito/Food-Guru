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
    
    func createIndividualMealPlanner() {
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
                    let reference = self.db.collection("users").document(id)
                    reference.updateData([
                        "mealPlannerID": reference.documentID
                    ])
                } else {
                    print("Error creating meal planner: \(String(describing: error))")
                }
            }
        }
    }
    
    func createGroupMealPlanner() {
        if let groupEmails = SharedValues.shared.groupEmails {
            let reference = db.collection("mealPlanners").document()
            reference.setData([
                "userIDs": [],
                "group": true
            ]) { error in
                if error == nil {
                    self.exists = true
                    self.group = true
                    for email in groupEmails {
                        // need to get the user's id
                        User.turnEmailToUid(db: self.db, email: email) { (uid) in
                            if let uid = uid {
                                // need to add the user's id to the main meal planner document
                                reference.updateData([
                                    "userIDs" : FieldValue.arrayUnion([uid])
                                ]) { error in
                                    if error == nil {
                                        // need to update the user's profile with the meal planner doc id
                                        let userRef = self.db.collection("users").document(uid)
                                        userRef.updateData([
                                            "mealPlannerID": reference.documentID
                                        ])
                                    }
                                }
                            }
                            self.userIDs?.append(email)
                        }
                    }
                } else {
                    print("Error creating group meal planner: \(String(describing: error))")
                }
            }
        }
    }
    
    func addRecipeToPlanner(db: Firestore, recipe: MPCookbookRecipe, shortDate: String, mealType: MealType) {
        let date = shortDate.shortDateToMonthYear()
        print("Writing meal plan recipe to firestore on \(date)")
        if let id = SharedValues.shared.mealPlannerID {
            let reference = db.collection("mealPlanners").document(id).collection(date).document()
            reference.setData([
               "name": recipe.name,
               "ingredients": Array(recipe.ingredients),
               "instructions": Array(recipe.instructions),
               "cookTime": recipe.cookTime.value as Any,
               "prepTime": recipe.prepTime.value as Any,
               "numServes": recipe.servings.value as Any,
               "calories": recipe.calories.value as Any,
               "notes": recipe.notes as Any,
               "date": shortDate,
               "mealType": mealType.rawValue,
               "id": reference.documentID
            ]) { error in
                if error == nil {
                    recipe.id = reference.documentID
                    if self.group == true, let uids = self.userIDs {
                        for id in uids {
                            if id != SharedValues.shared.userID {
                                MealPlanner.writeRecipeToUsersProfile(db: db, id: reference.documentID, recipe: recipe, shortDate: shortDate, mealType: mealType, userID: id)
                            }
                        }
                    }
                }
            }
        }
    }
    
    class func writeRecipeToUsersProfile(db: Firestore, id: String, recipe: MPCookbookRecipe, shortDate: String, mealType: MealType, userID: String) {
        #warning("need to do additional testing on this")
        print("Need to add to user's document: \(userID)")
        let reference = db.collection("users").document(id).collection("mealPlanner-new").document(recipe.id)
        reference.setData([
            "name": recipe.name,
            "ingredients": Array(recipe.ingredients),
            "instructions": Array(recipe.instructions),
            "cookTime": recipe.cookTime.value as Any,
            "prepTime": recipe.prepTime.value as Any,
            "numServes": recipe.servings.value as Any,
            "calories": recipe.calories.value as Any,
            "notes": recipe.notes as Any,
            "date": shortDate,
            "mealType": mealType.rawValue,
            "id": reference.documentID
        ])
    }
    
    // MARK: UI
    // To get the int value for the first day of the example month from the specific day and weekday from a selected date
    class func getWeekdayForFirstDay(dayNumber: Int, weekday: Int) -> Int {
        guard dayNumber > 7 else { return 1 + (((weekday + 7) - dayNumber) % 7) }
        return getWeekdayForFirstDay(dayNumber: dayNumber % 7, weekday: weekday)
        
    }
    
}
