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
    var name: String
    var recipeType: [String]
    var cuisineType: String
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
    var imagePath: String?
    var reviewImagePaths: [String]?
    
    init(name: String, recipeType: [String], cuisineType: String, cookTime: Int, prepTime: Int, ingredients: [String], instructions: [String], calories: Int?, numServes: Int, userID: String?, numReviews: Int?, numStars: Int?, notes: String?, tagline: String?, recipeImage: Data?, imagePath: String?, reviewImagePaths: [String]?) {
        self.name = name
        self.recipeType = recipeType
        self.cuisineType = cuisineType
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
        self.imagePath = imagePath
        self.reviewImagePaths = reviewImagePaths
    }
    

    
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
                let r = Recipe(name: doc.get("name") as! String, recipeType: doc.get("recipeType") as! [String], cuisineType: doc.get("cuisineType") as! String, cookTime: doc.get("cookTime") as! Int, prepTime: doc.get("prepTime") as! Int, ingredients: doc.get("ingredients") as! [String], instructions: doc.get("instructions") as! [String], calories: doc.get("calories") as? Int, numServes: doc.get("numServes") as! Int, userID: doc.get("userID") as? String, numReviews: doc.get("numReviews") as? Int, numStars: doc.get("numStars") as? Int, notes: doc.get("notes") as? String, tagline: doc.get("tagline") as? String, recipeImage: nil, imagePath: doc.get("path") as? String, reviewImagePaths: doc.get("reviewImagePaths") as? [String])
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
    
    
    static func getRecipeInfoFromURLallRecipes(recipeURL: String) {
        guard let url = URL(string: recipeURL) else {
            print("No URL entered")
            return
        }
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                print("data was nil")
                return
            }
            guard let htmlString = String(data: data, encoding: .utf8) else {
                print("couldn't cast data into String")
                return
            }
            
            guard let leftSideIngredients = htmlString.range(of: "=\"lst_ingredients_1\">") else {
                print("Trouble finding left side -- ingredients")
                Recipe.getRecipeInfoFromURL_allRecipesTwo(recipeURL: recipeURL)
                return
            }
            guard let rightSideIngredients = htmlString.range(of: ">Add all ingredients to list</span>") else {
                print("Trouble finding right side -- ingredients")
                return
            }
            
            guard let leftSideDirections = htmlString.range(of: "<div class=\"directions--section\">") else {
                print("Trouble finding left side -- directions")
                return
            }
            
            guard let rightSideDirections = htmlString.range(of: "<div class=\"directions--section__right-side\">") else {
                print("Trouble finding right side -- directions")
                return
            }
            
            let rangeOfIngredientText = leftSideIngredients.upperBound..<rightSideIngredients.lowerBound
            let ingredientText = String(htmlString[rangeOfIngredientText])
            let finalIngredients = ingredientText.getIngredientsFromString(ingredients: [])
            
            
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
    
    static func getPuppyRecipesFromSearches(activeSearches: [(String, SearchType)], expiringItems: [String], recipesFound: @escaping (_ recipes: [Recipe.Puppy]) -> Void) {
        var puppyRecipes: [Recipe.Puppy] = []
        
        
        var itemsToSearch: [String] {
            if activeSearches.contains(where: {$0 == ("Expiring", .other)}) {
                return expiringItems
            } else {
                return activeSearches.filter({$0.1 == .ingredient}).map { (str) -> String in
                    (GenericItem(rawValue: str.0)?.description ?? "")
                }.filter({$0 != ""})
            }
        }
        
        let ingredientText = itemsToSearch.map { (str) -> String in
            str.replacingOccurrences(of: " ", with: "%20")
        }.joined(separator: ",")
        
        
        var potentialOtherThanIngredientText: String {
            let otherSearches = activeSearches.filter({$0.1 != .ingredient})
            if otherSearches.isEmpty == false {
                return "&q=\(otherSearches.first!.0)"
            } else {
                return ""
            }
        }
        
        var searchURL: URL? {
            if ingredientText != "" {
                return URL(string: "http://www.recipepuppy.com/api/?i=\(ingredientText)\(potentialOtherThanIngredientText)")
            } else {
                print("Doing general query")
                let txt = (activeSearches.first?.0)?.replacingOccurrences(of: " ", with: "%20")
                return URL(string: "http://www.recipepuppy.com/api/?q=\(txt ?? "\(GenericItem.all.randomElement() ?? "")")")
            }
        }
        
        guard let url = searchURL else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            DispatchQueue.main.async {
                guard let data = data else {
                    print("Data was nil")
                    return
                }
                
                let json = try? JSONSerialization.jsonObject(with: data, options: [])
                if let dictionary = json as? [String:Any] {
                    let newData = dictionary["results"] as? [Any]
                    
                    if let newData = newData {
                        for recipeData in newData {
                            let recipeDataDict = recipeData as? [String:Any]
                            if let recipeDataDict = recipeDataDict {
                                let title = recipeDataDict["title"] as? String
                                let trimTitle = title?.trim()
                                let ingredients = recipeDataDict["ingredients"] as? String
                                let url = recipeDataDict["href"] as? String
                                let puppyRecipe = Recipe.Puppy(title: trimTitle, ingredients: ingredients, url: URL(string: url ?? ""))
                                puppyRecipes.append(puppyRecipe)
                                
                            }
                            
                        }
                        recipesFound(puppyRecipes)
                    }
                }
            }
        }
        task.resume()
        
    }
    
    static func readOneRecipeFrom(id: String, db: Firestore, recipeReturned: @escaping(_ recipe: Recipe) -> Void) {
        let reference = db.collection("recipes").document(id)
        reference.getDocument { (documentSnapshot, error) in
            guard let doc = documentSnapshot else { return }
            let recipe = Recipe(name: doc.get("name") as! String, recipeType: doc.get("recipeType") as! [String], cuisineType: doc.get("cuisineType") as! String, cookTime: doc.get("cookTime") as! Int, prepTime: doc.get("prepTime") as! Int, ingredients: doc.get("ingredients") as! [String], instructions: doc.get("instructions") as! [String], calories: doc.get("calories") as? Int, numServes: doc.get("numServes") as! Int, userID: doc.get("userID") as? String, numReviews: doc.get("numReviews") as? Int, numStars: doc.get("numStars") as? Int, notes: doc.get("notes") as? String, tagline: doc.get("tagline") as? String, recipeImage: nil, imagePath: doc.get("path") as? String, reviewImagePaths: doc.get("reviewImagePaths") as? [String])
            recipeReturned(recipe)
        }
    }
    
    static func getRecipeInfoFromURL_allRecipesTwo(recipeURL: String) {
        let url = URL(string: recipeURL)!

        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                print("data was nil")
                return
            }
            guard let htmlString = String(data: data, encoding: .utf8) else {
                print("couldn't cast data into String")
                return
            }
            print(htmlString)
            
            let leftSideString = "[{\"@context\""
            
            let rightSideString = "[{\"@type\":\"Review\""
            
            guard let leftSideRange = htmlString.range(of: leftSideString) else {
                print("couldn't find left range")
                return
            }
            
            guard let rightSideRange = htmlString.range(of: rightSideString) else {
                print("couldn't find right range")
                return
            }
            
            let rangeOfTheData = leftSideRange.upperBound..<rightSideRange.lowerBound
            let textToGrab = String(htmlString[rangeOfTheData])
            //print(textToGrab)
            
            
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
    
    
}



