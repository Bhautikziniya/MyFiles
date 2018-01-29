//
//  FBHelper.swift
//  Vachnamrut
//
//  Created by Bhautik Ziniya on 9/14/17.
//  Copyright © 2017 Agile Infoways. All rights reserved.
//

import UIKit
//import FBSDKLoginKit

class FBHelper: NSObject {
    /*
    // Check login status
    static var isUserLoggedIn : Bool {
        return FBSDKAccessToken.current() != nil
    }
    
    // Login
    static func login(_ viewConroller : UIViewController, withComplition completionHandler:((Bool, Error?) -> Void)?) {
        if FBSDKAccessToken.current() != nil {
            // User Already Logged in
            loggingPrint("Already logged in")
            if let validHandler = completionHandler {
                validHandler(true, nil)
            }
        } else {
            // Do login
            let loginPermissions = ["email", "public_profile"]
            let loginManager : FBSDKLoginManager = FBSDKLoginManager()
            //loginManager.loginBehavior = .web     // Change login behavior.
            loginManager.logIn(withReadPermissions: loginPermissions, from: viewConroller, handler: { (loginResult, error) in
                if error != nil {
                    if let validHandler = completionHandler {
                        validHandler(false, error)
                    }
                } else if loginResult!.isCancelled {
                    loggingPrint("Login Cancelled.")
                    let error = NSError(domain: "Facebook login cancelled.", code: 5001, userInfo: nil) as Error
                    if let validHandler = completionHandler {
                        validHandler(false, error)
                    }
                } else {
                    loggingPrint("User logged in with token : \(FBSDKAccessToken.current().tokenString)")
                    if let validHandler = completionHandler {
                        validHandler(true, nil)
                    }
                }
            })
        }
    }
    
    // Get User info
    static func userInfo(_ completionHandler: ((Any?, Error?) -> Void)?) {
        guard FBSDKAccessToken.current() != nil else {
            let err = NSError(domain: "Not logged in yet.", code: 5001, userInfo: nil) as Error
            if let validHandler = completionHandler {
                validHandler(nil, err)
            }
            return
        }
        
        FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"id,name,email,first_name,last_name,picture.width(300).height(300)"]).start { (connection, result, error) in
            loggingPrint(result)
            if let validHandler = completionHandler {
                validHandler(result, error)
            }
        }
    }
    
    // Logout
    static func logout()
    {
        if FBSDKAccessToken.current() != nil {
            let loginManager: FBSDKLoginManager = FBSDKLoginManager()
            loginManager.logOut()
        }
    }
     */
}
