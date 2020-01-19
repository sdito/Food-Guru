//
//  Colors.swift
//  smartList
//
//  Created by Steven Dito on 8/4/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import Foundation
import UIKit

struct Colors {
    
    static let main = UIColor(red: 146.0/255.0, green: 0.0/255.0, blue: 255.0/255.0, alpha: 1.0)
    static let secondary = UIColor(red: 0.3236978054, green: 0.1063579395, blue: 0.574860394, alpha: 1)
    static let mainLight = UIColor(red: 169.0/255.0, green: 0.0/255.0, blue: 255.0/255.0, alpha: 0.5)
    
    //used to blend in with textFields for non textfields
    static let lightGray = UIColor(red: 200.0/255.0, green: 200.0/255.0, blue: 200.0/255.0, alpha: 1.0)
    static let messageGreen = UIColor(red: 0.0/255.0, green: 128.0/255.0, blue: 0.0/255.0, alpha: 1.0)
    

    static func getRGBcolorFromPercentage(double: Double) -> UIColor {
        let ratio = 1.0 / 13.0
        switch double {
        case 0...ratio:
            return UIColor(red: 255.0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1.0)
        case ratio...ratio*2:
            return UIColor(red: 255.0/255.0, green: 43.0/255.0, blue: 0/255.0, alpha: 1.0)
        case ratio*2...ratio*3:
            return UIColor(red: 255.0/255.0, green: 85.0/255.0, blue: 0/255.0, alpha: 1.0)
        case ratio*3...ratio*4:
            return UIColor(red: 255.0/255.0, green: 128.0/255.0, blue: 0/255.0, alpha: 1.0)
        case ratio*4...ratio*5:
            return UIColor(red: 255.0/255.0, green: 170.0/255.0, blue: 0/255.0, alpha: 1.0)
        case ratio*5...ratio*6:
            return UIColor(red: 255.0/255.0, green: 213.0/255.0, blue: 0/255.0, alpha: 1.0)
        case ratio*6...ratio*7:
            return UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 0/255.0, alpha: 1.0)
        case ratio*7...ratio*8:
            return UIColor(red: 213.0/255.0, green: 255.0/255.0, blue: 0/255.0, alpha: 1.0)
        case ratio*8...ratio*9:
            return UIColor(red: 170.0/255.0, green: 255.0/255.0, blue: 0/255.0, alpha: 1.0)
        case ratio*9...ratio*10:
            return UIColor(red: 128.0/255.0, green: 255.0/255.0, blue: 0/255.0, alpha: 1.0)
        case ratio*10...ratio*11:
            return UIColor(red: 85.0/255.0, green: 255.0/255.0, blue: 0/255.0, alpha: 1.0)
        case ratio*11...ratio*12:
            return UIColor(red: 43.0/255.0, green: 255.0/255.0, blue: 0/255.0, alpha: 1.0)
        case ratio*12...ratio*13:
            return UIColor(red: 0/255.0, green: 255.0/255.0, blue: 0/255.0, alpha: 1.0)
        default:
            return UIColor(red: 255.0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1.0)
        }
    }
}
