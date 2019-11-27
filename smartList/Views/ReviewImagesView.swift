//
//  ReviewImagesView.swift
//  smartList
//
//  Created by Steven Dito on 11/26/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import UIKit
import FirebaseStorage

class ReviewImagesView: UIView {
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var imageView: UIImageView!
    lazy var storage = Storage.storage()
    
    //#error("Chicken lemon linguini is the test recipe")
    func setUI(imagePaths: [String]) {
        //let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        
    
        for path in imagePaths {
            let editedPath = path.resizedTo("200x200")
            
            
            let reference = storage.reference(withPath: editedPath)
            reference.getData(maxSize: 2 * 1024 * 1024) { (data, error) in
                guard let data = data else {
                    print("Error downloading image: \(String(describing: error))")
                    return
                }
                let image = UIImage(data: data)
                if path == imagePaths.first {
                    self.imageView.image = image
                } else {
                    let imageView = UIImageView(image: image)
                    //imageView.addGestureRecognizer(gestureRecognizer)
                    self.stackView.addArrangedSubview(imageView)
                }
            }
        }
        #error("gesture recognizer stuff is not working, need to implement it so that when user presses image, detail screen and larger image shows")
//        stackView.subviews.forEach { (view) in
//            print("called")
//            view.isUserInteractionEnabled = true
//            view.addGestureRecognizer(gestureRecognizer)
//        }
        
    }
    
    @objc func tapAction() {
        print("Tap action called")
    }
}
