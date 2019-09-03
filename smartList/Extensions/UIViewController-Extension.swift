//
//  UIViewController-Extension.swift
//  smartList
//
//  Created by Steven Dito on 8/26/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import Foundation
import UIKit


extension UIViewController {
    
    func add(popUp: SelectRecipeTypeVC) {
//        self.addChild(popUp)
//        popUp.view.frame = self.view.frame
//        self.view.addSubview(popUp.view)
//        popUp.didMove(toParent: self)
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "recipeType") as! SelectRecipeTypeVC
        self.present(vc, animated: true, completion: nil)

    }
}
