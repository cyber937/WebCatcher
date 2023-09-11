//
//  WebCatcherController_ScheduleDelegate.swift
//  WebCatcher
//
//  Created by Kiyoshi on 10/8/18.
//  Copyright © 2018 Digital Bytes Inc. All rights reserved.
//

import Cocoa

extension WebCatcherController: NSTableViewDataSource, NSTableViewDelegate {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return PersistantData.sharedInstance.scheduleControllers.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let scheduleController = PersistantData.sharedInstance.scheduleControllers[row]
        
        let result: ScheduleCellView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "Schedule"), owner: self) as! ScheduleCellView
        
        result.scheduleName.stringValue = scheduleController.schedule.scheduleTitle
        result.scheduleString.stringValue = scheduleController.description()!
        
//        if scheduleController.schedule.isTimerStarted {
//            result.scheduleStartStopButton.title = "Stop"
//            result.scheduleEditButton.isEnabled = false
//            result.scheduleRemoveButton.isEnabled = false
//        } else {
//            result.scheduleStartStopButton.title = "Start"
//            result.scheduleEditButton.isEnabled = true
//            result.scheduleRemoveButton.isEnabled = true
//        }
        
        result.row = row
        result.delegate = self
        
        return result
        
    }
}
