//
//  ScheduleCreateController.swift
//  Scheduler
//
//  Created by Kiyoshi on 10/2/18.
//  Copyright © 2018 Digital Bytes. All rights reserved.
//

import Cocoa

class ScheduleCreateController: NSViewController {

    @IBOutlet weak var frequencyMenu: NSPopUpButton!
    @IBOutlet weak var weekdayMenu: NSPopUpButton!
    @IBOutlet weak var dateMenu: NSPopUpButton!
    
    @IBOutlet weak var timePicker: NSDatePicker!
    
    var scheduleType: ScheduleType = .everyday
    
    override func viewDidLoad() {
        super.viewDidLoad()
        weekdayMenu.isHidden = true
        dateMenu.isHidden = true
    }
    
    @IBAction func pushOkButton(_ sender: Any) {
        let selectedDate = timePicker.dateValue
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: selectedDate)
        let minutes = calendar.component(.minute, from: selectedDate)
        
        var schedule: Schedule
        
        switch scheduleType {
        case .everyday:
            schedule = Schedule(type: .everyday, hour: hour, minute: minutes)
        case .everyweek:
            schedule = Schedule(type: .everyweek, weekday: weekdayMenu.indexOfSelectedItem, hour: hour, minute: minutes)
        case .everymonth:
            schedule = Schedule(type: .everymonth, day: dateMenu.indexOfSelectedItem, hour: hour, minute: minutes)
        }
        
        if let scheduleDescription = schedule.description(), 
            let nextDate = schedule.nextDate() {
            print("\(scheduleDescription)")
            print("\(nextDate.description)")
        }
    }
    
    @IBAction func pushCancelButton(_ sender: Any) {
        self.dismiss(nil)
    }
    
    @IBAction func selectFrequenceyMenu(_ sender: NSPopUpButton) {
        
        guard let scheduleType = ScheduleType(rawValue: sender.indexOfSelectedItem) else { return }
        
        self.scheduleType = scheduleType
        
        switch self.scheduleType {
            
        case .everyday:
            weekdayMenu.isHidden = true
            dateMenu.isHidden = true
            
        case .everyweek:
            weekdayMenu.isHidden = false
            dateMenu.isHidden = true
            
        case .everymonth:
            weekdayMenu.isHidden = true
            dateMenu.isHidden = false
        }
        
    }
    
}
