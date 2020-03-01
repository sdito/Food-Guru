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



class MealPlanner {
    var id: String?
    var exists: Bool?
    var userIDs: [String]?
    var group: Bool?
    var recipes: [MPCookbookRecipe]?
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
    
    func getMealPlannerRecipes() {
        let realm = try? Realm()
        if let realm = realm {
            // Should use a listener to automatically update the objects
            recipes = Array(realm.objects(MPCookbookRecipe.self))
            
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
                    var uids: [String]? = []
                    self.exists = true
                    self.group = true
                    for email in groupEmails {
                        // need to get the user's id
                        User.turnEmailToUid(db: self.db, email: email) { (uid) in
                            if let uid = uid {
                                uids?.append(uid)
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
                            self.userIDs = uids
                        }
                        
                    }
                } else {
                    print("Error creating group meal planner: \(String(describing: error))")
                }
            }
        }
    }
    
    func addRecipeToPlanner(recipe: MPCookbookRecipe, shortDate: String, mealType: MealType) {
        
        // going to switch it up
        // need to write it to a dict like this for eery month -> if var dict = data["recentlyViewedRecipes"] as? [String:[String:Any]]
        // would need to edit the dict for every recipe that is added or deleted to it
        // would also need to write each recipe (with the id) to a general collection where the recipes could be downloaded from
        // have the user read the dict, when they select a recipe if they dont have it in realm then they need to downlaod teh recipe, else just show the recipe
        // _recipeDict will be for the general dict of all recipe IDs, in the same collection each recipe will be written with the ID
        
        /*
         let dict: [String:[String:Any]] = ["\(Date().timeIntervalSince1970)":["name": self.name, "path": self.imagePath as Any, "timeIntervalSince1970": Date().timeIntervalSince1970]]
         reference.updateData([
             "recentlyViewedRecipes" : dict
         ])
         */
        let date = shortDate.shortDateToMonthYear()
        if let id = SharedValues.shared.mealPlannerID {
            let reference = db.collection("mealPlanners").document(id).collection(date).document("_recipeDict")
            
        }
        /*
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
                    
                }
            }
        }
        */
        
    }
    
    func listenForNewRecipesAddedToMealPlannerToWriteToRealm() {
        #warning("need to use a unique device identifier here, or in the user's profile, to ensure each device could download them, in realm need to seperate them by account")
        if let uid = SharedValues.shared.userID {
            let reference = db.collection("users").document(uid).collection("mealPlanner-new")
            reference.getDocuments { (querySnapshot, error) in
                guard let docs = querySnapshot?.documents else { print(error as Any); return }
                for doc in docs {
                    let mpCookbookRecipe = doc.getMPCookbookRecipe()
                    mpCookbookRecipe.write()
                    let refToDelete = self.db.collection("users").document(uid).collection("mealPlanner-new").document(doc.documentID)
                    refToDelete.delete()
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

