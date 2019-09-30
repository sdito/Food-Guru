//
//  RecipeDetailVC.swift
//  smartList
//
//  Created by Steven Dito on 9/29/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import UIKit

class RecipeDetailVC: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var recipeName: UILabel!
    @IBOutlet weak var nameAndTitleView: UIView!
    
    var data: (image: UIImage, recipe: Recipe)?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set the image twice so that there will be something there while the better quality picture is loading, rather than a loading circle
        if let data = data {
            setUI(recipe: data.recipe, image: data.image)
        }
        data?.recipe.getImageFromStorage(thumb: false, imageReturned: { (img) in
            self.imageView.image = img
        })
    }
    
    private func setUI(recipe: Recipe, image: UIImage) {
        imageView.image = data?.image
        recipeName.text = recipe.name
        nameAndTitleView.shadowAndRounded(); nameAndTitleView.alpha = 0.95
    }

}
