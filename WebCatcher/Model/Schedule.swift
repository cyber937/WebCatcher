//
//  Schedule.swift
//  Scheduler
//
//  Created by Kiyoshi on 10/2/18.
//  Copyright © 2018 Digital Bytes. All rights reserved.
//

import Cocoa

//MARK: Schedule Model

enum ScheduleType: Int, Codable {
    case everyday = 0
    case everyweek
}

enum EmailAttachType: String, Codable {
    case imageFile
    case googleDriveLink
}

struct Schedule: Codable {

    var scheduleTitle: String
    let uuid: UUID
    
    // MARK: CaptureSite
    
    var captureSiteGroups: [CaptureSiteGroup]
    
    
    // MARK: Schedule Information
    
    var type:           ScheduleType
    var weekday:        Int?
    var hour:           Int
    var minute:         Int
    
    
    // MARK: Email Information
    
    var emailAddress: [String]
    var emailSubject: String
    var emailBody: String
    var emailAttachType: EmailAttachType
    
    var isTimerStarted: Bool
    
    var bufferTime: Int
    
    init(name: String,
         type: ScheduleType,
         weekday: Int? = nil,
         hour: Int,
         minute: Int,
         captureSiteGroups: [CaptureSiteGroup]) {
        
        self.scheduleTitle = name
        self.uuid = UUID()
        self.type = type
        
        self.weekday = weekday
        
        self.hour = hour
        self.minute = minute
        
        self.captureSiteGroups = captureSiteGroups
        
        self.emailAddress = []
        self.emailSubject = ""
        self.emailBody = ""
        self.emailAttachType = .imageFile
        
        self.isTimerStarted = false
        self.bufferTime = 5
    }
}

//MARK: CaptureSite Model

struct CaptureSite: Codable {
    var siteName:   String
    var url:    URL
}

struct CaptureSiteGroup: Codable {
    var groupName: String = ""
    var captureSites = [CaptureSite]()
    
    init(groupName: String) {
        self.groupName = groupName
    }
}

extension Schedule {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        scheduleTitle =     try values.decode(String.self, forKey: .scheduleTitle)
        uuid =              try values.decode(UUID.self, forKey: .uuid)
        captureSiteGroups = try values.decode([CaptureSiteGroup].self, forKey: .captureSiteGroups)
        type =              try values.decode(ScheduleType.self, forKey: .type)
        hour =              try values.decode(Int.self, forKey: .hour)
        minute =            try values.decode(Int.self, forKey: .minute)
        emailAddress =      try values.decode([String].self, forKey: .emailAddress)
        emailSubject =      try values.decode(String.self, forKey: .emailSubject)
        emailBody =         try values.decode(String.self, forKey: .emailBody)
        isTimerStarted =    try values.decode(Bool.self, forKey: .isTimerStarted)
        bufferTime =        try values.decode(Int.self, forKey: .bufferTime)
        
        if values.contains(.weekday) {
            weekday = try values.decode(Int?.self, forKey: .weekday)
        } else {
            weekday = nil
        }
        
        if values.contains(.emailAttachType) {
            emailAttachType =  try values.decode(EmailAttachType.self, forKey: .emailAttachType)
        } else {
            emailAttachType = .imageFile
        }
    }
}
