//
//  StarRatingView.swift
//  smartList
//
//  Created by Steven Dito on 10/5/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import UIKit

class StarRatingView: UIView {
    private let full = "star.fill"
    private let half = "star.lefthalf.fill"
    private let none = "star"
    @IBOutlet weak var one: UIImageView!
    @IBOutlet weak var two: UIImageView!
    @IBOutlet weak var three: UIImageView!
    @IBOutlet weak var four: UIImageView!
    @IBOutlet weak var five: UIImageView!
    @IBOutlet weak var numReviews: UILabel!
    
    func setUI(rating: Double, nReviews: Int) {
        numReviews.text = "\(nReviews)"
        if #available(iOS 13.0, *) {
            one.image = UIImage(systemName: full)
            two.image = UIImage(systemName: full)
            three.image = UIImage(systemName: full)
            four.image = UIImage(systemName: full)
            five.image = UIImage(systemName: full)
            switch rating {
            case 0..<1.25:
                two.image = UIImage(systemName: none)
                three.image = UIImage(systemName: none)
                four.image = UIImage(systemName: none)
                five.image = UIImage(systemName: none)
            case 1.25..<1.75:
                two.image = UIImage(systemName: half)
                three.image = UIImage(systemName: none)
                four.image = UIImage(systemName: none)
                five.image = UIImage(systemName: none)
            case 1.75..<2.25:
                three.image = UIImage(systemName: none)
                four.image = UIImage(systemName: none)
                five.image = UIImage(systemName: none)
            case 2.25..<2.75:
                three.image = UIImage(systemName: half)
                four.image = UIImage(systemName: none)
                five.image = UIImage(systemName: none)
            case 2.75..<3.25:
                four.image = UIImage(systemName: none)
                five.image = UIImage(systemName: none)
            case 3.25..<3.75:
                four.image = UIImage(systemName: half)
                five.image = UIImage(systemName: none)
            case 3.75..<4.25:
                five.image = UIImage(systemName: none)
            case 4.25..<4.75:
                five.image = UIImage(systemName: half)
            case 4.75...5.00:
                return
            default:
                one.image = UIImage(systemName: none)
                two.image = UIImage(systemName: none)
                three.image = UIImage(systemName: none)
                four.image = UIImage(systemName: none)
                five.image = UIImage(systemName: none)
            }
        } else {
            // Fallback on earlier versions
        }
        
    }

}
