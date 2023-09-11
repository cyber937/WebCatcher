//
//  DataHandler.swift
//  WebCatcher
//
//  Created by Kiyoshi on 10/15/18.
//  Copyright © 2018 Digital Bytes Inc. All rights reserved.
//

import Foundation

class DataHandler {
    func loadingSchedules(url: URL) {
        
        do {
            let data = try Data(contentsOf: url, options:[])
            
            PersistantData.sharedInstance.scheduleControllers.removeAll()
            
            let decoder = JSONDecoder()
            let schedules = try decoder.decode([Schedule].self, from: data)
            
            for schedule in schedules {
                let scheduleController = ScheduleController(schedule: schedule)
                PersistantData.sharedInstance.scheduleControllers.append(scheduleController)
            }
            
        } catch {
            print(error)
        }
    }
    
    func savingSchedules(url: URL) {
        
        var schedules = [Schedule]()
        for scheduleController in PersistantData.sharedInstance.scheduleControllers {
            schedules.append(scheduleController.schedule)
        }
        
        if let encodedData = try? JSONEncoder().encode(schedules) {
            do {
                try encodedData.write(to: url)
            } catch {
                print(error)
            }
        }
    }
    
    func savingSetting() {
        
        var schedules = [Schedule]()
        for scheduleController in PersistantData.sharedInstance.scheduleControllers {
            schedules.append(scheduleController.schedule)
        }
        
        if let encodedData = try? JSONEncoder().encode(schedules) {
            do {
                
                // Finding app apecific document folder url
                let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                let documentsURL = urls[0]
                
                // Making url for app setting file
                let settingFileURL = documentsURL.appendingPathComponent("setting")
                
                try encodedData.write(to: settingFileURL)
            } catch {
                print(error)
            }
        }
    }
}