extension Recipe {
    mutating func writeToFirestore(db: Firestore!, storage: Storage) {
        let ingredients = self.ingredients
        let doc = db.collection("recipes").document()
        self.imagePath = "recipe/\(doc.documentID).jpg"
        doc.setData([
            "name": self.name,
            "recipeType": self.recipeType,
            "cuisineType": self.cuisineType,
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
            "path": self.imagePath as Any,
            "tagline": self.tagline as Any,
            "reviewImagePaths": self.reviewImagePaths as Any
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
        let uploadReference = Storage.storage().reference(withPath: imagePath ?? "")
        guard let imageData = self.recipeImage else { return }
        let newMetadata = StorageMetadata()
        newMetadata.contentType = "image/jpeg"
        //uploadReference.putData(imageData)
        
        uploadReference.putData(imageData, metadata: newMetadata)
        
        
    }
    func getImageFromStorage(thumb: Bool, imageReturned: @escaping (_ image: UIImage?) -> Void) {
        var image: UIImage?
        var thumbPath = self.imagePath
        if thumb == true {
            thumbPath?.removeLast(4)
            thumbPath?.append(contentsOf: "_200x200.jpg")
        }
        
        #warning("check which thumbnail image size works the best and change here, then limit firebase extension to only keep that size so theres no extra images")
        
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
    func updateRecipeReviewInfo(stars: Int, reviews: Int, db: Firestore) {
        
        let recipeID = self.imagePath?.imagePathToDocID()
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
        let recipeID = self.imagePath?.imagePathToDocID()
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
    
    //(Bundle.main.loadNibNamed("IngredientView", owner: nil, options: nil)?.first as? IngredientView)!
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
    
    
    func addRecipeDocumentToUserProfile(db: Firestore) {
        guard let id = self.imagePath?.imagePathToDocID() else { return }
        let reference = db.collection("users").document(Auth.auth().currentUser?.uid ?? " ").collection("savedRecipes").document(id)
        reference.setData([
            "name": self.name,
            "recipeType": self.recipeType,
            "cuisineType": self.cuisineType,
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
            "path": self.imagePath as Any,
            "tagline": self.tagline as Any,
            "reviewImagePaths": self.reviewImagePaths as Any
        ]) { err in
        if let err = err {
            print("Error writing document: \(err)")
        } else {
            print("Document successfully written")
            }
        }
    }
    
    func removeRecipeDocumentFromUserProfile(db: Firestore) {
        guard let id = self.imagePath?.imagePathToDocID() else { return }
        let reference = db.collection("users").document(Auth.auth().currentUser?.uid ?? " ").collection("savedRecipes").document(id)
        reference.delete()
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
    
    func addRecipeToRecentlyViewedRecipes(db: Firestore) {
        #warning("does dispatchQueue do anything here, ask")
        DispatchQueue.main.async {
            if let uid = Auth.auth().currentUser?.uid {
                let reference = db.collection("users").document(uid)
                reference.getDocument { (documentSnapshot, error) in
                    guard let doc = documentSnapshot else { return }
                    guard let data = doc.data() else { return }
                    
                    if var dict = data["recentlyViewedRecipes"] as? [String:[String:Any]] {
                        // update the data, already have saved recipes
                        print(dict.keys.count)
                        dict["\(Date().timeIntervalSince1970)"] = ["name": self.name, "path": self.imagePath as Any, "timeIntervalSince1970": Date().timeIntervalSince1970]
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
                        let dict: [String:[String:Any]] = ["\(Date().timeIntervalSince1970)":["name": self.name, "path": self.imagePath as Any, "timeIntervalSince1970": Date().timeIntervalSince1970]]
                        reference.updateData([
                            "recentlyViewedRecipes" : dict
                        ])
                    }
                }
            }
        }
    }
    
}


extension Recipe {
    struct Puppy {
        var title: String?
        var ingredients: String?
        var url: URL?
        
        init(title: String?, ingredients: String?, url: URL?) {
            self.title = title
            self.ingredients = ingredients
            self.url = url
        }
    }
}

