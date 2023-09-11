//
//  PreferenceController.swift
//  WebCatcher
//
//  Created by Kiyoshi on 10/10/18.
//  Copyright © 2018 Digital Bytes Inc. All rights reserved.
//

import Cocoa

class EmailAccountController: NSViewController, NSTextFieldDelegate {
    
    @IBOutlet weak var hostName: NSTextField!
    
    @IBOutlet weak var userName: NSTextField!
    
    @IBOutlet weak var password: NSSecureTextField!
    
    @IBOutlet weak var passwordShowText: NSTextField!
    
    @IBOutlet weak var showHideSecureTextButton: NSButton!
    
    @IBOutlet weak var port: NSTextField!
    
    @IBOutlet weak var updateButton: NSButton!
    
    @IBOutlet weak var testEmailAddress: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults = UserDefaults.standard
        
        if let hostName = defaults.string(forKey: "hostName") {
            self.hostName.stringValue = hostName
        }
        
        if let userName = defaults.string(forKey: "userName") {
            self.userName.stringValue = userName
        }
        
        if let password = defaults.string(forKey: "password") {
            self.password.stringValue = password
            self.passwordShowText.stringValue = password
        }
        
        if let port = defaults.string(forKey: "port") {
            self.port.stringValue = "\(port)"
        }
        
        showHideSecureTextButton.state = .off
        passwordShowText.isHidden = true
        password.isHidden = false
    }
    
    override func viewDidDisappear() {
        passwordShowText.isHidden = true
        password.isHidden = false
        showHideSecureTextButton.state = .off
    }
    
    func controlTextDidChange(_ obj: Notification) {
        
        let defaults = UserDefaults.standard
        
        guard let hostNameString = defaults.string(forKey: "hostName"),
            let userNameString = defaults.string(forKey: "userName"),
            let passwordString = defaults.string(forKey: "password"),
            let portString = defaults.string(forKey: "port") else {
                updateButton.isEnabled = true
                return
        }
        
        if showHideSecureTextButton.state == .on {
            if hostName.stringValue != hostNameString || userName.stringValue != userNameString || passwordShowText.stringValue != passwordString || port.stringValue != portString {
                password.stringValue = passwordShowText.stringValue
                updateButton.isEnabled = true
            } else {
                updateButton.isEnabled = false
            }
        } else {
            if hostName.stringValue != hostNameString || userName.stringValue != userNameString || password.stringValue != passwordString || port.stringValue != portString {
                passwordShowText.stringValue = password.stringValue
                updateButton.isEnabled = true
            } else {
                updateButton.isEnabled = false
            }
        }
    }
    
    @IBAction func pushShowHideSecureTextButton(_ sender: NSButton) {
        if sender.state == .on {
            passwordShowText.isHidden = false
            password.isHidden = true
        } else {
            passwordShowText.isHidden = true
            password.isHidden = false
        }
    }
    
    @IBAction func pushUpdateButton(_ sender: Any) {
        
        let defaults = UserDefaults.standard
        defaults.set(self.hostName.stringValue, forKey: "hostName")
        defaults.set(self.userName.stringValue, forKey: "userName")
        
        if showHideSecureTextButton.state == .on {
            self.password.stringValue = self.passwordShowText.stringValue
            defaults.set(self.password.stringValue, forKey: "password")
        } else {
            self.passwordShowText.stringValue = self.password.stringValue
            defaults.set(self.passwordShowText.stringValue, forKey: "password")
        }
        
        if let portNumber = Int(self.port.stringValue) {
            defaults.set(portNumber, forKey: "port")
        } else {
            defaults.set(0, forKey: "port")
        }
        
        updateButton.isEnabled = false
    }
    
    @IBAction func pushSendingTestEmailButton(_ sender: Any) {
        let testSMTPSession = MCOSMTPSession()
        testSMTPSession.hostname = self.hostName.stringValue
        testSMTPSession.username = self.userName.stringValue
        testSMTPSession.password = self.password.stringValue
        
        guard let portNumber = UInt32(self.port.stringValue) else {
            print("Invalid Port Number")
            return
        }
        
        testSMTPSession.port = portNumber
        testSMTPSession.authType = .saslPlain
        testSMTPSession.connectionType = .TLS
        
        let testBuilder = MCOMessageBuilder()
        var testEmailAddresses = [MCOAddress]()
        testEmailAddresses.append(MCOAddress(displayName: nil, mailbox: self.testEmailAddress.stringValue))
        testBuilder.header.to = testEmailAddresses
        testBuilder.header.from = MCOAddress(displayName: nil, mailbox: self.userName.stringValue)
        testBuilder.header.subject = "Test Email From WebCatcher"
        testBuilder.htmlBody = "This is Test Email From WebCatcher"
        
        let rfc822Data = testBuilder.data()
        let sendOperation = testSMTPSession.sendOperation(with: rfc822Data)
        sendOperation?.start { (error) -> Void in
            if (error != nil) {
                NSLog("Error sending email: \(error!.localizedDescription)")
                
                let alert = NSAlert()
                alert.messageText = "Error - Sending test email:"
                alert.informativeText = "\(error!.localizedDescription)."
                alert.alertStyle = .warning
                alert.addButton(withTitle: "OK")
                alert.runModal()
                
            } else {
                NSLog("Successfully sent email!")
                
                let alert = NSAlert()
                alert.messageText = "Successfully sent test email!"
                alert.alertStyle = .warning
                alert.addButton(withTitle: "OK")
                alert.runModal()
            }
        }
    }
    
}
