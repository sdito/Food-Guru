//
//  Recipe.swift
//  smartList
//
//  Created by Steven Dito on 8/24/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import RealmSwift


struct Recipe {
    var djangoID: Int
    var name: String
    var cookTime: Int
    var prepTime: Int
    var ingredients: [String]
    var instructions: [String]
    var calories: Int?
    var numServes: Int
    var userID: String?
    var numReviews: Int?
    var numStars: Int?
    var notes: String?
    var tagline: String?
    var recipeImage: Data?
    var mainImage: String?
    var thumbImage: String?
    var reviewImagePaths: [String]?
    
    init(djangoID: Int, name: String, cookTime: Int, prepTime: Int, ingredients: [String], instructions: [String], calories: Int?, numServes: Int, userID: String?, numReviews: Int?, numStars: Int?, notes: String?, tagline: String?, recipeImage: Data?, mainImage: String?, thumbImage: String?, reviewImagePaths: [String]?) {
        self.djangoID = djangoID
        self.name = name
        self.cookTime = cookTime
        self.prepTime = prepTime
        self.ingredients = ingredients
        self.instructions = instructions
        self.calories = calories
        self.numServes = numServes
        self.userID = userID
        self.numReviews = numReviews
        self.numStars = numStars
        self.notes = notes
        self.tagline = tagline
        self.recipeImage = recipeImage
        self.mainImage = mainImage
        self.thumbImage = thumbImage
        self.reviewImagePaths = reviewImagePaths
    }
    
    // MARK: General
    
    
    
    mutating func writeToFirestore(db: Firestore!, storage: Storage) {
        let ingredients = self.ingredients
        let doc = db.collection("recipes-external").document()
        self.mainImage = "recipe/\(doc.documentID).jpg"
        doc.setData([
            "djangoID": self.djangoID,
            "name": self.name,
            "cookTime": self.cookTime,
            "prepTime": self.prepTime,
            "totalTime": self.cookTime + self.prepTime,
            "ingredients": self.ingredients,
            "instructions": self.instructions,
            "calories": self.calories as Any,
            "numServes": self.numServes,
            "userID": self.userID as Any,
            "numReviews": self.numReviews as Any,
            "numStars": self.numStars as Any,
            "notes": self.notes as Any,
            "path": self.mainImage as Any,
            "tagline": self.tagline as Any,
            "reviewImagePaths": self.reviewImagePaths as Any,
            "numberIngredients": self.ingredients.count as Any
        ]) { err in
            if err != nil {
                UIApplication.shared.keyWindow?.rootViewController?.createMessageView(color: .red, text: "Failed creating recipe")
            } else {
                print("Document successfully written")
                UIApplication.shared.keyWindow?.rootViewController?.createMessageView(color: Colors.messageGreen, text: "Recipe successfully created")
                // give the items their own line for easier querying
                for item in ingredients {
                    let systemitem = Search.turnIntoSystemItem(string: item)
                    print(systemitem)
                    if systemitem != .other {
                        doc.updateData([
                            "has_\(systemitem)": true
                        ])
                    }
                    
                }
            }
        }
        let uploadReference = Storage.storage().reference(withPath: mainImage ?? "")
        guard let imageData = self.recipeImage else { return }
        let newMetadata = StorageMetadata()
        newMetadata.contentType = "image/jpeg"
        //uploadReference.putData(imageData)
        
        uploadReference.putData(imageData, metadata: newMetadata)
        
        
    }
    
    static func readOneRecipeFrom(id: String, db: Firestore, recipeReturned: @escaping(_ recipe: Recipe) -> Void) {
        let reference = db.collection("recipes").document(id)
        
        reference.getDocument { (documentSnapshot, error) in
            guard let doc = documentSnapshot else { return }
            let recipe = doc.getRecipe()
            recipeReturned(recipe)
        }
    }
    
