//
//  WokatoController.swift
//  WebCatcher
//
//  Created by Kiyoshi Nagahama on 6/25/19.
//  Copyright © 2019 Digital Bytes Inc. All rights reserved.
//

import Cocoa

class WorkatoController: NSViewController, NSTextFieldDelegate {

    @IBOutlet weak var enableButton: NSButton!
    
    @IBOutlet weak var webhookAddress: NSTextField!
    
    @IBOutlet weak var updateButton: NSButton!
    
    var workatoEnable: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults = UserDefaults.standard
        
        workatoEnable = defaults.bool(forKey: "workatoEnable")
        
        if workatoEnable {
            self.enableButton.state = .on
            self.webhookAddress.isEnabled = true
        }
        
        if let webhookAddressString = defaults.string(forKey: "webhookAddress") {
            webhookAddress.stringValue = webhookAddressString
        }
        
    }


    @IBAction func pushEnableButton(_ sender: NSButton) {
        switch sender.state {
        case .on:
            self.webhookAddress.isEnabled = true
            self.workatoEnable = true
        case .off:
            self.webhookAddress.isEnabled = false
            self.workatoEnable = false
        default:
            break
        }
        updateButton.isEnabled = true
    }
    
    @IBAction func pushUpdateButton(_ sender: NSButton) {
        let defaults = UserDefaults.standard
        defaults.set(self.workatoEnable, forKey: "workatoEnable")
        defaults.set(self.webhookAddress.stringValue, forKey: "webhookAddress")
    }
    
    func controlTextDidChange(_ obj: Notification) {
        updateButton.isEnabled = true
    }

    
    
}
