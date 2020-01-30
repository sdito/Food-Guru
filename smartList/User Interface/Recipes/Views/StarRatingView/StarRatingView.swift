//
//  StarRatingView.swift
//  smartList
//
//  Created by Steven Dito on 10/5/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import UIKit

class StarRatingView: UIView {
    
    let fullImage = UIImage(named: "star.filled")
    let halfImage = UIImage(named: "star.half")
    let emptyImage = UIImage(named: "star.outline")
    @IBOutlet weak var one: UIImageView!
    @IBOutlet weak var two: UIImageView!
    @IBOutlet weak var three: UIImageView!
    @IBOutlet weak var four: UIImageView!
    @IBOutlet weak var five: UIImageView!
    @IBOutlet weak var numReviews: UILabel!
    
    func setUI(rating: Double, nReviews: Int) {
        numReviews.text = "\(nReviews)"
        one.image = fullImage
        two.image = fullImage
        three.image = fullImage
        four.image = fullImage
        five.image = fullImage
        switch rating {
        case 0..<1.25:
            two.image = emptyImage
            three.image = emptyImage
            four.image = emptyImage
            five.image = emptyImage
        case 1.25..<1.75:
            two.image = halfImage
            three.image = emptyImage
            four.image = emptyImage
            five.image = emptyImage
        case 1.75..<2.25:
            three.image = emptyImage
            four.image = emptyImage
            five.image = emptyImage
        case 2.25..<2.75:
            three.image = halfImage
            four.image = emptyImage
            five.image = emptyImage
        case 2.75..<3.25:
            four.image = emptyImage
            five.image = emptyImage
        case 3.25..<3.75:
            four.image = halfImage
            five.image = emptyImage
        case 3.75..<4.25:
            five.image = emptyImage
        case 4.25..<4.75:
            five.image = halfImage
        case 4.75...5.00:
            return
        default:
            one.image = emptyImage
            two.image = emptyImage
            three.image = emptyImage
            four.image = emptyImage
            five.image = emptyImage
        }
        
    }

}