    func turnRecipeIntoCookbookRecipe() -> CookbookRecipe {
        let cbr = CookbookRecipe()
        let ingredients = List<String>.init()
        let instructions = List<String>.init()
        self.ingredients.forEach({ingredients.append($0)})
        self.instructions.forEach({instructions.append($0)})
        cbr.setUp(name: self.name, servings: RealmOptional(self.numServes), cookTime: RealmOptional(self.cookTime), prepTime: RealmOptional(self.prepTime), calories: RealmOptional(self.calories), ingredients: ingredients, instructions: instructions, notes: self.notes)
        return cbr
    }
    
    func getImageFromStorage(thumb: Bool, imageReturned: @escaping (_ image: UIImage?) -> Void) {
        var image: UIImage?
        var thumbPath = self.mainImage
        if thumb == true {
            thumbPath?.removeLast(4)
            thumbPath?.append(contentsOf: "_200x200.jpg")
        }
        
        
        let storageRef = Storage.storage().reference(withPath: thumbPath ?? "")
        storageRef.getData(maxSize: 4 * 1024 * 1024) { (data, error) in
            if let error = error {
                print("Got an error fetching data: \(error)")
                return
            }
            if let data = data {
                image = UIImage(data: data)
                
            }
            imageReturned(image)
        }
    }
    
