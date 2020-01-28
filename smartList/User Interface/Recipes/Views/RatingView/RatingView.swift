//
//  RatingView.swift
//  smartList
//
//  Created by Steven Dito on 10/7/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import UIKit

class RatingView: UIView {
    @IBOutlet weak var reviewerName: UILabel!
    @IBOutlet weak var reviewText: UILabel!
    @IBOutlet weak var headerStackView: UIStackView!
    
    func setUI(review: Review) {
        reviewerName.text = "By \(review.userName)"
        reviewText.text = review.body
        let v = Bundle.main.loadNibNamed("StarRatingView", owner: nil, options: nil)?.first as! StarRatingView
        v.setUI(rating: Double(review.rating), nReviews: 0)
        v.numReviews.removeFromSuperview()
        headerStackView.insertArrangedSubview(v, at: 0)
    }

}
