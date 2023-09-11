//
//  ActivityLogController.swift
//  WebCatcher
//
//  Created by Kiyoshi Nagahama on 2/13/19.
//  Copyright © 2019 Digital Bytes Inc. All rights reserved.
//

import Cocoa

class ActivityLogController: NSViewController {

    @IBOutlet var activityLogTextView: NSTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(activityLogUpdated(_:)),
                                               name: .activityLogUpdated,
                                               object: nil)
    }
    
    override func viewWillAppear() {
        activityLogTextView.string = PersistantData.sharedInstance.activityLog
    }
    
    @objc func activityLogUpdated(_ notification: Notification) {
        activityLogTextView.string = PersistantData.sharedInstance.activityLog
    }
    
    @IBAction func pushExportButton(_ sender: NSButton) {
        let exportSettingPanel = NSSavePanel()
        exportSettingPanel.allowedFileTypes = ["txt"]
        exportSettingPanel.title = "Export Activity Log"
        let i = exportSettingPanel.runModal()
        if (i == NSApplication.ModalResponse.OK){
            
            guard let exportingLocationURL = exportSettingPanel.url else {
                print("")
                return
            }
            
            do {
                try AccessActivityLogText().write(to: exportingLocationURL, atomically: true, encoding: .utf8)
            } catch {
                print(error)
            }
            
        }
    }
    
}

func AccessActivityLogText() -> String {
    
    var activityLogText: String = ""
    
    if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last {
        
        let activityLogURL = documentsDirectory.appendingPathComponent("activitylog.txt")
        
        let fileManager = FileManager.default
        
        if fileManager.fileExists(atPath: activityLogURL.path) {
            
            do {
                activityLogText = try String(contentsOf: activityLogURL, encoding: .utf8)
            } catch {
                print("Error:", error)
            }
            
        } else {
            // If activitylog file is not available
            
            activityLogText += "Activity Log - Version 1.0\n\n"
            
            do {
                try activityLogText.write(to: activityLogURL, atomically: false, encoding: .utf8)
            } catch {
                print("Error:", error)
            }
            
        }
    }
    return activityLogText
}
