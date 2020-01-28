//
//  StarRatingView.swift
//  smartList
//
//  Created by Steven Dito on 10/5/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import UIKit

class StarRatingView: UIView {
//    private let full = "star.fill"
//    private let half = "star.lefthalf.fill"
//    private let none = "star"
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
        if #available(iOS 13.0, *) {
            one.image = fullImage//UIImage(systemName: full)
            two.image = fullImage//UIImage(systemName: full)
            three.image = fullImage//UIImage(systemName: full)
            four.image = fullImage//UIImage(systemName: full)
            five.image = fullImage//UIImage(systemName: full)
            switch rating {
            case 0..<1.25:
                two.image = emptyImage//UIImage(systemName: none)
                three.image = emptyImage//UIImage(systemName: none)
                four.image = emptyImage//UIImage(systemName: none)
                five.image = emptyImage//UIImage(systemName: none)
            case 1.25..<1.75:
                two.image = halfImage//UIImage(systemName: half)
                three.image = emptyImage//UIImage(systemName: none)
                four.image = emptyImage//UIImage(systemName: none)
                five.image = emptyImage//UIImage(systemName: none)
            case 1.75..<2.25:
                three.image = emptyImage//UIImage(systemName: none)
                four.image = emptyImage//UIImage(systemName: none)
                five.image = emptyImage//UIImage(systemName: none)
            case 2.25..<2.75:
                three.image = halfImage//UIImage(systemName: half)
                four.image = emptyImage//UIImage(systemName: none)
                five.image = emptyImage//UIImage(systemName: none)
            case 2.75..<3.25:
                four.image = emptyImage//UIImage(systemName: none)
                five.image = emptyImage//UIImage(systemName: none)
            case 3.25..<3.75:
                four.image = halfImage//UIImage(systemName: half)
                five.image = emptyImage//UIImage(systemName: none)
            case 3.75..<4.25:
                five.image = emptyImage//UIImage(systemName: none)
            case 4.25..<4.75:
                five.image = halfImage//UIImage(systemName: half)
            case 4.75...5.00:
                return
            default:
                one.image = emptyImage//UIImage(systemName: none)
                two.image = emptyImage//UIImage(systemName: none)
                three.image = emptyImage//UIImage(systemName: none)
                four.image = emptyImage//UIImage(systemName: none)
                five.image = emptyImage//UIImage(systemName: none)
            }
        } else {
            // Fallback on earlier versions
        }
        
    }

}
