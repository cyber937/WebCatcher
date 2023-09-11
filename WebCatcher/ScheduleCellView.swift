//
//  ScheduleCellView.swift
//  Scheduler
//
//  Created by Kiyoshi on 10/2/18.
//  Copyright © 2018 Digital Bytes. All rights reserved.
//

import Cocoa

protocol ScheduleCellViewDelegate {
    func startSchedule(row: Int)
    func editSchedule(row: Int)
    func removeSchedule(row: Int)
    func testSchedule(row: Int)
}

class ScheduleCellView: NSTableCellView {

    @IBOutlet weak var scheduleName: NSTextField!
    @IBOutlet weak var scheduleString: NSTextField!
    @IBOutlet weak var scheduleStartStopButton: NSButton!
    @IBOutlet weak var scheduleEditButton: NSButton!
    @IBOutlet weak var scheduleRemoveButton: NSButton!
    @IBOutlet weak var scheduleTestButton: NSButton!
    
    var row: Int!
    weak var delegate: WebCatcherController?
    
    /// Start & Stop Button Action
    
    @IBAction func pushScheduleStartStopButton(_ sender: NSButton) {
        
        let emailAttachType = PersistantData.sharedInstance.scheduleControllers[row].schedule.emailAttachType
        
        if emailAttachType == .googleDriveLink {
            
            guard let _ = PersistantData.sharedInstance.driveService.authorizer else {
                
                let alert = NSAlert()
                alert.messageText = "Error - Cannot access Google account:"
                alert.informativeText = "Please sign into your Google account from 'WebWatcher>Preferences>Google Drive'."
                alert.alertStyle = .warning
                alert.addButton(withTitle: "OK")
                alert.runModal()
                
                return
            }
        }
        
        if sender.title == "Start" {
            
            print("User Start the schedule")
            
            sender.title = "Stop"
            PersistantData.sharedInstance.scheduleControllers[row].schedule.isTimerStarted = true
            delegate?.startSchedule(row: row)
            scheduleEditButton.isEnabled = false
            scheduleRemoveButton.isEnabled = false
            scheduleTestButton.isEnabled = false
            
        } else {
            
            print("User Stop the schedule")
            
            sender.title = "Start"
            PersistantData.sharedInstance.scheduleControllers[row].schedule.isTimerStarted = false
            PersistantData.sharedInstance.scheduleControllers[row].cancelTimer()
            scheduleEditButton.isEnabled = true
            scheduleRemoveButton.isEnabled = true
            scheduleTestButton.isEnabled = true
        }
        
    }
    
    @IBAction func pushScheduleEditButton(_ sender: NSButton) {
        delegate?.editSchedule(row: row)
    }
    
    @IBAction func pushScheduleRemoveButton(_ sender: NSButton) {
        delegate?.removeSchedule(row: row)
    }
    
    @IBAction func pushScheduleTestButton(_ sender: NSButton) {
        delegate?.testSchedule(row: row)
    }

}

