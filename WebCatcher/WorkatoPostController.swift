//
//  WorkatoPostController.swift
//  WebCatcher
//
//  Created by Kiyoshi Nagahama on 6/25/19.
//  Copyright © 2019 Digital Bytes Inc. All rights reserved.
//

import Cocoa

struct WokatoData: Codable {
    var version: String
    var startDate: String
}

class WorkatoPostController {
    
    var webhookAddress: String?
    
    init(webhookAddress: String) {
        self.webhookAddress = webhookAddress
    }
    
    func sendWithTimestamp(date: Date) {
        let dateForJSONFormatter = DateFormatter()
        dateForJSONFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let dateForJSONString = dateForJSONFormatter.string(from: date)
        
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        
        let sendingData = WokatoData(version: appVersion!, startDate: dateForJSONString)
        
        let encoder = JSONEncoder()
        
        let data = try! encoder.encode(sendingData)
        
        let url = URL(string: self.webhookAddress!)!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = data
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("error: \(error)")
            } else {
                if let response = response as? HTTPURLResponse {
                    print("statusCode: \(response.statusCode)")
                }
                
                if let data = data, let dataString = String(data: data, encoding: .utf8) {
                    print("data: \(dataString)")
                }
                
            }
        }
        
        task.resume()
        
    }
    
}
