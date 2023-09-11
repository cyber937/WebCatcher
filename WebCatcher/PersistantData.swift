//
//  PersistantData.swift
//  WebCatcher
//
//  Created by Kiyoshi on 10/15/18.
//  Copyright © 2018 Digital Bytes Inc. All rights reserved.
//

import Foundation
import GoogleAPIClientForREST

class PersistantData {
    static let sharedInstance: PersistantData = {

        let instance = PersistantData()
        
        return instance
        
    }()
    
    var scheduleControllers = [ScheduleController]()
    var fileURL: URL?
    var driveService = GTLRDriveService()
    var activityLog = AccessActivityLogText()
    var captureStartDate: Date?
}
