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




protocol MealPlanRecipeChangedDelegate: class {
    func recipesChanged(month: String)
}



class MealPlanner {
    var id: String?
    var exists: Bool?
    var userIDs: [String]?
    var group: Bool?
    var mealPlanDict: [String:Set<RecipeTransfer>] = [:]
    weak var delegate: MealPlanRecipeChangedDelegate?
    private var db = Firestore.firestore()
    
    
    struct RecipeTransfer: Hashable {
        var date: String
        var id: String
        var name: String
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
        // recipeDict will be for the general dict of all recipe IDs, in the same collection each recipe will be written with the ID
        
        let date = shortDate.shortDateToMonthYear()
        if let id = SharedValues.shared.mealPlannerID {
            let recipeDocReference = db.collection("mealPlanners").document(id).collection("recipes").document()
            recipe.id = recipeDocReference.documentID
            let reference = db.collection("mealPlanners").document(id).collection("schedule").document(date) // use an array, have the date before ID 7.1.19-THISISTHEIDHERE
            reference.setData([
                "recipes": FieldValue.arrayUnion(["\(shortDate)__\(recipe.id)__\(recipe.name)"])
            ], merge: true) { (error) in
                if error == nil {
                    self.addRecipeDocumentoPlanner(reference: recipeDocReference, recipe: recipe, shortDate: shortDate)
                } else {
                    print("Error writing recipe to meal planner: \(error as Any)")
                }
            }
        }
    }
    
    // helper to addRecipeToPlanner
    func addRecipeDocumentoPlanner(reference: DocumentReference, recipe: MPCookbookRecipe, shortDate: String) {
        let ingredients = Array<String>(recipe.ingredients)
        let instructions = Array<String>(recipe.instructions)
        reference.setData([
            "name": recipe.name,
            "cookTime": recipe.cookTime.value as Any,
            "prepTime": recipe.prepTime.value as Any,
            "ingredients": ingredients,
            "instructions": instructions,
            "calories": recipe.calories.value as Any,
            "numServes": recipe.servings.value as Any,
            "notes": recipe.notes as Any,
            "date": recipe.date,
            "ownID": reference.documentID
        ])
    }
    
    
    func listenForMealPlannerRecipes(complete: @escaping (_ bool: Bool) -> Void) {
        if let id = SharedValues.shared.mealPlannerID {
            let refernece = db.collection("mealPlanners").document(id).collection("schedule")
            
            #warning("probbaly for the best if i merge the two calls in this function")
            
            refernece.getDocuments { (querySnapshot, error) in
                guard let docs = querySnapshot?.documents else { complete(false); return }
                
                for doc in docs {
                    guard let recipes = doc.get("recipes") as? [String] else { continue }
                    let monthYear = doc.documentID
                    for recipe in recipes {
                        let recipeParts = recipe.mealPlanReadRecipeHelper()
                        if self.mealPlanDict[monthYear] != nil {
                            self.mealPlanDict[monthYear]!.insert(recipeParts)
                        } else {
                            self.mealPlanDict[monthYear] = [recipeParts]
                        }
                    }
                }
                complete(true)
            }
            
            
            refernece.addSnapshotListener { (querySnapshot, error) in
                guard let snapshot = querySnapshot else { return }
                snapshot.documentChanges.forEach { (diff) in
                    let doc = diff.document
                    let monthYear = doc.documentID
                    var setToCompareForMonth = Set<MealPlanner.RecipeTransfer>()
                    if let recipes = doc.get("recipes") as? [String] {
                        for recipe in recipes {
                            let recipeParts = recipe.mealPlanReadRecipeHelper()
                            setToCompareForMonth.insert(recipeParts)
                        }
                        // Here, set the new value in the dict, set the different UI on the calendar view, make sure recipes are going to be set, dont need to handle individual recipes
                        // Could have something like a dict of months with the associated view, then could pinpoint the specific new that needed to be updated)
                        self.mealPlanDict[monthYear] = setToCompareForMonth
                        self.delegate?.recipesChanged(month: monthYear)
                    }
                }
            }
            
            
            
        } else {
            complete(false)
        }
    }
    
    
    // MARK: UI
    // To get the int value for the first day of the example month from the specific day and weekday from a selected date
    class func getWeekdayForFirstDay(dayNumber: Int, weekday: Int) -> Int {
        guard dayNumber > 7 else { return 1 + (((weekday + 7) - dayNumber) % 7) }
        return getWeekdayForFirstDay(dayNumber: dayNumber % 7, weekday: weekday)
        
    }
    
}

