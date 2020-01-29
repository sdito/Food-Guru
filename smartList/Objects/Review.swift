//
//  Review.swift
//  smartList
//
//  Created by Steven Dito on 10/7/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

struct Review {
    var userName: String
    var rating: Int
    var body: String?
    var date: TimeInterval?
    
    init(userName: String, rating: Int, body: String?, date: TimeInterval?) {
        self.userName = userName
        self.rating = rating
        self.body = body
        self.date = date
    }
    
    static func getReviewsFrom(recipe: Recipe, db: Firestore, reviewsReturned: @escaping (_ reviews: [Review]) -> Void) {
        var reviews: [Review] = []
        let id = recipe.imagePath?.imagePathToDocID()
        if let id = id {
            let reference = db.collection("recipes").document(id).collection("reviews").whereField("hasText", isEqualTo: true).limit(to: 5)
            reference.getDocuments { (querySnapshot, error) in
                guard let documents = querySnapshot?.documents else {
                    print("Error retching documents: \(String(describing: error))")
                    return
                }
                for doc in documents {
                    if let name = doc.get("name") as? String, let rating = doc.get("stars") as? Int {
                        let review = Review(userName: name, rating: rating, body: doc.get("review") as? String, date: doc.get("timeIintervalSince1970") as? TimeInterval)
                        reviews.append(review)
                    }
                }
                reviewsReturned(reviews)
            }
        }
    }
    static func getViewsFrom(reviews: [Review]) -> [UIView] {
        var views: [RatingView] = []
        for review in reviews {
            let view = Bundle.main.loadNibNamed("RatingView", owner: nil, options: nil)?.first as! RatingView
            view.setUI(review: review)
            views.append(view)
        }
        if views.isEmpty == false {
            return views
        } else {
            let label = UILabel()
            label.numberOfLines = 0
            
            label.text = "No written reviews yet, if you have made this recipe before write a review!"
            label.font = UIFont(name: "futura", size: 15)
            return [label]
        }
        
    }
    
    
    static func writeImageForReview(image: UIImage, recipe: Recipe, db: Firestore) {
        guard let recipeID = recipe.imagePath?.imagePathToDocID() else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let imageData: Data = image.jpegData(compressionQuality: 0.75) else { return }
        let random = String.randomString(length: 8)
        let uploadReference = Storage.storage().reference(withPath: "review/\(recipeID)/\(uid)/\(random).jpg")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        uploadReference.putData(imageData, metadata: metadata)
        let fullPath = uploadReference.fullPath
        

        // add the path to the recipe document
        let recipeReference = db.collection("recipes").document(recipeID)
        recipeReference.updateData([
            "reviewImagePaths": FieldValue.arrayUnion([fullPath])
        ])
        
        // delay to make sure the document is updated, how fast this data is updated is not important
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            db.collection("recipes").document(recipeID).collection("reviews").whereField("user", isEqualTo: uid).getDocuments { (querySnapshot, error) in
                guard let document = querySnapshot?.documents.first else {
                    print("Error retrieving document: \(String(describing: error))")
                    return
                }
                
                let id = document.documentID
                db.collection("recipes").document(recipeID).collection("reviews").document(id).updateData([
                    "imagePath": fullPath
                ])
            }
        }
    }
    
    
}
