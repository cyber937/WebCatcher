//
//  CaptureSiteGroupListCellView.swift
//  WebCatcher
//
//  Created by Kiyoshi on 11/8/18.
//  Copyright © 2018 Digital Bytes Inc. All rights reserved.
//

import Cocoa

protocol CaptureSiteGroupListCellViewDelegate {
    func startEditingCaptureSiteGroupWithRow(_ row: Int)
}

class CaptureSiteGroupListCellView: NSTableCellView {

    var deligate: CaptureSiteGroupListCellViewDelegate?
    
    var row: Int!
    
    @IBAction func pushEditButton(_ sender: NSButton) {
        deligate?.startEditingCaptureSiteGroupWithRow(row)
    }
    
}
