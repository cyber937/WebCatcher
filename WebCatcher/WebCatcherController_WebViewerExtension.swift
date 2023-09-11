//
//  WebCatcherController_WebviwerExtension.swift
//  WebCatcher
//
//  Created by Kiyoshi on 10/8/18.
//  Copyright © 2018 Digital Bytes Inc. All rights reserved.
//

import Cocoa
import WebKit

extension WebCatcherController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        //guard let webSnapshotView = webView as? WebSnapshotView,
        //    let schedule = PersistantData.sharedInstance.schedules.first(where: {$0.data.uuid == webSnapshotView.uuid }) else { return }
        
        //webSnapshotView.schedule = schedule
        
        //let webSnapshotOperation = WebSnapshotOperation(webSnapshotView)
        
        //schedule.snapshotOperationQueue.addOperation(webSnapshotOperation)
        
    }
    
}
