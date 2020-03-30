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




protocol MealPlanDelegate: class {
    func recipesChanged(month: String)
    func mealPlannerCreated()
}



class MealPlanner {
    var id: String?
    var exists: Bool?
    var userIDs: [String]?
    var group: Bool?
    var mealPlanDict: [String:Set<RecipeTransfer>] = [:]
    var recipeListener: ListenerRegistration?
    weak var delegate: MealPlanDelegate?
    private var db = Firestore.firestore()
    
    
    struct RecipeTransfer: Hashable {
        var date: String
        var id: String
        var name: String
        var metadata: String?
    }
    
    // MARK: Creation
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
                    self.delegate?.mealPlannerCreated()
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
                    self.delegate?.mealPlannerCreated()
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
    
    // MARK: Recipes
    
    func addRecipeToPlanner(recipe: MPCookbookRecipe, shortDate: String, mealType: MealType, previousID: String?) {
        
        // going to switch it up
        // need to write it to a dict like this for eery month -> if var dict = data["recentlyViewedRecipes"] as? [String:[String:Any]]
        // would need to edit the dict for every recipe that is added or deleted to it
        // would also need to write each recipe (with the id) to a general collection where the recipes could be downloaded from
        // have the user read the dict, when they select a recipe if they dont have it in realm then they need to downlaod teh recipe, else just show the recipe
        // recipeDict will be for the general dict of all recipe IDs, in the same collection each recipe will be written with the ID
        
        let date = shortDate.shortDateToMonthYear()
        if let id = SharedValues.shared.mealPlannerID {
            
            var recipeDocReference: DocumentReference {
                if previousID != nil {
                    return db.collection("mealPlanners").document(id).collection("recipes").document(previousID!)
                } else {
                    return db.collection("mealPlanners").document(id).collection("recipes").document()
                }
            }

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
    
    func addNoteToPlanner(shortDate: String, note: String) {
        print("From note func: \(shortDate), \(note)")
        if let id = SharedValues.shared.mealPlannerID {
            let date = shortDate.shortDateToMonthYear()
            let reference = db.collection("mealPlanners").document(id).collection("schedule").document(date)
            let noteID = String.randomString(length: 20)
            reference.setData([
                "recipes": FieldValue.arrayUnion(["\(shortDate)__\(noteID)__\(note)__note"])
            ], merge: true) { (error) in
                if error == nil {
                    print("Note successfully written to meal planner")
                } else {
                    print("Error writing note to meal planner")
                }
            }
            
        }
    }
    
    // helper to addRecipeToPlanner
    private func addRecipeDocumentoPlanner(reference: DocumentReference, recipe: MPCookbookRecipe, shortDate: String) {
        
        let ingredients = Array<String>(recipe.ingredients)
        let instructions = Array<String>(recipe.instructions)
        
        if reference.documentID == recipe.id {
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
        } else {
            if let id = SharedValues.shared.mealPlannerID {
                let correctedReference = db.collection("mealPlanners").document(id).collection("recipes").document(recipe.id)
                correctedReference.setData([
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
            
            
        }
        
        
    }
    
    func removeRecipeFromPlanner(recipe: RecipeTransfer) {
        
        // delete recipe from (3 things) [first], schedule in meal planners [second], recipes in meal planners [third], delete from realm
        
        if let id = SharedValues.shared.mealPlannerID {
            
            // delete from realm, if exists in realm
            let realm = try? Realm()
            do {
                try realm?.write {
                    if let object = realm?.object(ofType: MPCookbookRecipe.self, forPrimaryKey: recipe.id) {
                        realm?.delete(object)
                    }
                }
            } catch {
                print("Error deleting from realm: \(error)")
            }
            
            // delete from schedule
            let documentMonthYear = recipe.date.shortDateToMonthYear()
            
            var firebaseRecipeFormat: String {
                if recipe.metadata == "note" {
                    return "\(recipe.date)__\(recipe.id)__\(recipe.name)__note"
                } else {
                    return "\(recipe.date)__\(recipe.id)__\(recipe.name)"
                }
            }
            
            
            let scheduleReference = db.collection("mealPlanners").document(id).collection("schedule").document(documentMonthYear)
            scheduleReference.updateData([
                "recipes": FieldValue.arrayRemove([firebaseRecipeFormat])
            ]) { err in
                if err == nil {
                    // delete from recipes in meal planner
                    
                    let recipeReference = self.db.collection("mealPlanners").document(id).collection("recipes").document(recipe.id)
                    
                    recipeReference.delete() { err in
                        if err == nil {
                            print("Both successfully deleted from recipes and scheudle")
                        } else {
                            print("Recipe not successfully deleted from recipes, but deleted from schedule")
                        }
                    }
                    
                } else {
                    print("Error deleting recipe from schedule: \(err as Any)")
                }
            }
            
        }
        
    }
    
    func changeDateForRecipe(recipe: MealPlanner.RecipeTransfer, newDate: Date, copyRecipe: Bool) {
        if let id = SharedValues.shared.mealPlannerID {
            
            // first delete the recipe with the old informaiton, only if copy is false which means original needs to be deleted
            if copyRecipe == false {
                let oldMonthYear = recipe.date.shortDateToMonthYear()
                let oldScheduleReference = db.collection("mealPlanners").document(id).collection("schedule").document(oldMonthYear)
                
                var oldDbFormat: String {
                    if recipe.metadata == "note" {
                        return "\(recipe.date)__\(recipe.id)__\(recipe.name)__note"
                    } else {
                        return "\(recipe.date)__\(recipe.id)__\(recipe.name)"
                    }
                }
                
                oldScheduleReference.updateData([
                    "recipes": FieldValue.arrayRemove([oldDbFormat])
                ])
            }
            
            
            // then write the recipe with the new information to schedule
            let newShortDate = newDate.dbFormat()
            let newMonthYear = newShortDate.shortDateToMonthYear()
            let newScheduleReference = db.collection("mealPlanners").document(id).collection("schedule").document(newMonthYear)
            
            var newDbFormat: String {
                if recipe.metadata == "note" {
                    return "\(newShortDate)__\(recipe.id)__\(recipe.name)__note"
                } else {
                    return "\(newShortDate)__\(recipe.id)__\(recipe.name)"
                }
            }
            
            newScheduleReference.updateData([
                "recipes" : FieldValue.arrayUnion([newDbFormat])
            ]) { (err) in
                if err != nil {
                    // update failed becuase document didnt exist, need to create new scheudle document and write the data there
                    newScheduleReference.setData([
                        "recipes": [newDbFormat]
                    ])
                }
            }
            
        }
    }
    
    
    
    func getMealPlannerRecipes(complete: @escaping (_ bool: Bool) -> Void) {
        if let id = SharedValues.shared.mealPlannerID {
            let refernece = db.collection("mealPlanners").document(id).collection("schedule")
            
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

            listenForMealPlanRecipes()

        } else {
            complete(false)
        }
    }
    
    func listenForMealPlanRecipes() {
        
        if let id = SharedValues.shared.mealPlannerID {
            let refernece = db.collection("mealPlanners").document(id).collection("schedule")
            recipeListener?.remove()
            recipeListener = refernece.addSnapshotListener { (querySnapshot, error) in
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
        }
        
    }
    
    class func deleteAllItems(db: Firestore, id: String) {
        
        let recipeReference = db.collection("mealPlanners").document(id).collection("recipes")
        let scheduleReference = db.collection("mealPlanners").document(id).collection("schedule")
        
        recipeReference.getDocuments { (querySnapshot, error) in
            if let documents = querySnapshot?.documents {
                documents.forEach { (doc) in
                    recipeReference.document(doc.documentID).delete()
                }
            }
        }
        
        scheduleReference.getDocuments { (querySnapshot, error) in
            if let documents = querySnapshot?.documents {
                documents.forEach { (doc) in
                    let ref = scheduleReference.document(doc.documentID)
                    ref.updateData([
                        "recipes" : FieldValue.delete()
                    ])
                }
            }
        }
    }
    
    // MARK: Lists
    
    
    
    
    func addItemsToListFromCertainDay(shortDate: String, calledFrom: UIViewController) {
        
        
        
        // First, get all the items that need to be added
        getIngredientsForMPlistAdding(shortDate: shortDate) { (ingredientsToAddToList) in
            // seems like this works
            // Second, add all the items to the list
            print(ingredientsToAddToList)
            if let uid = SharedValues.shared.userID {
                GroceryList.getUsersCurrentList(db: self.db, userID: uid) { (list) in
                    if let list = list {
                        if list.stores?.isEmpty == true {
                            for item in ingredientsToAddToList {
                                GroceryList.addItemToListFromRecipe(db: self.db, listID: list.ownID ?? " ", name: item, userID: uid, store: "")
                            }
                            calledFrom.createMessageView(color: Colors.messageGreen, text: "Items added to list!")
                        } else if list.stores?.count == 1 {
                            for item in ingredientsToAddToList {
                                GroceryList.addItemToListFromRecipe(db: self.db, listID: list.ownID ?? " ", name: item, userID: uid, store: list.stores!.first!)
                            }
                            calledFrom.createMessageView(color: Colors.messageGreen, text: "Items added to list!")
                        } else {

                            calledFrom.createPickerView(itemNames: ingredientsToAddToList, itemStores: list.stores, itemListID: list.ownID ?? " ", singleItem: false, delegateVC: calledFrom)
                        }
                    } else {
                        GroceryList.handleProcessForAutomaticallyGeneratedListFromRecipe(db: self.db, items: ingredientsToAddToList)
                        calledFrom.createMessageView(color: Colors.messageGreen, text: "List created and items added!")
                    }
                }
            }
        }
        
        
    }
    
    private func getIngredientsForMPlistAdding(shortDate: String, ingredientsReturned: @escaping (_ ingredients: [String]) -> Void) {
        let realm = try? Realm()
        var ingredientsToAddToList: [String] = []
        let recipes = self.mealPlanDict[shortDate.shortDateToMonthYear()]?.filter({$0.date == shortDate && $0.metadata != "note"})
        var count = 0
        
        if let recipes = recipes {
            for recipe in recipes {
                if let realmRecipe = realm?.object(ofType: MPCookbookRecipe.self, forPrimaryKey: recipe.id) {
                    // recipe is already downloaded
                    let ings = Array(realmRecipe.ingredients)
                    ingredientsToAddToList += ings
                    count += 1
                    if count == recipes.count {
                        ingredientsReturned(ingredientsToAddToList)
                    }
                } else {
                    // need to download recipe (and might as well write to realm), then add the ingredients
                    if let id = SharedValues.shared.mealPlannerID {
                        let reference = db.collection("mealPlanners").document(id).collection("recipes").document(recipe.id)
                        reference.getDocument { (documentSnapshot, error) in
                            guard let doc = documentSnapshot else { return }
                            let newRecipe = doc.getMPCookbookRecipe()
                            newRecipe.write()
                            ingredientsToAddToList += Array(newRecipe.ingredients)
                            count += 1
                            if count == recipes.count {
                                ingredientsReturned(ingredientsToAddToList)
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: Changes
    class func handleMealPlannerForGroupChangeOrNewGroup(db: Firestore, oldEmails: [String]?, newEmails: [String], mealPlannerID: String?) {
        
        #warning("need to do slightly more testing to ensure this is working as intended")
        // If old emails is nil, then this was a brand new group, use the users meal planner (if it exists) for the new meal planner
        // If old emails exist, need to nil out every meal planner ID
        // For both cases, in newEmails need to write the mealPlannerID to every user's profile
        print("MP Change being called: oldEmails: \(oldEmails?.joined(separator: ", ") ?? " none"), newEmails: \(newEmails.joined(separator: ", "))")
        
        
        
        // to remove the old mealPlannerID value from the previous emails
        if let oldEmails = oldEmails {
            oldEmails.forEach { (email) in
                db.collection("users").whereField("email", isEqualTo: email).getDocuments { (querySnapshot, error) in
                    guard let doc = querySnapshot?.documents.first else { return }
                    if let uid = doc.get("uid") as? String {
                        let userRef = db.collection("users").document(uid)
                        userRef.updateData([
                            "mealPlannerID" : FieldValue.delete()
                        ])
                    }
                }
            }
        }
        
        
        if let mealPlannerID = mealPlannerID {
            // update the mealPlanner document
            let mpRef = db.collection("mealPlanners").document(mealPlannerID)
            mpRef.updateData([
                "userIDs" : FieldValue.delete()
            ])
            // update the user's profiles
            newEmails.forEach { (email) in
                db.collection("users").whereField("email", isEqualTo: email).getDocuments { (querySnapshot, error) in
                    guard let doc = querySnapshot?.documents.first else { return }
                    if let uid = doc.get("uid") as? String {
                        let userRef = db.collection("users").document(uid)
                        userRef.updateData([
                            "mealPlannerID" : mealPlannerID
                        ])
                        // add uid to ref
                        mpRef.updateData([
                            "userIDs" : FieldValue.arrayUnion([uid])
                        ])
                    }
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


extension Array where Element == MealPlanner.RecipeTransfer {
    func sortNoteFirstAlphabetical() -> [MealPlanner.RecipeTransfer] {
        // Have notes first, sort everything alphabetically, if same letters then sort by ID
        var notes: [MealPlanner.RecipeTransfer] = []
        var recipes: [MealPlanner.RecipeTransfer] = []
        
        for a in self {
            if a.metadata == "note" {
                notes.append(a)
            } else {
                recipes.append(a)
            }
        }
        notes = notes.sorted(by: { (one, two) -> Bool in
            if one.name != two.name {
                return one.name < two.name
            } else {
                return one.id < two.id
            }
        })
        
        recipes = recipes.sorted(by: { (one, two) -> Bool in
            if one.name != two.name {
                return one.name < two.name
            } else {
                return one.id < two.id
            }
        })
        
        return notes + recipes
    }
}
