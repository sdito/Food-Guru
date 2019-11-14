//
//  PDFCreator.swift
//  smartList
//
//  Created by Steven Dito on 11/13/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import UIKit

class PDFCreator: NSObject {
    
    func createFlyer() -> Data {
      let pdfMetaData = [
        kCGPDFContextCreator: "Recipe PDF",
        kCGPDFContextAuthor: "Steven Dito"
      ]
      let format = UIGraphicsPDFRendererFormat()
      format.documentInfo = pdfMetaData as [String: Any]
      let pageWidth = 8.5 * 72.0
      let pageHeight = 11 * 72.0
      let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
      let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
      let data = renderer.pdfData { (context) in
        context.beginPage()
        let attributes = [
            NSAttributedString.Key.font: UIFont(name: "futura", size: 40)!
        ]
        let text = "I'm a PDF! And PDFs are my favorite thing ever"
        text.draw(at: CGPoint(x: 0, y: 0), withAttributes: attributes)
      }

      return data
    }
    
}
