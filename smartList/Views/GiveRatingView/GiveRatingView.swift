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
    func writeImageForReview(image: UIImage)
}


class GiveRatingView: UIView {
    private var imageForReview: UIImage?
    var imagePicker = UIImagePickerController()
    var delegate: GiveRatingViewDelegate!
    private var rating: Int?
    private let placeholder = "How was the recipe? Did you have any cooking tips, or make any substitutions?"
    @IBOutlet weak var ratingButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var imageSelectOutlet: UIButton!
    @IBOutlet var starButtons: [UIButton]!
    
    
    
    override func awakeFromNib() {
        textView.delegate = self
        textView.border(cornerRadius: 5.0)
        textView.tintColor = Colors.main
        textView.text = placeholder
        textView.alpha = 0.5
        ratingButton.isUserInteractionEnabled = false
        imagePicker.delegate = self //as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
        imageSelectOutlet.layer.cornerRadius = 5
        imageSelectOutlet.clipsToBounds = true
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
    
    
    @IBAction func addPhoto(_ sender: Any) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(.init(title: "Camera", style: .default, handler: {(alert: UIAlertAction!) in self.cameraOption()}))
        actionSheet.addAction(.init(title: "Photo library", style: .default, handler: {(alert: UIAlertAction!) in self.photoLibraryOption()}))
        actionSheet.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            self.findViewController()?.present(actionSheet, animated: true)
        } else {
            // do other stuff for iPad
            guard let viewRect = sender as? UIView else { return }
            if let presenter = actionSheet.popoverPresentationController {
                presenter.sourceView = viewRect
                presenter.sourceRect = viewRect.bounds
            }
            self.findViewController()?.present(actionSheet, animated: true)
        }
        
    }
    
    private func cameraOption() {
        print("Camera option")
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        self.findViewController()?.present(imagePicker, animated: true, completion: nil)
    }
    
    private func photoLibraryOption() {
        print("Photo library option")
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        self.findViewController()?.present(imagePicker, animated: true, completion: nil)
    }
    
    
    @IBAction func enterRating(_ sender: Any) {
        print("Publish the review here")
        let reviewText = (textView.text != placeholder) ? textView.text : ""
        delegate.publishRating(stars: rating ?? 0, rating: reviewText)
        if let image = imageForReview {
            delegate.writeImageForReview(image: image)
        }
    }
    
}

extension GiveRatingView: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if picker == imagePicker {
            if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
                imageForReview = pickedImage
                imageSelectOutlet.setBackgroundImage(pickedImage, for: .normal)
                imageSelectOutlet.tintColor = .clear
                imagePicker.dismiss(animated: true, completion: nil)
            }
        }
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("Cancel time happened")
        imageForReview = nil
        imageSelectOutlet.setBackgroundImage(nil, for: .normal)
        imageSelectOutlet.tintColor = Colors.main
        imagePicker.dismiss(animated: true, completion: nil)
    }
}


extension GiveRatingView: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.alpha = 1.0
        //textView.text = ""
        if textView.text == placeholder {
            textView.text = ""
        }
    }
}
