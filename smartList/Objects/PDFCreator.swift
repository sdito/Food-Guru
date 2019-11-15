//
//  PDFCreator.swift
//  smartList
//
//  Created by Steven Dito on 11/13/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import UIKit



// needs a lot of updating, a VERY rough draft now



class PDFCreator: NSObject {
    
    let title: String
    let ingredients: [String]
    let instructions: [String]
    
    init(title: String, ingredients: [String], instructions: [String]) {
        self.title = title
        self.ingredients = ingredients
        self.instructions = instructions
    }
    
    func createFlyer() -> Data {
      let pdfMetaData = [
        kCGPDFContextCreator: "Recipe PDF",
        kCGPDFContextAuthor: "Steven Dito",
        kCGPDFContextTitle: title
      ]
      let format = UIGraphicsPDFRendererFormat()
      format.documentInfo = pdfMetaData as [String: Any]
      let pageWidth = 8.5 * 72.0
      let pageHeight = 11 * 72.0
      let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
      let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
      let data = renderer.pdfData { (context) in
        context.beginPage()
        let titleBottom = addTitle(pageRect: pageRect)
        let ingredientsBottom = addBodyText(pageRect: pageRect, textTop: titleBottom + 18.0, text: ingredients, ingredients: true)
        _ = addBodyText(pageRect: pageRect, textTop: ingredientsBottom, text: instructions, ingredients: false)
      }

      return data
    }
    
    
    func addTitle(pageRect: CGRect) -> CGFloat {
      let titleFont = UIFont(name: "futura", size: 18)
      let titleAttributes: [NSAttributedString.Key: Any] =
        [NSAttributedString.Key.font: titleFont!]
      let attributedTitle = NSAttributedString(
        string: title,
        attributes: titleAttributes
      )
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
    
    func addBodyText(pageRect: CGRect, textTop: CGFloat, text: [String], ingredients: Bool) -> CGFloat {
        
      let textFont = UIFont(name: "futura", size: 12)
      let paragraphStyle = NSMutableParagraphStyle()
      paragraphStyle.alignment = .natural
      paragraphStyle.lineBreakMode = .byWordWrapping
      let textAttributes = [
        NSAttributedString.Key.paragraphStyle: paragraphStyle,
        NSAttributedString.Key.font: textFont
      ]
      let attributedText = NSAttributedString(
        string: text.joined(separator: "\n"),
        attributes: textAttributes as [NSAttributedString.Key : Any]
      )
        
        var height: CGFloat {
            if ingredients == true {
                return CGFloat(18 * text.count)//pageRect.height - textTop
            } else {
                return pageRect.height
            }
        }
      let textRect = CGRect(
        x: 10,
        y: textTop,
        width: pageRect.width - 36,
        height: height
      )
      attributedText.draw(in: textRect)
        print(textRect.origin.y + textRect.size.height)
        return textRect.origin.y + textRect.size.height
    }
}
