//
//  PageHeaderView.swift
//  WebCatcher
//
//  Created by Kiyoshi on 11/9/18.
//  Copyright © 2018 Digital Bytes Inc. All rights reserved.
//

import Cocoa

class PageHeaderView: NSView {

    private var title: String
    
    init(title: String) {
        
        self.title = title
        super.init(frame: NSMakeRect(0.0, 0.0, 600.0, 100.0))
    }
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ dirtyRect: NSRect) {
        
        WebCatcherUI.drawPageHeader(title: title)
        
    }
    
}

class GroupPageHeaderView: NSView {
    
    private var title:  String
    private var date:   Date
    
    init(title: String, date: Date) {
        
        self.title = title
        self.date = date
        super.init(frame: NSMakeRect(0.0, 0.0, 2610.0, 260.0))
    }
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ dirtyRect: NSRect) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        WebCatcherUI.drawGroupHeader(title: title, date: dateFormatter.string(from: date))
        
    }
}
