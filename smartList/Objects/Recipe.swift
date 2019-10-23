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
    
    init(name: String, recipeType: [String], cuisineType: String, cookTime: Int, prepTime: Int, ingredients: [String], instructions: [String], calories: Int?, numServes: Int, userID: String?, numReviews: Int?, numStars: Int?, notes: String?, tagline: String?, recipeImage: Data?, imagePath: String?) {
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
    }
    
    static func readUserRecipes(db: Firestore, recipesReturned: @escaping (_ recipe: [Recipe]) -> Void) {
        var recipes: [Recipe] = []
        db.collection("recipes").getDocuments { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(String(describing: error))")
                return
            }
            for doc in documents {
                let r = Recipe(name: doc.get("name") as! String, recipeType: doc.get("recipeType") as! [String], cuisineType: doc.get("cuisineType") as! String, cookTime: doc.get("cookTime") as! Int, prepTime: doc.get("prepTime") as! Int, ingredients: doc.get("ingredients") as! [String], instructions: doc.get("instructions") as! [String], calories: doc.get("calories") as? Int, numServes: doc.get("numServes") as! Int, userID: doc.get("userID") as? String, numReviews: doc.get("numReviews") as? Int, numStars: doc.get("numStars") as? Int, notes: doc.get("notes") as? String, tagline: doc.get("tagline") as? String, recipeImage: nil, imagePath: doc.get("path") as? String)
                recipes.append(r)
            }
            recipesReturned(recipes)
        }
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
            "tagline": self.tagline as Any
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written")
                
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
    
}
