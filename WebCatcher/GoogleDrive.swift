//
//  GoogleDrive.swift
//  WebCatcher
//
//  Created by Kiyoshi Nagahama on 10/29/18.
//  Copyright © 2018 Digital Bytes Inc. All rights reserved.
//

import Foundation
import AppAuth
import GTMAppAuth
import GoogleAPIClientForREST

class GDrive {

    private let service: GTLRDriveService

    init(_ service: GTLRDriveService) {
        self.service = service
    }
    
    public func createFolder(_ folderName:     String,
                             completeHandler:  @escaping (String?, Error?) -> ()) {
        
        let file = GTLRDrive_File()
        file.name = folderName
        file.mimeType = "application/vnd.google-apps.folder"
        
        let query = GTLRDriveQuery_FilesCreate.query(withObject: file, uploadParameters: nil)
        query.fields = "id"
        
        service.executeQuery(query) { (ticket, folder, error) in
            completeHandler((folder as? GTLRDrive_File)?.identifier, error)
        }
    }
    
    public func search(_ fileName: String, completeHandler: @escaping (String?, Error?) -> ()) {
        let query = GTLRDriveQuery_FilesList.query()
        query.pageSize = 1
        query.q = "name contains '\(fileName)'"
        
        service.executeQuery(query) { (ticket, results, error) in
            completeHandler((results as? GTLRDrive_FileList)?.files?.first?.identifier, error)
        }
    }
    
    public func updatePermissionToOpenPublic(_ fileID: String) {
        let persmission = GTLRDrive_Permission(json: ["type":"anyone", "role":"reader"])
         let query = GTLRDriveQuery_PermissionsCreate.query(withObject: persmission, fileId: fileID)
        service.executeQuery(query) { (ticket, results, error) in
            guard let error = error else { return }
            print(error)
        }
    }
    
    public func uploadFile(_ folderName: String, fileName: String, data: Data, MIMEType: String, completeHandler: @escaping ((String?, Error?) -> ())) {
        search(folderName) { (folderID, error) in
            if let ID = folderID {
                self.upload(ID, fileName: fileName, data: data, MIMEType: MIMEType, completeHandler: completeHandler)
            } else {
                self.createFolder(folderName, completeHandler: { (folderID, error) in
                    if let ID = folderID {
                        self.upload(ID, fileName: fileName, data: data, MIMEType: MIMEType, completeHandler: completeHandler)
                    }
                })
            }
        }
    }
    
    public func upload(_ parentID: String,
                       fileName: String,
                       data: Data,
                       MIMEType: String,
                       completeHandler: @escaping ((String?, Error?) -> ())) {
        
        let file = GTLRDrive_File()
        file.name = fileName
        file.parents = [parentID]
        
        let uploadParams = GTLRUploadParameters.init(data: data, mimeType: MIMEType)
        uploadParams.shouldUploadWithSingleRequest = true
        
        let query = GTLRDriveQuery_FilesCreate.query(withObject: file, uploadParameters: uploadParams)
        
        self.service.executeQuery(query, completionHandler: { (ticket, file, error) in
            completeHandler((file as? GTLRDrive_File)?.identifier, error)
        })
    }
}
