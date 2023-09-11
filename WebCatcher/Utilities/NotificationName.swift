//
//  NotificationName.swift
//  WebCatcher
//
//  Created by Kiyoshi on 10/23/18.
//  Copyright © 2018 Digital Bytes Inc. All rights reserved.
//

import Foundation

extension Notification.Name {
    
    
    static let webSnapshotProcessDone = Notification.Name("WebSnapshotProcessDone")
    
    static let archivedScheduleDataLoaded = Notification.Name("ArchivedScheduleDataLoaded")
    
    static let urlTableSelected = Notification.Name("URLTableSelectd")
    static let urlTableDeselected = Notification.Name("URLTableDeselectd")
    
    static let snapshotProcessViewControllerClose = Notification.Name("SnapshotProcessViewControllerClose")
    
    static let activityLogUpdated = Notification.Name("ActivityLogUpdated")
}
