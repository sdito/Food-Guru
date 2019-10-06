//
//  GiveRatingView.swift
//  smartList
//
//  Created by Steven Dito on 10/5/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import UIKit


protocol GiveRatingViewDelegate {
    func publishRating(stars: Int, rating: String?)
}


class GiveRatingView: UIView {
    var delegate: GiveRatingViewDelegate!
    private var rating: Int?
    private let placeholder = "How was the recipe? Did you have any cooking tips, or make any substitutions?"
    @IBOutlet weak var ratingButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet var starButtons: [UIButton]!
    
    
    
    override func awakeFromNib() {
        textView.delegate = self
        textView.border()
        textView.tintColor = Colors.main
        textView.text = placeholder
        textView.alpha = 0.5
        ratingButton.isUserInteractionEnabled = false
        
    }
    
    
    @IBAction func tapped(_ sender: UIButton) {
        ratingButton.isUserInteractionEnabled = true
        rating = sender.tag
        starButtons.forEach { (button) in
            if button.tag <= sender.tag {
                button.setImage(UIImage(named: "star.filled"), for: .normal)
            } else {
                button.setImage(UIImage(named: "star.outline"), for: .normal)
            }
        }
        ratingButton.setTitle("Publish rating", for: .normal)
        ratingButton.setTitleColor(Colors.main, for: .normal)
    }
    
    
    
    
    
    
    @IBAction func enterRating(_ sender: Any) {
        print("Publish the review here")
        let reviewText = (textView.text != placeholder) ? textView.text : ""
        delegate.publishRating(stars: rating ?? 0, rating: reviewText)
        
    }
    
}


extension GiveRatingView: UITextViewDelegate {
    @objc func gestureSelector() {
        print("called")
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.alpha = 1.0
        textView.text = ""
    }
}
