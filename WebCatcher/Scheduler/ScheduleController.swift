//
//  ScheduleController.swift
//  WebCatcher
//
//  Created by Kiyoshi on 11/7/18.
//  Copyright © 2018 Digital Bytes Inc. All rights reserved.
//

import Foundation
import WebKit
import Quartz

final class ScheduleController {

    var schedule: Schedule
    var timer: DispatchSourceTimer?
    
    var printViews = [NSImageView]()
    var printGroupViews = [NSImageView]()
    var printPage = NSView(frame: NSMakeRect(0.0, 0.0, 600.0, 100))
    
    var processIndex = 0
    
    init(schedule: Schedule) {
        self.schedule = schedule
    }
    
    func cancelTimer() {
        timer?.cancel()
        timer = nil
    }
    
    func activityInterval() -> Int {
        
        var interval: TimeInterval
        
        switch schedule.type {
        case .everyday:
            interval = TimeInterval(24 * 60 * 60)
        case .everyweek:
            interval = TimeInterval(7 * 24 * 60 * 60)
        }
        
        let reult = Int(interval)
        
        return reult
    }
    
    func description() -> String? {
        
        var descriptionString: String
        
        switch schedule.type {
        case .everyday:
            descriptionString = "Everyday - "
        case .everyweek:
            guard let weekday = schedule.weekday,
                let readableWeekday = readableWeekday(from: weekday) else { return nil }
            descriptionString = "Every \(readableWeekday) - "
        }
        
        let calendar = Calendar.current
        guard let tergetDate = calendar.date(bySettingHour: schedule.hour, minute: schedule.minute, second: 0, of: Date()) else {
            print("Cannot create targetDate")
            return nil
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        descriptionString = descriptionString + dateFormatter.string(from: tergetDate)
        
        return descriptionString
    }
    
    func readableWeekday(from: Int) -> String? {
        
        var readableWeekdayString: String = ""
        
        switch from {
        case 0:
            readableWeekdayString = "Sunday"
        case 1:
            readableWeekdayString = "Monday"
        case 2:
            readableWeekdayString = "Tuesday"
        case 3:
            readableWeekdayString = "Wednesday"
        case 4:
            readableWeekdayString = "Thursday"
        case 5:
            readableWeekdayString = "Friday"
        case 6:
            readableWeekdayString = "Saturday"
        default:
            return nil
        }
        
        return readableWeekdayString
    }
    
    func nextDate() -> Date? {
        
        var targetDateComponents: DateComponents
        
        switch schedule.type {
        case .everyday:
            targetDateComponents = DateComponents(hour: schedule.hour, minute: schedule.minute)
        case .everyweek:
            targetDateComponents = DateComponents(hour: schedule.hour, minute: schedule.minute, weekday: schedule.weekday! + 1)
        }
        
        let calendar = Calendar.current
        
        let targetDate = calendar.nextDate(after: Date(), matching: targetDateComponents, matchingPolicy:.nextTime)
        
        return targetDate
    }
}