    static func getNRecipes(num: Int, db: Firestore, lastDoc: QueryDocumentSnapshot?, recipesReturned: @escaping (_ recipe: [Recipe], _ lastDoc: QueryDocumentSnapshot?) -> Void) {
        #warning("need to get rid of this and use from Network")
        var recipes: [Recipe] = []
        
        var reference: Query {
            if let lastDoc = lastDoc {
                return db.collection("recipes").limit(to: num).start(afterDocument: lastDoc)
            } else {
                return db.collection("recipes").limit(to: num)
            }
        }
        
        reference.getDocuments { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(String(describing: error))")
                return
            }
            
            for doc in documents {
                let r = doc.getRecipe()
                recipes.append(r)
            }
            recipesReturned(recipes, documents.last)
        }
    }
    
    // MARK: Saved recipes
    
    static func addRecipeToSavedRecipes(db: Firestore, str: String) {
        let reference = db.collection("users").document(Auth.auth().currentUser?.uid ?? " ")
        reference.updateData([
            "savedRecipes": FieldValue.arrayUnion([str])
        ])
    }
    static func removeRecipeFromSavedRecipes(db: Firestore, str: String) {
        let reference = db.collection("users").document(Auth.auth().currentUser?.uid ?? " ")
        reference.updateData([
            "savedRecipes": FieldValue.arrayRemove([str])
        ])
    }
    
    static func readUserSavedRecipes(db: Firestore, recipesReturned: @escaping (_ recipe: [Recipe]) -> Void) {
        var recipes: [Recipe] = []
        let reference = db.collection("users").document(Auth.auth().currentUser?.uid ?? " ").collection("savedRecipes")
        reference.getDocuments { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(String(describing: error))")
                return
            }
            for doc in documents {
                let r = doc.getRecipe()
                recipes.append(r)
            }
            recipesReturned(recipes)
        }
    }
    
    
    static func filterSavedRecipesFrom(text: String, savedRecipes: [Recipe]) -> [Recipe] {
        
        if text == "" {
            return savedRecipes
        } else {
            var recipes: [Recipe] = []
            for recipe in savedRecipes {
                if recipe.name.lowercased().contains(text.lowercased()) {
                    recipes.append(recipe)
                }
            }
            return recipes
        }
    }
    
    // MARK: Previous viewed
    
    func addRecipeToRecentlyViewedRecipes(db: Firestore) {
        #warning("need to update this with DJANGO id, basically fix the whole thing")
        DispatchQueue.main.async {
            if let uid = Auth.auth().currentUser?.uid {
                let reference = db.collection("users").document(uid)
                reference.getDocument { (documentSnapshot, error) in
                    guard let doc = documentSnapshot else { return }
                    guard let data = doc.data() else { return }
                    
                    if var dict = data["recentlyViewedRecipes"] as? [String:[String:Any]] {
                        // update the data, already have saved recipes
                        print(dict.keys.count)
                        dict["\(Date().timeIntervalSince1970)"] = ["name": self.name, "path": self.mainImage as Any, "timeIntervalSince1970": Date().timeIntervalSince1970]
                        // should have the dict, just would need to write over the previous dict with this new dict, also might need to delete the oldest entry
                        
                        print(dict.keys.count)
                        if dict.keys.count > 20 {
                            let key = dict.keys.sorted().first
                            dict.removeValue(forKey: key!)
                            
                        }
                        print(dict.keys.count)
                        reference.updateData([
                            "recentlyViewedRecipes" : dict
                        ])
                    } else {
                        // no saved recipes, need to create the dictionary
                        let dict: [String:[String:Any]] = ["\(Date().timeIntervalSince1970)":["name": self.name, "path": self.mainImage as Any, "timeIntervalSince1970": Date().timeIntervalSince1970]]
                        reference.updateData([
                            "recentlyViewedRecipes" : dict
                        ])
                    }
                }
            }
        }
    }
    
    static func readPreviouslyViewedRecipes(db: Firestore) {
        if let uid = Auth.auth().currentUser?.uid {
            let reference = db.collection("users").document(uid)
            reference.getDocument { (documentSnapshot, error) in
                guard let document = documentSnapshot else { return }
                guard let field = document.get("recentlyViewedRecipes") as? [String:[String:Any]] else { return }
                SharedValues.shared.previouslyViewedRecipes = field
            }
        }
    }
    
    
    func addRecipeDocumentToUserProfile(db: Firestore) {
        let id = "\(self.djangoID)"
        guard let userID = SharedValues.shared.userID else { return }
        let reference = db.collection("users").document(userID).collection("savedRecipes").document(id)
        reference.setData([
            "djangoID": self.djangoID,
            "name": self.name,
            "cookTime": self.cookTime,
            "prepTime": self.prepTime,
            "totalTime": self.cookTime + self.prepTime,
            "ingredients": self.ingredients,
            "instructions": self.instructions,
            "calories": self.calories as Any,
            "numServes": self.numServes,
            "notes": self.notes as Any,
            "path": self.mainImage as Any,
            "tagline": self.tagline as Any,
            "thumbImage": self.thumbImage as Any
        ]) { err in
        if let err = err {
            print("Error saving recipe document: \(err)")
        } else {
            print("Document successfully written")
            }
        }
    }
    
    func removeRecipeDocumentFromUserProfile(db: Firestore) {
        let id = "\(self.djangoID)"
        guard let userID = SharedValues.shared.userID else { return }
        let reference = db.collection("users").document(userID).collection("savedRecipes").document(id)
        reference.delete()
    }
    
    // MARK: Parse from URL
    
    
    static func getRecipeInfoFromURLallRecipes(recipeURL: String) {
        DispatchQueue.global(qos: .background).async {
            
            guard let url = URL(string: recipeURL) else {
                NotificationCenter.default.post(name: .recipeNotFoundFromURLalert, object: nil)
                return
            }
            
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                guard let data = data else {
                    NotificationCenter.default.post(name: .recipeNotFoundFromURLalert, object: nil)
                    return
                }
                guard let htmlString = String(data: data, encoding: .utf8) else {
                    NotificationCenter.default.post(name: .recipeNotFoundFromURLalert, object: nil)
                    return
                }
                
                guard let leftSideIngredients = htmlString.range(of: "=\"lst_ingredients_1\">") else {
                    print("Trouble finding left side -- ingredients")
                    Recipe.getRecipeInfoFromURL_allRecipesTwo(recipeURL: recipeURL)
                    return
                }
                guard let rightSideIngredients = htmlString.range(of: ">Add all ingredients to list</span>") else {
                    NotificationCenter.default.post(name: .recipeNotFoundFromURLalert, object: nil)
                    return
                }
                
                guard let leftSideDirections = htmlString.range(of: "<div class=\"directions--section\">") else {
                    NotificationCenter.default.post(name: .recipeNotFoundFromURLalert, object: nil)
                    return
                }
                
                guard let rightSideDirections = htmlString.range(of: "<div class=\"directions--section__right-side\">") else {
                    NotificationCenter.default.post(name: .recipeNotFoundFromURLalert, object: nil)
                    return
                }
                
                let rangeOfIngredientText = leftSideIngredients.upperBound..<rightSideIngredients.lowerBound
                
                
                let ingredientText = String(htmlString[rangeOfIngredientText])
                print(ingredientText)
                var finalIngredients: [String] = []
                
                DispatchQueue.main.async {
                    print(ingredientText)
                    finalIngredients = ingredientText.getIngredientsFromString(ingredients: [])
                }
                
                
                
                let rangeOfDirectionText = leftSideDirections.upperBound..<rightSideDirections.lowerBound
                let instructionText = String(htmlString[rangeOfDirectionText])
                let finalInstructions = instructionText.getInstructionsFromString(instructions: [])
                
                
                let cookTime = instructionText.getCookTime()
                let prepTime = instructionText.getPrepTime()
                
                let title = htmlString.getTitleFromHTML()
                
                let calories = htmlString.getCaloriesFromHTML()
                
                let servings = htmlString.getServingsFromHTML()
                
                
                let dict: [String:Any] = [
                    "title": title,
                    "ingredients": finalIngredients,
                    "instructions": finalInstructions,
                    "cookTime": cookTime as Any,
                    "prepTime": prepTime as Any,
                    "calories": calories as Any,
                    "servings": servings as Any
                ]
                
                NotificationCenter.default.post(name: .recipeDataFromURLReceived, object: nil, userInfo: dict)

            }
            
            task.resume()
        
            
        }
        
    }
    
   
    
    
    
    static func getRecipeInfoFromURL_allRecipesTwo(recipeURL: String) {
        
        // for the second type of webpage from allrecipes
        
        let url = URL(string: recipeURL)!

        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                NotificationCenter.default.post(name: .recipeNotFoundFromURLalert, object: nil)
                return
            }
            guard let htmlString = String(data: data, encoding: .utf8) else {
                NotificationCenter.default.post(name: .recipeNotFoundFromURLalert, object: nil)
                return
            }
            
            let leftSideString = "[{\"@context\""
            
            let rightSideString = "[{\"@type\":\"Review\""
            
            guard let leftSideRange = htmlString.range(of: leftSideString) else {
                NotificationCenter.default.post(name: .recipeNotFoundFromURLalert, object: nil)
                return
            }
            
            guard let rightSideRange = htmlString.range(of: rightSideString) else {
                NotificationCenter.default.post(name: .recipeNotFoundFromURLalert, object: nil)
                return
            }
            
            let rangeOfTheData = leftSideRange.upperBound..<rightSideRange.lowerBound
            
            // Text to grab is the shortened version of all the data, so there will be less collisions and less of the string to search
            let textToGrab = String(htmlString[rangeOfTheData])
            
            
            guard let leftSideIngredients = textToGrab.range(of: "\"recipeIngredient\":") else { return }
            guard let rightSideIngredients = textToGrab.range(of: ",\"recipeInstructions\"") else { return }
            let ingredientRange = leftSideIngredients.upperBound..<rightSideIngredients.lowerBound
            let ingredientText = String(textToGrab[ingredientRange])
            let finalIngredients = ingredientText.getIngredientsFromHTML_ARTWO()
            
            guard let leftSideInstructions = textToGrab.range(of: "\"recipeInstructions\":") else { return }
            guard let rightSideInstructions = textToGrab.range(of: ",\"recipeCategory\":") else { return }
            
            let instructionRange = leftSideInstructions.upperBound..<rightSideInstructions.lowerBound
            let instructionText = String(textToGrab[instructionRange])
            let finalInstructions = instructionText.getInstructionsFromHTML_ARTWO([])
            
            let finalServings = htmlString.getServingsFromHTML_ARTWO()
            let finalTitle = htmlString.getTitleFromHTML()
            let finalCookTime = textToGrab.getCookTimeARTWO()
            let finalPrepTime = textToGrab.getPrepTimeARTWO()
            let finalCalories = textToGrab.getCaloriesFromHTML_ARTWO()
            
            // Could get more things in the future, such as notes or image
            let dict: [String:Any] = [
                "title": finalTitle,
                "ingredients": finalIngredients,
                "instructions": finalInstructions as Any,
                "cookTime": finalCookTime as Any,
                "prepTime": finalPrepTime as Any,
                "calories": finalCalories as Any,
                "servings": finalServings as Any
            ]
            
            NotificationCenter.default.post(name: .recipeDataFromURLReceived, object: nil, userInfo: dict)
        }
        task.resume()
    }
    
    // MARK: Review
    
    func updateRecipeReviewInfo(stars: Int, reviews: Int, db: Firestore) {
        
        let recipeID = self.mainImage?.imagePathToDocID()
        let starsValue = self.numStars
        let reviewsValue = self.numReviews
        
        if starsValue == nil || reviewsValue == nil {
            db.collection("recipes").document(recipeID ?? " ").updateData([
                "numReviews": reviews,
                "numStars": stars
            ])
        } else {
            if var starsValue = starsValue, var reviewsValue = reviewsValue {
                starsValue += stars
                reviewsValue += reviews
                db.collection("recipes").document(recipeID ?? " ").updateData([
                    "numStars": starsValue,
                    "numReviews": reviewsValue
                ])
            } else {
                print("Error - updateRecipeReviewInfo(stars: Int, reviews: Int, db: Firestore)")
            }
        }
    }
    
    func addReviewToRecipe(stars: Int, review: String?, db: Firestore) {
        let recipeID = self.mainImage?.imagePathToDocID()
        var hasTextReview: Bool {
            if review == nil || review == "" {
                return false
            } else {
                return true
            }
        }
        let reference = db.collection("recipes").document(recipeID ?? " ").collection("reviews").document()
        reference.setData([
            "stars": stars,
            "review": review as Any,
            "user": Auth.auth().currentUser?.uid as Any,
            "timeIntervalSince1970": Date().timeIntervalSince1970,
            "hasText": hasTextReview
        ]) {err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written")
                User.getNameFromUid(db: db, uid: self.userID ?? " ") { (name) in
                    reference.updateData([
                        "name": name as Any
                    ])
                }
                self.updateRecipeReviewInfo(stars: stars, reviews: 1, db: db)
                
                // do the recalculation stuff here
                
            }
        }
    }
    
    // MARK: UI
    
    func addButtonIngredientViewsTo(stackView: UIStackView, delegateVC: UIViewController) {
        for item in self.ingredients {
            let v = Bundle.main.loadNibNamed("ButtonIngredientView", owner: nil, options: nil)?.first as! ButtonIngredientView
            
            v.setUI(ingredient: item)
            v.delegate = delegateVC as? ButtonIngredientViewDelegate
            stackView.insertArrangedSubview(v, at: 1)
        }
    }
    func addInstructionsToInstructionStackView(stackView: UIStackView) {
        var counter = 1
        for item in self.instructions {
            let v = Bundle.main.loadNibNamed("LabelInstructionView", owner: nil, options: nil)?.first as! LabelInstructionView
            v.setUI(num: counter, instr: item)
            stackView.insertArrangedSubview(v, at: stackView.subviews.count)
            counter += 1
        }
    }
    
}

extension DocumentSnapshot {
    func getRecipe() -> Recipe {
        let r = Recipe(djangoID: self.get("djangoID") as? Int ?? -1,
                       name: self.get("name") as! String,
                       cookTime: self.get("cookTime") as! Int,
                       prepTime: self.get("prepTime") as! Int,
                       ingredients: self.get("ingredients") as! [String],
                       instructions: self.get("instructions") as! [String],
                       calories: self.get("calories") as? Int,
                       numServes: self.get("numServes") as! Int,
                       userID: self.get("userID") as? String,
                       numReviews: self.get("numReviews") as? Int,
                       numStars: self.get("numStars") as? Int,
                       notes: self.get("notes") as? String,
                       tagline: self.get("tagline") as? String,
                       recipeImage: nil,
                       mainImage: self.get("path") as? String,
                       thumbImage: self.get("thumbImage") as? String,
                       reviewImagePaths: self.get("reviewImagePaths") as? [String])
        return r
    }
}


