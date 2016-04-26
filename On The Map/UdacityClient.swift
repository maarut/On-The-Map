//
//  UdacityClient.swift
//  On The Map
//
//  Created by Maarut Chandegra on 25/04/2016.
//  Copyright © 2016 Maarut Chandegra. All rights reserved.
//

import UIKit

class UdacityClient {
    
    private (set) var session = NSURLSession.sharedSession()
    private (set) var user: UdacityUser?
    
    private init() { }
    
    static func sharedInstance() -> UdacityClient
    {
        struct DispatchOnce { static var token = 0; static var value: UdacityClient? }
        dispatch_once(&DispatchOnce.token) { DispatchOnce.value = UdacityClient() }
        return DispatchOnce.value!
    }
    
    func login(username: String, password: String, completionHandler: (Bool, NSError?) -> Void)
    {
        let task = taskForPOSTMethod(Methods.Session, parameters: [:], httpBody: ["udacity": ["username": username, "password": password]]) { (data, error) in
            func logError(errorString: String) {
                let error = NSError(domain: "UdacityClient.login", code: 1, userInfo: [NSLocalizedDescriptionKey: errorString])
                completionHandler(false, error)
            }
            guard error == nil else {
                completionHandler(false, error!)
                return
            }
            guard let data = data as? [String: AnyObject] else {
                logError("Unable to parse returned JSON object")
                return
            }
            guard let account = data[UserLoginResponseKeys.Account] as? [String: AnyObject] else {
                logError("key \"\(UserLoginResponseKeys.Account)\" not found in JSON response")
                return
            }
            guard let accountId = Int(account[UserLoginResponseKeys.AccountId] as? String ?? "") else {
                logError("key \"\(UserLoginResponseKeys.AccountId)\" not found in JSON response")
                return
            }
            self.user = UdacityUser(userId: accountId)
            completionHandler(true, nil)
        }
        task.resume()
    }
    
    func logout(completionHandler: (Bool, NSError?) -> Void)
    {
        let task = taskForDELETEMethod(Methods.Session) { (data, error) in
            func logError(errorString: String) {
                let error = NSError(domain: "UdacityClient.login", code: 1, userInfo: [NSLocalizedDescriptionKey: errorString])
                completionHandler(false, error)
            }
            guard error == nil else {
                completionHandler(false, error!)
                return
            }
            completionHandler(true, nil)
        }
        task.resume()
    }
    
    func userData()
    {
        
    }
}
