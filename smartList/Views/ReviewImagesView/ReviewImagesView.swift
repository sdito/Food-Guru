//
//  ReviewImagesView.swift
//  smartList
//
//  Created by Steven Dito on 11/26/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import UIKit
import FirebaseStorage



protocol ReviewImagesViewDelegate {
    func showDetailedImage(path: String?, initialImage: UIImage?)
}


class ReviewImagesView: UIView {
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var imageButton: UIButton!
    
    lazy var storage = Storage.storage()
    private var paths: [String] = []
    var delegate: ReviewImagesViewDelegate!
    
    
    func setUI(imagePaths: [String]) {
        paths = imagePaths
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
                    self.imageButton.setBackgroundImage(image, for: .normal)
                    self.imageButton.addTarget(self, action: #selector(self.tapAction), for: .touchUpInside)
                    self.imageButton.setTitle(path, for: .normal)
                    self.imageButton.setTitleColor(.clear, for: .normal)
                } else {
                    let button = UIButton()
                    button.setBackgroundImage(image, for: .normal)
                    button.addTarget(self, action: #selector(self.tapAction), for: .touchUpInside)
                    self.stackView.addArrangedSubview(button)
                    button.setTitle(path, for: .normal)
                    button.setTitleColor(.clear, for: .normal)
                }
            }
        }

    }
    
    @objc func tapAction(sender: UIButton) {
        if let index = stackView.subviews.firstIndex(of: sender) {
            if paths.count >= Int(index) + 1 {
                let img = sender.currentBackgroundImage
                let path = sender.title(for: .normal)
                delegate.showDetailedImage(path: path, initialImage: img)
            }
        }
    }
}
