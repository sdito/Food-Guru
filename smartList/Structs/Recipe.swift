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
    var recipeImage: Data?
    var imagePath: String?
    var imageHeight: CGFloat?
    
    
    init(name: String, recipeType: [String], cuisineType: String, cookTime: Int, prepTime: Int, ingredients: [String], instructions: [String], calories: Int?, numServes: Int, userID: String?, numReviews: Int?, numStars: Int?, notes: String?, recipeImage: Data?, imagePath: String?, imageHeight: CGFloat?) {
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
        self.recipeImage = recipeImage
        self.imagePath = imagePath
        self.imageHeight = imageHeight
    }
    
    static func readUserRecipes(db: Firestore, recipesReturned: @escaping (_ recipe: [Recipe]) -> Void) {
        var recipes: [Recipe] = []
        db.collection("recipes").whereField("userID", isEqualTo: SharedValues.shared.userID ?? "").getDocuments { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(String(describing: error))")
                return
            }
            for doc in documents {
                let r = Recipe(name: doc.get("name") as! String, recipeType: doc.get("recipeType") as! [String], cuisineType: doc.get("cuisineType") as! String, cookTime: doc.get("cookTime") as! Int, prepTime: doc.get("prepTime") as! Int, ingredients: doc.get("ingredients") as! [String], instructions: doc.get("instructions") as! [String], calories: doc.get("calories") as? Int, numServes: doc.get("numServes") as! Int, userID: doc.get("userID") as? String, numReviews: doc.get("numReviews") as? Int, numStars: doc.get("numStars") as? Int, notes: doc.get("notes") as? String, recipeImage: nil, imagePath: doc.get("path") as? String, imageHeight: doc.get("imageHeight") as? CGFloat)
                recipes.append(r)
            }
            recipesReturned(recipes)
        }
    }
    
}



extension Recipe {
    mutating func writeToFirestore(db: Firestore!, storage: Storage) {
        let doc = db.collection("recipes").document()
        self.imagePath = "recipe/\(doc.documentID).jpg"
        
        doc.setData([
            "name": self.name,
            "recipeType": self.recipeType,
            "cuisineType": self.cuisineType,
            "cookTime": self.cookTime,
            "prepTime": self.prepTime,
            "ingredients": self.ingredients,
            "instructions": self.instructions,
            "calories": self.calories as Any,
            "numServes": self.numServes,
            "userID": self.userID as Any,
            "numReviews": self.numReviews as Any,
            "numStars": self.numStars as Any,
            "notes": self.notes as Any,
            "path": self.imagePath as Any,
            "imageHeight": self.imageHeight as Any
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written")
            }
        }
        let uploadReference = Storage.storage().reference(withPath: imagePath ?? "")
        guard let imageData = self.recipeImage else { return }
        
        uploadReference.putData(imageData)
        //NEED TO SET RECIPE VALUE (ADD IT TO THE STRUCT) TO THE METHOD I.E. URL THAT THE IMAGE COULD BE READ FROM
    }
    func getImageFromStorage(imageReturned: @escaping (_ image: UIImage?) -> Void) {
        var image: UIImage?
        
        let storageRef = Storage.storage().reference(withPath: self.imagePath ?? "")
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
    
}
