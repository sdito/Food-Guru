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
    var authorName: String?
    var cookTime: Int?
    var prepTime: Int?
    var ingredients: [String]
    var instructions: [String]
    var calories: Int?
    var numServes: Int
    var notes: String?
    var tagline: String?
    var recipeImage: Data?
    var mainImage: String?
    var thumbImage: String?
    var authorURL: String?
    
    init(djangoID: Int, name: String, authorName: String?, cookTime: Int?, prepTime: Int?, ingredients: [String], instructions: [String], calories: Int?, numServes: Int, notes: String?, tagline: String?, recipeImage: Data?, mainImage: String?, thumbImage: String?, authorURL: String?) {
        self.djangoID = djangoID
        self.name = name
        self.authorName = authorName
        self.cookTime = cookTime
        self.prepTime = prepTime
        self.ingredients = ingredients
        self.instructions = instructions
        self.calories = calories
        self.numServes = numServes
        self.notes = notes
        self.tagline = tagline
        self.recipeImage = recipeImage
        self.mainImage = mainImage
        self.thumbImage = thumbImage
        self.authorURL = authorURL
    }
    
    // MARK: General
    
    mutating func writeToFirestore(db: Firestore!, storage: Storage) {
        let ingredients = self.ingredients
        let doc = db.collection("recipes-external").document()
        self.mainImage = "recipe/\(doc.documentID).jpg"
        doc.setData([
            "djangoID": self.djangoID,
            "name": self.name,
            "authorName": self.authorName as Any,
            "cookTime": self.cookTime as Any,
            "prepTime": self.prepTime as Any,
            "totalTime": (self.cookTime ?? 0) + (self.prepTime ?? 0),
            "ingredients": self.ingredients,
            "instructions": self.instructions,
            "calories": self.calories as Any,
            "numServes": self.numServes,
            "notes": self.notes as Any,
            "path": self.mainImage as Any,
            "tagline": self.tagline as Any,
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

    
    // MARK: Saved recipes
    static func addRecipeToSavedRecipes(db: Firestore, recipe: Recipe) {
        let reference = db.collection("users").document(Auth.auth().currentUser?.uid ?? " ")
        reference.updateData([
            "savedRecipes": FieldValue.arrayUnion(["\(recipe.djangoID)"])
        ])
    }
    
    static func removeRecipeFromSavedRecipes(db: Firestore, recipe: Recipe) {
        let reference = db.collection("users").document(Auth.auth().currentUser?.uid ?? " ")
        reference.updateData([
            "savedRecipes": FieldValue.arrayRemove(["\(recipe.djangoID)"])
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
        DispatchQueue.main.async {
            if let uid = Auth.auth().currentUser?.uid {
                let reference = db.collection("users").document(uid)
                reference.getDocument { (documentSnapshot, error) in
                    guard let doc = documentSnapshot else { return }
                    guard let data = doc.data() else { return }
                    
                    if var dict = data["recentlyViewedRecipes"] as? [String:[String:Any]] {
                        // update the data, already have saved recipes
                        print(dict.keys.count)
                        dict["\(Date().timeIntervalSince1970)"] = ["name": self.name, "path": "\(self.djangoID)", "timeIntervalSince1970": Date().timeIntervalSince1970]
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
                        let dict: [String:[String:Any]] = ["\(Date().timeIntervalSince1970)":["name": self.name, "path": "\(self.djangoID)", "timeIntervalSince1970": Date().timeIntervalSince1970]]
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
            "authorName": self.authorName as Any,
            "cookTime": self.cookTime as Any,
            "prepTime": self.prepTime as Any,
            "totalTime": (self.cookTime ?? 0) + (self.prepTime ?? 0),
            "ingredients": self.ingredients,
            "instructions": self.instructions,
            "calories": self.calories as Any,
            "numServes": self.numServes,
            "notes": self.notes as Any,
            "path": self.mainImage as Any,
            "tagline": self.tagline as Any,
            "thumbImage": self.thumbImage as Any,
            "authorURL": self.authorURL as Any
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
    
    static func randomRecipeForSkeletonView() -> Recipe {
        return Recipe(djangoID: -1, name: "Recipe", authorName: nil, cookTime: nil, prepTime: nil, ingredients: [], instructions: [], calories: nil, numServes: 0, notes: nil, tagline: "s", recipeImage: nil, mainImage: nil, thumbImage: nil, authorURL: nil)
    }
    
}

extension DocumentSnapshot {
    func getRecipe() -> Recipe {
        let r = Recipe(djangoID: self.get("djangoID") as? Int ?? -1,
                       name: self.get("name") as! String,
                       authorName: self.get("authorName") as? String,
                       cookTime: self.get("cookTime") as? Int,
                       prepTime: self.get("prepTime") as? Int,
                       ingredients: self.get("ingredients") as! [String],
                       instructions: self.get("instructions") as! [String],
                       calories: self.get("calories") as? Int,
                       numServes: self.get("numServes") as! Int,
                       notes: self.get("notes") as? String,
                       tagline: self.get("tagline") as? String,
                       recipeImage: nil,
                       mainImage: self.get("path") as? String,
                       thumbImage: self.get("thumbImage") as? String,
                       authorURL: self.get("authorURL") as? String)
        return r
    }
}


