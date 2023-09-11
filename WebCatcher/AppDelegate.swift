//
//  AppDelegate.swift
//  WebCatcher
//
//  Created by Kiyoshi Nagahama on 9/29/18.
//  Copyright © 2018 Digital Bytes Inc. All rights reserved.
//

import Cocoa
import AppAuth
import GTMAppAuth
import GoogleAPIClientForREST

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let authorization = GTMAppAuthFetcherAuthorization(fromKeychainForName: kGTMAppAuthKeychainItemName)
        PersistantData.sharedInstance.driveService.authorizer = authorization
        
        // Finding app apecific document folder url
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last {
            
            let settingFileURL = documentsDirectory.appendingPathComponent("setting")
        
            let fileManager = FileManager.default
            
            if fileManager.fileExists(atPath: settingFileURL.path) {
                DataHandler().loadingSchedules(url: settingFileURL)
                
                let nc = NotificationCenter.default
                nc.post(name:       .archivedScheduleDataLoaded,
                        object:     nil)
            }
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        DataHandler().savingSetting()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    @IBAction func importSetting(_ sender: Any)  {
        let importSettingPanel = NSOpenPanel()
        importSettingPanel.allowedFileTypes = ["wc"]
        importSettingPanel.title = "Import Setting"
        let i = importSettingPanel.runModal()
        if (i == NSApplication.ModalResponse.OK){
            
            guard let importingSettingURL = importSettingPanel.url else {
                print("")
                return
            }
            
            DataHandler().loadingSchedules(url: importingSettingURL)
            
            NotificationCenter.default.post(name:       .archivedScheduleDataLoaded,
                                            object:     nil)
            
            DataHandler().savingSetting()
            
        }
    }

    @IBAction func exportSetting(_ sender: Any) {
        let exportSettingPanel = NSSavePanel()
        exportSettingPanel.allowedFileTypes = ["wc"]
        exportSettingPanel.title = "Export Setting"
        let i = exportSettingPanel.runModal()
        if (i == NSApplication.ModalResponse.OK){
            
            guard let exportingLocationURL = exportSettingPanel.url else {
                print("")
                return
            }
            
            DataHandler().savingSchedules(url: exportingLocationURL)
        }
    }
    
}

