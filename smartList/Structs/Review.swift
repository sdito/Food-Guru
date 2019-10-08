//
//  Review.swift
//  smartList
//
//  Created by Steven Dito on 10/7/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import Foundation
import FirebaseFirestore

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
    static func getViewsFrom(reviews: [Review]) -> [RatingView] {
        var views: [RatingView] = []
        for review in reviews {
            let view = Bundle.main.loadNibNamed("RatingView", owner: nil, options: nil)?.first as! RatingView
            view.setUI(review: review)
            views.append(view)
        }
        return views
    }
}
