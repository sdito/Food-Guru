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
    
    public var documentData: Data?
    
    
    @IBOutlet weak var pdfView: PDFView!
    
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
                vc.popoverPresentationController?.sourceRect = pdfView.frame
                present(vc, animated: true, completion: nil)
                
                
            }
        }
    }
}
