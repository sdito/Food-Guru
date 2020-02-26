//
//  PDFCreator.swift
//  smartList
//
//  Created by Steven Dito on 11/13/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import UIKit



class PDFCreator: NSObject {
    
    let title: String
    let ingredients: [String]
    let instructions: [String]
    
    init(title: String, ingredients: [String], instructions: [String]) {
        self.title = title
        self.ingredients = ingredients
        self.instructions = instructions.map({"\((instructions.firstIndex(of: $0) ?? 0) + 1). \($0)"})
    }
    
    func createPDF() -> Data {
        let pdfMetaData = [
            kCGPDFContextCreator: "Recipe PDF",
            kCGPDFContextAuthor: "Food Guru",
            kCGPDFContextTitle: title
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        let pageWidth = 8.5 * 72.0
        let pageHeight = 11 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        // need to take the ending location of the previous section in order to know where to layout the next section
        let data = renderer.pdfData { (context) in
            context.beginPage()
            let titleBottom = addTitleToPDF(pageRect: pageRect)
            let ingredientsBottom = addSectionTitleToPDF(pageRect: pageRect, sectionTitle: "Ingredients", textTop: titleBottom + 18.0)
            let ingredientSectionBottom = addBodyTextToPDF(pageRect: pageRect, textTop: ingredientsBottom + 9.0, text: ingredients, ingredients: true)
            let instructionsBottom = addSectionTitleToPDF(pageRect: pageRect, sectionTitle: "Instructions", textTop: ingredientSectionBottom + 18.0)
            addBodyTextToPDF(pageRect: pageRect, textTop: instructionsBottom + 9.0, text: instructions, ingredients: false)
            addLogoToPDF(pageRect: pageRect, image: UIImage(named: "__logoOpposite")!)
        }

      return data
    }
    
    func addSectionTitleToPDF(pageRect: CGRect, sectionTitle: String, textTop: CGFloat) -> CGFloat {
        let font = UIFont(name: "futura", size: 15)
        let attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font!]
        let attributedTitle = NSAttributedString(string: sectionTitle, attributes: attributes)
        let titleStringSize = attributedTitle.size()
        let titleStringRect = CGRect(
            x: (pageRect.width - titleStringSize.width) / 2.0,
            y: textTop,
            width: titleStringSize.width,
            height: titleStringSize.height
        )
        
        attributedTitle.draw(in: titleStringRect)
        return titleStringRect.origin.y + titleStringRect.size.height
    }
    
    func addTitleToPDF(pageRect: CGRect) -> CGFloat {
        let titleFont = UIFont(name: "futura", size: 18)
        let titleAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: titleFont!]
        let attributedTitle = NSAttributedString(string: title, attributes: titleAttributes)
        let titleStringSize = attributedTitle.size()
        let titleStringRect = CGRect(
            x: (pageRect.width - titleStringSize.width) / 2.0,
            y: 36,
            width: titleStringSize.width,
            height: titleStringSize.height
        )
        attributedTitle.draw(in: titleStringRect)
        return titleStringRect.origin.y + titleStringRect.size.height
    }
    
    func addLogoToPDF(pageRect: CGRect, image: UIImage) {
        let imageRect = CGRect(x: pageRect.width - 30 - 40, y: 30, width: 40, height: 40)
        
        image.draw(in: imageRect)
    }
    
    // set up so this will work for both ingredients and instructions
    @discardableResult
    func addBodyTextToPDF(pageRect: CGRect, textTop: CGFloat, text: [String], ingredients: Bool) -> CGFloat {
        
        let textFont = UIFont(name: "futura", size: 12)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .natural
        paragraphStyle.lineBreakMode = .byWordWrapping
        
        let textAttributes = [
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.font: textFont
        ]
        var attributedString: String {
            if ingredients == true {
                return text.joined(separator: "\n")
            } else {
                return text.joined(separator: "\n\n")
            }
        }
        let attributedText = NSAttributedString(
            string: attributedString,
            attributes: textAttributes as [NSAttributedString.Key : Any]
        )
        
        var height: CGFloat {
            if ingredients == true {
                return attributedText.size().height
            } else {
                return pageRect.height
            }
        }
        
        let textRect = CGRect(
            x: 36,
            y: textTop,
            width: pageRect.width - 72,
            height: height
        )
        attributedText.draw(in: textRect)
            return textRect.origin.y + textRect.size.height
        }
}
