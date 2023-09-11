//
//  ScheduleController.swift
//  Scheduler
//
//  Created by Kiyoshi on 10/2/18.
//  Copyright © 2018 Digital Bytes. All rights reserved.
//

import Cocoa
import WebKit

final class ScheduleViewController: NSViewController {

    // MARK: Outlets
    
    @IBOutlet weak var scheduleName: NSTextField!
    @IBOutlet weak var captureSiteGroupListView: NSTableView!
    @IBOutlet weak var captureSiteGroupAddRemoveSegment: NSSegmentedControl!
    
    // MARK: Schedule Outlets
    @IBOutlet weak var frequencyMenu: NSPopUpButton!
    @IBOutlet weak var weekdayMenu: NSPopUpButton!
    @IBOutlet weak var dateMenu: NSPopUpButton!
    @IBOutlet weak var timePicker: NSDatePicker!
    
    // MARK: Buffer Time Outlets
    @IBOutlet weak var bufferTime: NSTextField!
    
    // MARK: Email Outlets
    @IBOutlet weak var emailToTokenField: NSTokenField!
    @IBOutlet weak var emailSubjectTextField: NSTextField!
    @IBOutlet weak var emailMessageTextField: NSTextField!
    @IBOutlet weak var emailAttachmentType: NSPopUpButton!
    
    // MARK: Control Outlets
    @IBOutlet weak var createButton: NSButton!
    @IBOutlet weak var updateButton: NSButton!
    
    // MARK: Properties
    var captureSiteGroups = [CaptureSiteGroup]()
    var scheduleController: ScheduleController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let onlyIntFormatter = OnlyIntegerValueFormatter()
        bufferTime.formatter = onlyIntFormatter
        
        guard let scheduleController = scheduleController else {
            
            createButton.isHidden = false
            updateButton.isHidden = true
            
            scheduleName.stringValue = "Untitle Schedule"
            
            bufferTime.stringValue = "5"
            
            weekdayMenu.isHidden = true
            dateMenu.isHidden = true
            
            return
        }
        
        createButton.isHidden = true
        updateButton.isHidden = false
        
        scheduleName.stringValue = scheduleController.schedule.scheduleTitle
        captureSiteGroups = scheduleController.schedule.captureSiteGroups
        
        bufferTime.stringValue = String(scheduleController.schedule.bufferTime)
        
        frequencyMenu.selectItem(withTag: scheduleController.schedule.type.rawValue)
        
        let calendar = Calendar.current
        let tergetDate = calendar.date(bySettingHour: scheduleController.schedule.hour, minute: scheduleController.schedule.minute, second: 0, of: Date())
        
        timePicker.dateValue = tergetDate!
        
        switch scheduleController.schedule.type {
        case .everyday:
            weekdayMenu.isHidden = true
            dateMenu.isHidden = true
        case .everyweek:
            weekdayMenu.isHidden = false
            weekdayMenu.selectItem(withTag: scheduleController.schedule.weekday!)
            dateMenu.isHidden = true
        }
        
        var emailTokenStringValue = ""
        for (index, emailAddress) in scheduleController.schedule.emailAddress.enumerated() {
            emailTokenStringValue = emailTokenStringValue + emailAddress
            if index < scheduleController.schedule.emailAddress.count {
                emailTokenStringValue = emailTokenStringValue + ","
            }
        }
        
        emailToTokenField.stringValue = emailTokenStringValue
        emailSubjectTextField.stringValue = scheduleController.schedule.emailSubject
        emailMessageTextField.stringValue = scheduleController.schedule.emailBody
        
