//
//  RecipePDFVC.swift
//  smartList
//
//  Created by Steven Dito on 11/13/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import UIKit
import PDFKit

class RecipePDFVC: UIViewController {
    
    @IBOutlet weak var pdfView: PDFView!
    
    public var documentData: Data?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let data = documentData {
            pdfView.document = PDFDocument(data: data)
            pdfView.autoScales = true
            
            let vc = UIActivityViewController(
                activityItems: [data],
                applicationActivities: []
            )
            
            if UIDevice.current.userInterfaceIdiom == .phone {
                present(vc, animated: true, completion: nil)
            } else {
                // do other stuff for iPad
                vc.popoverPresentationController?.sourceView = self.view
                // To center the action sheet
                vc.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                vc.popoverPresentationController?.permittedArrowDirections = []
                present(vc, animated: true, completion: nil)
            }
        }
    }
}
