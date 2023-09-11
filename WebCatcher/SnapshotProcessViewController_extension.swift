//
//  SnapshotProcessViewController_extension.swift
//  WebCatcher
//
//  Created by Kiyoshi on 11/15/18.
//  Copyright © 2018 Digital Bytes Inc. All rights reserved.
//

import Cocoa
import Quartz
import GoogleAPIClientForREST

extension SnapshotProcessViewController {
    
    func printGroupMake(printViews: [NSImageView], name: String) -> NSImageView {
        
        var maxHight: CGFloat = 0.0
        
        for printView in printViews {
            if maxHight < printView.frame.height {
                maxHight = printView.frame.height
            }
        }
        
        let printGroupView = NSImageView(frame: NSMakeRect(0.0, 0.0, 2610.0, maxHight))
        
        for (index, printView) in printViews.enumerated() {
            printView.frame = NSMakeRect((CGFloat(index) * 670.0), printGroupView.frame.height - printView.frame.height, printView.frame.width, printView.frame.height)
            printGroupView.addSubview(printView)
        }
        
        let groupHeaderView = GroupPageHeaderView(title: name, date: Date())
        
        printGroupView.frame = NSMakeRect(0.0, 0.0, printGroupView.frame.width, printGroupView.frame.height + groupHeaderView.frame.height)
        
        groupHeaderView.frame = NSMakeRect(0.0, printGroupView.frame.height - groupHeaderView.frame.height, groupHeaderView.frame.width, groupHeaderView.frame.height)
        
        printGroupView.addSubview(groupHeaderView)
        
        return printGroupView
    }
    
    func test2(printGroupViews: [NSImageView]) -> NSBitmapImageRep{
        var maxHight: CGFloat = 0.0
        for printGroupView in printGroupViews {
            if maxHight < printGroupView.frame.height {
                maxHight = printGroupView.frame.height
            }
        }
        
        let finalView = NSImageView(frame: NSMakeRect(10.0, 0.0, 8450.0, maxHight + 10))
        
        for (index, printGroupView) in printGroupViews.enumerated() {
            printGroupView.frame = NSMakeRect((CGFloat(index) * 2910) + 10, finalView.frame.height - printGroupView.frame.height, printGroupView.frame.width, printGroupView.frame.height)
            finalView.addSubview(printGroupView)
        }
        
        let imageRepresentation = finalView.bitmapImageRepForCachingDisplay(in: finalView.bounds)
        finalView.cacheDisplay(in: finalView.bounds, to: imageRepresentation!)
        let imageRep = NSBitmapImageRep(cgImage: imageRepresentation!.cgImage!)
        
        return imageRep
    }
    
    func preparingPrintView(_ image: NSImage, name: String) -> NSImageView {
        let pageHeaderView = PageHeaderView(title: name)
        let resizedImage = image.resize(w: Int(image.size.width * 0.5), h: Int(image.size.height * 0.5))
        
        let imageView = NSImageView(frame: NSMakeRect(0.0, 0.0, resizedImage.size.width, resizedImage.size.height))
        imageView.image = resizedImage
        
        let printView = NSImageView(frame: NSMakeRect(0.0, 0.0, 600.0, pageHeaderView.frame.height + imageView.frame.height))
        printView.addSubview(imageView)
        
        pageHeaderView.frame = NSMakeRect(0.0, imageView.frame.height, pageHeaderView.frame.width, pageHeaderView.frame.height)
        printView.addSubview(pageHeaderView)
        
        return printView
    }
    
    func uploadingGDrive(data: Data, date: Date) {
        
        let service = GDrive(PersistantData.sharedInstance.driveService)
        
        let fileNameDateFormatter = DateFormatter()
        fileNameDateFormatter.dateFormat = "yyyy-MM-dd_HH:mma"
        let fileName = "\(fileNameDateFormatter.string(from: date)).jpg"
        
        service.search("WebCatcher") { (folderID, error) in
            if let folderID = folderID {
                service.upload(folderID, fileName: fileName, data: data, MIMEType: "image/jpeg") { (fileID, error) in
                    guard let fileID = fileID else { return }
                    
                    let query = GTLRDriveQuery_FilesList.query()
                    query.pageSize = 1
                    query.fields = "files(webViewLink)"
                    query.q = "name contains '\(fileName)'"
                    PersistantData.sharedInstance.driveService.executeQuery(query) { (ticket, results, error) in
                        
                        guard let webViewLink = (results as? GTLRDrive_FileList)?.files?.first?.webViewLink else { return }
                        
                        self.sendingEmail(webViewLink: webViewLink, data: nil, date: date)
                        
                    }
                    
                    service.updatePermissionToOpenPublic(fileID)
                }
            } else {
                service.createFolder("WebCatcher") { (folderID, error) in
                    if let folderID = folderID {
                        
                        service.upload(folderID, fileName: fileName, data: data, MIMEType: "application/pdf") { (fileID, error) in
                            guard let fileID = fileID else { return }
                            
                            let query = GTLRDriveQuery_FilesList.query()
                            query.pageSize = 1
                            query.fields = "files(webViewLink)"
                            query.q = "name contains '\(fileName)'"
                            PersistantData.sharedInstance.driveService.executeQuery(query) { (ticket, results, error) in
                                
                                guard let webViewLink = (results as? GTLRDrive_FileList)?.files?.first?.webViewLink else { return }
                                
                                 self.sendingEmail(webViewLink: webViewLink, data: nil, date: date)
                            }
                            
                            service.updatePermissionToOpenPublic(fileID)
                        }
                    }
                }
            }
        }

    }
    
