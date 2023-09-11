//
//  ViewController.swift
//  PrintableDocument
//
//  Created by Kiyoshi on 10/24/18.
//  Copyright © 2018 Digital Bytes. All rights reserved.
//

import Cocoa
import Quartz

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func pushPrintButton(_ sender: Any) {
    
        let pdfDocument = PDFDocument()
        
        let myView = CoverTitleView(frame: NSRect(x: 0, y: 0, width: 612, height: 792), title: "This is title", date: Date())
        let pdfData = myView.dataWithPDF(inside: myView.bounds)
        let pdfPage = PDFPage(image: NSImage(data: pdfData)!)!
        
        pdfDocument.insert(pdfPage, at: 0)
        pdfDocument.insert(pdfPage, at: 1)
        
        guard let data = pdfDocument.dataRepresentation() else {
            print("Error: Cannot make PDF data")
            return
        }
        
        let myURL = URL(fileURLWithPath: "/Users/kiyoshi/Movies/test.pdf")
        try! data.write(to: myURL)
        
    }
    
}

class CoverTitleView: NSView {
    
    private var title: String
    private var date: Date
    
    init(frame frameRect: NSRect, title: String, date: Date) {
        
        self.title = title
        self.date = date
        
        super.init(frame: frameRect)
    }
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ dirtyRect: NSRect) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mma"
        
        PSCover.drawCanvas1(title: title, date: dateFormatter.string(from: date), time: timeFormatter.string(from: date))
        
    }
    
}
