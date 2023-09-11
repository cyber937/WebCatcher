//
//  SnapshotProcessViewController.swift
//  WebCatcher
//
//  Created by Kiyoshi on 11/12/18.
//  Copyright © 2018 Digital Bytes Inc. All rights reserved.
//

import Cocoa
import WebKit

class SnapshotProcessViewController: NSViewController {

    @IBOutlet weak var webSnapView: WKWebView?
    @IBOutlet weak var capturingSitePreview: NSImageView?
    @IBOutlet weak var progressIndicator: NSProgressIndicator?
    @IBOutlet weak var siteTitle: NSTextField?
    
    var scheduleController: ScheduleController?
    
    var numberOfFinishedCaptureSiteGroup: Int   = 0
    var numberOfFinishedCaptureSite: Int        = 0
    
    var captureSiteGroupProcessQueue =  OperationQueue()
    var captureSiteProcessQueue =       OperationQueue()
    
    var testURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let scheduleController = scheduleController else { return }
        
        for captureSiteGroup in scheduleController.schedule.captureSiteGroups {
            
            let captureSiteGroupProcess = BlockOperation {
            
                self.captureSiteGroupProcessQueue.isSuspended = true
                
                for captureSite in captureSiteGroup.captureSites {
                    
                    let urlRequest = URLRequest(url: captureSite.url)
                
                    let captureSiteProcess = BlockOperation {
                    
                        self.captureSiteProcessQueue.isSuspended = true
                    
                        DispatchQueue.main.async {
                            self.webSnapView?.load(urlRequest)
                        }
                    
                    }
                
                    if let lastOperation = self.captureSiteProcessQueue.operations.last {
                        captureSiteProcess.addDependency(lastOperation)
                    }
                
                    self.captureSiteProcessQueue.addOperation(captureSiteProcess)
                }
            }
            
            if let lastOperation = self.captureSiteGroupProcessQueue.operations.last {
                captureSiteGroupProcess.addDependency(lastOperation)
            }
            
            self.captureSiteGroupProcessQueue.addOperation(captureSiteGroupProcess)
        }
    }
        
    override func viewDidAppear() {
        progressIndicator?.startAnimation(self)
        self.view.window?.styleMask.remove(.closable)
        self.view.window?.styleMask.remove(.resizable)
    }
}

extension SnapshotProcessViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        guard let scheduleController = scheduleController else { return }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(scheduleController.schedule.bufferTime)) {
            
            webView.evaluateJavaScript("document.readyState", completionHandler: { (complete, error) in
                
                if complete != nil {
                    
                    webView.evaluateJavaScript("document.body.scrollHeight", completionHandler: { (height, error) in
                        
                        webView.frame = NSRect(x: 300, y: 0, width: 1200, height: height as! Int)
                        
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(scheduleController.schedule.bufferTime)) {
                            
                            webView.takeSnapshot(with: nil) {image, error in
                                
                                PersistantData.sharedInstance.captureStartDate = Date()
                                
                                let siteName = scheduleController.schedule.captureSiteGroups[self.numberOfFinishedCaptureSiteGroup].captureSites[self.numberOfFinishedCaptureSite].siteName
                                
                                let imageSize = image!.size
                                let resizedImage = image!.resize(w: Int(imageSize.width / 4.8), h: Int(imageSize.height / 4.8))
                                
                                DispatchQueue.main.async {
                                    self.siteTitle?.stringValue = siteName
                                    self.capturingSitePreview?.image = resizedImage
                                }
                                
                                let printView = self.preparingPrintView(image!, name: siteName)
                                
                                scheduleController.printViews.append(printView)
                                
                                self.numberOfFinishedCaptureSite += 1
                                
                                if self.numberOfFinishedCaptureSite == scheduleController.schedule.captureSiteGroups[self.numberOfFinishedCaptureSiteGroup].captureSites.count {
                                    
                                    let groupName = scheduleController.schedule.captureSiteGroups[self.numberOfFinishedCaptureSiteGroup].groupName
                                    
                                    let printGroupView = self.printGroupMake(printViews: scheduleController.printViews, name: groupName)
                                    
                                    scheduleController.printGroupViews.append(printGroupView)
                                    
                                    scheduleController.printViews.removeAll()
                                    
                                    self.numberOfFinishedCaptureSite = 0
                                    
                                    self.numberOfFinishedCaptureSiteGroup += 1
                                    
                                    if self.numberOfFinishedCaptureSiteGroup == scheduleController.schedule.captureSiteGroups.count {
                                        
                                        let imageRep = self.test2(printGroupViews: scheduleController.printGroupViews)
                                        
                                        scheduleController.printGroupViews.removeAll()
                                        
                                        guard let data = imageRep.representation(using: .jpeg, properties: [NSBitmapImageRep.PropertyKey.compressionFactor:0.8]) else { return }
                                        
                                        if let testURL = self.testURL {
                                            do {
                                                try data.write(to: testURL)
                                            } catch {
                                                print(error)
                                            }

                                        } else {
                                            
                                            if scheduleController.schedule.emailAttachType == .imageFile {
                                                self.sendingEmail(webViewLink: nil, data: data, date: Date())
                                            } else {
                                                self.uploadingGDrive(data: data, date: Date())
                                            }

                                            
                                            // Workato Integration
                                            
                                            let defaults = UserDefaults.standard
                                            
                                            if defaults.bool(forKey: "workatoEnable") {
                                                
                                                if let webhookAddressString = defaults.string(forKey: "webhookAddress") {
                                                    let workatoPostController =  WorkatoPostController(webhookAddress: webhookAddressString)
                                                    workatoPostController.sendWithTimestamp(date: PersistantData.sharedInstance.captureStartDate!)
                                                }
                                            }
                                            
                                        }
                                        
                                        self.dismiss(nil)
                                        
                                    }
                                    self.captureSiteGroupProcessQueue.isSuspended = false
                                }
                                self.captureSiteProcessQueue.isSuspended = false
                            }
                        }
                    })
                }
            })
        }
    }
}