    func sendingEmail(webViewLink: String?, data: Data?, date: Date) {
        
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let emailSentTimeStamp = dateFormatterPrint.string(from: date)
        
        let smtpSession = MCOSMTPSession()
        
        let defaults = UserDefaults.standard
        
        smtpSession.hostname = defaults.string(forKey: "hostName")
        smtpSession.username = defaults.string(forKey: "userName")
        smtpSession.password = defaults.string(forKey: "password")
        smtpSession.port = UInt32(defaults.integer(forKey: "port"))
        smtpSession.authType = MCOAuthType.saslPlain
        smtpSession.connectionType = MCOConnectionType.TLS

        let builder = MCOMessageBuilder()
        
        var emailAddresses = [MCOAddress]()
        
        for address in scheduleController!.schedule.emailAddress {
            emailAddresses.append(MCOAddress(displayName: address, mailbox: address))
        }
        
        builder.header.to = emailAddresses
        builder.header.from = MCOAddress(displayName: defaults.string(forKey: "userName"), mailbox: defaults.string(forKey: "userName"))
        
        let emailSubject = scheduleController!.schedule.emailSubject + " " + emailSentTimeStamp
        
        builder.header.subject = emailSubject
        
        builder.htmlBody="<p>\(scheduleController!.schedule.emailBody)</p>"
        
        if let webViewLink = webViewLink {
            builder.htmlBody += "<p>\(webViewLink)</p>"
        }
        
        builder.htmlBody += "<P>\(emailSentTimeStamp)</P>"
        
        if let data = data {
            let fileNameDateFormatter = DateFormatter()
            fileNameDateFormatter.dateFormat = "yyyy-MM-dd__HH_mma"
            let fileName = "\(fileNameDateFormatter.string(from: date)).jpg"
            let attachment = MCOAttachment(data: data, filename: fileName)
            builder.addAttachment(attachment!)
        }
        
        let rfc822Data = builder.data()
        let sendOperation = smtpSession.sendOperation(with: rfc822Data)
        sendOperation?.start { (error) -> Void in
            if (error != nil) {
                print("Error sending email: \(error!.localizedDescription)")
                
                PersistantData.sharedInstance.activityLog += "\(emailSentTimeStamp): Error sending email - \(error!.localizedDescription)\n\n"
                
                if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last {
                    
                    let activityLogURL = documentsDirectory.appendingPathComponent("activitylog.txt")
                
                    do {
                        try PersistantData.sharedInstance.activityLog.write(to: activityLogURL, atomically: false , encoding: .utf8)
                    } catch {
                        print("Error - \(error)")
                    }
                }

                let notification = NSUserNotification()
                notification.identifier = "tv.digitalbytes.WebCachter"
                notification.title = "WebCatcher"
                notification.subtitle = emailSentTimeStamp
                notification.informativeText = "Error sending email - \(error!.localizedDescription)"
                let notificationCenter = NSUserNotificationCenter.default
                notificationCenter.deliver(notification)
                
            } else {
                NSLog("Successfully sent email!")
                
                PersistantData.sharedInstance.activityLog += "\(emailSentTimeStamp): Successfully sent email.\n\n"
                
                    if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last {
                        
                        let activityLogURL = documentsDirectory.appendingPathComponent("activitylog.txt")
                        
                        do {
                            try PersistantData.sharedInstance.activityLog.write(to: activityLogURL, atomically: false , encoding: .utf8)
                        } catch {
                            print("Error: \(error)")
                        }
                    }

                let notification = NSUserNotification()
                notification.identifier = "tv.digitalbytes.WebCachter"
                notification.title = "WebCatcher"
                notification.subtitle = emailSentTimeStamp
                notification.informativeText = "Successfully sent email."
                let notificationCenter = NSUserNotificationCenter.default
                notificationCenter.deliver(notification)
            
            }
            
            NotificationCenter.default.post(name:       .activityLogUpdated,
                                            object:     nil,
                                            userInfo:   nil)
        }
    }
}
