//
//  WebSnapshotOperation.swift
//  WebCatcher
//
//  Created by Kiyoshi on 10/10/18.
//  Copyright © 2018 Digital Bytes Inc. All rights reserved.
//

import Cocoa
import WebKit
import Quartz
import GoogleAPIClientForREST

class WebSnapshotOperation: Operation {
    
    var webSnapshotView: WebSnapshotView
    weak var queue: OperationQueue?
    
    init(_ webSnapshotView: WebSnapshotView) {
        self.webSnapshotView = webSnapshotView
    }
    
    override func main() {
        
        self.webSnapshotView.webSnapshot?.numberOfFinishedOperation += 1
        
        queue?.isSuspended = true
        
        guard let pdfDocument = self.webSnapshotView.webSnapshot?.schedule?.pdfDocument else { return }
        
        DispatchQueue.main.async {
            
            self.webSnapshotView.evaluateJavaScript("document.readyState", completionHandler: { (complete, error) in
                if complete != nil {
                    self.webSnapshotView.evaluateJavaScript("document.body.scrollHeight", completionHandler: { (height, error) in
                        
                        self.webSnapshotView.frame = NSRect(x: 0, y: 0, width: 1200, height: height as! Int)
                        
                        self.webSnapshotView.takeSnapshot(with: nil) {image, error in
                            
                            let coverView = CoverTitleView(frame: NSRect(x: 0, y: 0, width: 612, height: 792), title: self.webSnapshotView.name, date: Date())
                            let coverPDFData = coverView.dataWithPDF(inside: coverView.bounds)
                            let coverPDFPage = PDFPage(image: NSImage(data: coverPDFData)!)!
                            pdfDocument.insert(coverPDFPage, at: pdfDocument.pageCount)
                            
                            guard let jpegImage = image?.convertToJPEG() else {
                                print("Error: Cannot convert to JPEG image")
                                return
                            }
                            
                            let pdfPage = PDFPage(image: jpegImage)!
                            pdfDocument.insert(pdfPage, at: pdfDocument.pageCount)
                            
                            if self.webSnapshotView.webSnapshot?.numberOfFinishedOperation == self.webSnapshotView.webSnapshot?.webSnapshotViews.count {
                                
                                guard let data = pdfDocument.dataRepresentation() else {
                                    print("Error: Cannot make PDF data")
                                    return
                                }
                                
                                do {
                                    try data.write(to: URL(fileURLWithPath: "/Users/kiyoshi/Pictures/WebCatcher/test.pdf"))
                                } catch {
                                    print("Error")
                                }
                                
                            }
                            
                            self.queue?.isSuspended = false
                            
                        }
                    })
                }
                
            })
        }
    }
}