        if scheduleController.schedule.emailAttachType == .imageFile {
            emailAttachmentType.selectItem(withTag: 0)
        } else {
            emailAttachmentType.selectItem(withTag: 1)
        }
        
    }
    
    @IBAction func pushSiteGroupControllSegment(_ sender: NSSegmentedCell) {
        switch sender.selectedSegment {
        case 0:
            addCaptureSiteGroup()
        case 1:
            removeCaptureSiteGroup()
        default:
            break
        }
    }
    
    private func addCaptureSiteGroup() {
        let mainStoryBoard = NSStoryboard(name: "Main", bundle: nil)
        let captureSiteGroupViewController = mainStoryBoard.instantiateController(withIdentifier: "CaptureSiteGroupViewController") as! CaptureSiteGroupViewController
        captureSiteGroupViewController.delegate = self
        self.presentAsSheet(captureSiteGroupViewController)
    }
    
    private func removeCaptureSiteGroup() {
        captureSiteGroups.remove(at: captureSiteGroupListView.selectedRow)
        captureSiteGroupListView.reloadData()
        captureSiteGroupAddRemoveSegment.setEnabled(false, forSegment: 1)
    }
    
    @IBAction func pushCreateButton(_ sender: Any) {

        // Schedule Type
        guard let scheduleType = ScheduleType(rawValue: frequencyMenu.selectedTag()) else { return }
        
        // If Schedule Type is Weekday
        var weekday: Int?
        if scheduleType == .everyweek {
            weekday = weekdayMenu.indexOfSelectedItem
        }
        
        // Time
        let selectedDate = timePicker.dateValue
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: selectedDate)
        let minutes = calendar.component(.minute, from: selectedDate)
        
        var schedule = Schedule(name: scheduleName.stringValue,
                                type: scheduleType,
                                weekday: weekday,
                                hour: hour,
                                minute: minutes,
                                captureSiteGroups: captureSiteGroups)

        schedule.bufferTime = Int(bufferTime.stringValue)!
        
        let emailAddressString = emailToTokenField.stringValue
        schedule.emailAddress = emailAddressString.components(separatedBy: ",")
        schedule.emailSubject = emailSubjectTextField.stringValue
        schedule.emailBody = emailMessageTextField.stringValue

        if emailAttachmentType.selectedTag() == 0 {
            schedule.emailAttachType = .imageFile
        } else {
            schedule.emailAttachType = .googleDriveLink
        }
        
        let scheduleController = ScheduleController(schedule: schedule)
        PersistantData.sharedInstance.scheduleControllers.append(scheduleController)
        (presentingViewController as! WebCatcherController).scheduleView.reloadData()

        DataHandler().savingSetting()
        
        self.dismiss(nil)
    }
    
    @IBAction func pushUpdateButton(_ sender: Any) {

        guard let scheduleController = scheduleController else { return }
        
        scheduleController.schedule.scheduleTitle = scheduleName.stringValue
        scheduleController.schedule.captureSiteGroups.removeAll()
        
        captureSiteGroups.forEach {
            var captureSiteGroup = CaptureSiteGroup(groupName: $0.groupName)
            captureSiteGroup.captureSites = $0.captureSites
            scheduleController.schedule.captureSiteGroups.append(captureSiteGroup)
        }
        
        scheduleController.schedule.bufferTime = Int(bufferTime.stringValue)!
        
        let selectedDate = timePicker.dateValue
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: selectedDate)
        let minutes = calendar.component(.minute, from: selectedDate)

        
        scheduleController.schedule.hour = hour
        scheduleController.schedule.minute = minutes

        switch scheduleController.schedule.type {
        case .everyday:
            scheduleController.schedule.weekday = nil
        case .everyweek:
            scheduleController.schedule.weekday =  weekdayMenu.indexOfSelectedItem
        }

        let emailAddressString = emailToTokenField.stringValue
        scheduleController.schedule.emailAddress = emailAddressString.components(separatedBy: ",")
        scheduleController.schedule.emailSubject = emailSubjectTextField.stringValue
        scheduleController.schedule.emailBody = emailMessageTextField.stringValue
        
        if emailAttachmentType.selectedTag() == 0 {
            scheduleController.schedule.emailAttachType = .imageFile
        } else {
            scheduleController.schedule.emailAttachType = .googleDriveLink
        }
        
        (presentingViewController as! WebCatcherController).scheduleView.reloadData()

        DataHandler().savingSetting()
        
        self.dismiss(nil)
    }
    
    @IBAction func pushCancelButton(_ sender: Any) {
        self.dismiss(nil)
    }
    
    @IBAction func selectFrequenceyMenu(_ sender: NSPopUpButton) {
        
        guard let scheduleType = ScheduleType(rawValue: sender.indexOfSelectedItem) else { return }
        
        switch scheduleType {
            
        case .everyday:
            weekdayMenu.isHidden = true
            dateMenu.isHidden = true
            
        case .everyweek:
            weekdayMenu.isHidden = false
            dateMenu.isHidden = true
        }
        
        scheduleController?.schedule.type = scheduleType
    }
}
