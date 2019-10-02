//
//  RecipeDetailVC.swift
//  smartList
//
//  Created by Steven Dito on 9/29/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import UIKit
import FirebaseFirestore

class RecipeDetailVC: UIViewController {
    var db: Firestore!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var recipeName: UILabel!
    @IBOutlet weak var nameAndTitleView: UIView!
    @IBOutlet weak var author: UILabel!
    @IBOutlet weak var tagline: UILabel!
    @IBOutlet weak var prepTime: UILabel!
    @IBOutlet weak var cookTime: UILabel!
    @IBOutlet weak var servings: UILabel!
    @IBOutlet weak var calories: UILabel!
    @IBOutlet weak var ingredientsStackView: UIStackView!
    @IBOutlet weak var instructionsStackView: UIStackView!
    @IBOutlet weak var notes: UILabel!
    
    var data: (image: UIImage, recipe: Recipe)?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        //set the image twice so that there will be something there while the better quality picture is loading, rather than a loading circle
        if let data = data {
            setUI(recipe: data.recipe, image: data.image)
        }
        data?.recipe.getImageFromStorage(thumb: false, imageReturned: { (img) in
            self.imageView.image = img
        })
    }
    @IBAction func addAllToList(_ sender: Any) {
        print("Add all items to list")
    }
    
    private func setUI(recipe: Recipe, image: UIImage) {
        imageView.image = data?.image
        recipeName.text = recipe.name
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.nameAndTitleView.shadowAndRounded()
        }
        nameAndTitleView.alpha = 0.95
        tagline.text = recipe.tagline
        prepTime.text = "\(recipe.prepTime) m"
        cookTime.text = "\(recipe.cookTime) m"
        servings.text = "\(recipe.numServes)"
        calories.text = "\(recipe.calories!)"
        if let n = recipe.notes {
            notes.text = "Notes: \(n)"
        }
        if let uid = recipe.userID {
            User.getNameFromUid(db: db, uid: uid) { (name) in
                self.author.text = "By \(name ?? "unknown user")"
            }
        }
        recipe.addButtonIngredientViewsTo(stackView: ingredientsStackView)
        recipe.addInstructionsToInstructionStackView(stackView: instructionsStackView)
        
    }

}
