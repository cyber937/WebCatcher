//
//  GoogleDriveController.swift
//  WebCatcher
//
//  Created by Kiyoshi Nagahama on 10/29/18.
//  Copyright © 2018 Digital Bytes Inc. All rights reserved.
//

import Cocoa
import AppAuth
import GTMAppAuth
import GoogleAPIClientForREST

class GoogleDriveController: NSViewController {

    
    @IBOutlet weak var signedInButton: NSButton!
    @IBOutlet weak var usernameField: NSTextField!
    
    var redirectHTTPHandler:    OIDRedirectHTTPHandler?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    func signedInUsername() -> String? {
        guard let auth = PersistantData.sharedInstance.driveService.authorizer else { return nil }
        guard let canAuthorize = auth.canAuthorize,
            canAuthorize else { return nil }
        guard let userEmail = auth.userEmail else { return nil }
        return userEmail
    }
    
    func isSignedIn() -> Bool {
        guard signedInUsername() != nil else { return false }
        return true
    }
    
    func updateUI() {
        _ = self.isSignedIn()
        if let userName = self.signedInUsername() {
            signedInButton.title = "Sign Out"
            usernameField.stringValue = userName
        } else {
            signedInButton.title = "Sign In"
            usernameField.stringValue = ""
        }
    }
    
    func runSignin(completion: @escaping ()->Void ) {
        redirectHTTPHandler = OIDRedirectHTTPHandler(successURL: GoogleService().successURL)
        
        var error: NSError?
        
        guard let localRedirectURI = redirectHTTPHandler?.startHTTPListener(&error) else {
            print("Error")
            return
        }
        
        let configuration: OIDServiceConfiguration = GTMAppAuthFetcherAuthorization.configurationForGoogle()
        
        let request: OIDAuthorizationRequest = OIDAuthorizationRequest(configuration: configuration,
                                                                       clientId: GoogleService().clientID,
                                                                       clientSecret: GoogleService().clientSecret,
                                                                       scopes: [kGTLRAuthScopeDrive, OIDScopeEmail],
                                                                       redirectURL: localRedirectURI,
                                                                       responseType: OIDResponseTypeCode,
                                                                       additionalParameters: nil)
        
        redirectHTTPHandler?.currentAuthorizationFlow = OIDAuthState.authState(byPresenting: request) { (authState, error) in
            if let authState = authState  {
                let gtmAuthorization = GTMAppAuthFetcherAuthorization(authState: authState)
                PersistantData.sharedInstance.driveService.authorizer = gtmAuthorization
                GTMAppAuthFetcherAuthorization.save(gtmAuthorization, toKeychainForName: kGTMAppAuthKeychainItemName)
            }
            
            completion()
        }
    }
    
    @IBAction func pushSignInButton(_ sender: Any) {
        if !isSignedIn() {
            runSignin {
                self.updateUI()
            }
        } else {
            let service: GTLRDriveService = PersistantData.sharedInstance.driveService
            
            GTMAppAuthFetcherAuthorization.removeFromKeychain(forName: kGTMAppAuthKeychainItemName)
            service.authorizer = nil
            updateUI()
        }
    }
}
