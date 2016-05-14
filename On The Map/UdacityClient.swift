//
//  UdacityClient.swift
//  On The Map
//
//  Created by Maarut Chandegra on 25/04/2016.
//  Copyright © 2016 Maarut Chandegra. All rights reserved.
//

import UIKit

class UdacityClient
{
    
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
            func sendError(errorString: String) {
                let error = NSError(domain: "UdacityClient.login", code: 1, userInfo: [NSLocalizedDescriptionKey: errorString])
                completionHandler(false, error)
            }
            guard error == nil else {
                completionHandler(false, error!)
                return
            }
            guard let data = data as? [String: AnyObject] else {
                sendError("Unable to parse returned JSON object")
                return
            }
            guard let account = data[UserLoginResponseKeys.Account] as? [String: AnyObject] else {
                sendError("key \"\(UserLoginResponseKeys.Account)\" not found in JSON response")
                return
            }
            guard let accountId = Int(account[UserLoginResponseKeys.AccountId] as? String ?? "") else {
                sendError("key \"\(UserLoginResponseKeys.AccountId)\" not found in JSON response")
                return
            }
            self.getUserDataForUserId(accountId) { (user, error) in
                guard error == nil else {
                    completionHandler(false, error!)
                    return
                }
                self.user = user
                completionHandler(true, nil)
            }
            
        }
        task.resume()
    }
    
    func logout(completionHandler: (Bool, NSError?) -> Void)
    {
        let task = taskForDELETEMethod(Methods.Session) { (data, error) in
            func logError(errorString: String) {
                let error = NSError(domain: "UdacityClient.logout", code: 1, userInfo: [NSLocalizedDescriptionKey: errorString])
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
    
    func getUserDataForUserId(userId: Int, completionHandler: (UdacityUser?, NSError?) -> Void)
    {
        let task = taskForGETMethod("\(Methods.Users)/\(userId)", parameters: [:], completionHandler: { (data, error) in
            func sendError(errorString: String) {
                let error = NSError(domain: "UdacityClient.getUserData", code: 1, userInfo: [NSLocalizedDescriptionKey: errorString])
                completionHandler(nil, error)
            }
            guard error == nil else {
                completionHandler(nil, error!)
                return
            }
            guard let data = data as? [String: AnyObject] else {
                sendError("Unable to parse returned JSON object")
                return
            }
            guard let user = data[UserDataResponseKeys.User] as? [String: AnyObject] else {
                sendError("key \"\(UserDataResponseKeys.User)\" not found in JSON response")
                return
            }
            guard let firstName = user[UserDataResponseKeys.FirstName] as? String else {
                sendError("key \"\(UserDataResponseKeys.FirstName)\" not found in JSON response")
                return
            }
            guard let lastName = user[UserDataResponseKeys.LastName] as? String else {
                sendError("key \"\(UserDataResponseKeys.LastName)\" not found in JSON response")
                return
            }
            let udacityUser = UdacityUser(userId: userId, firstName: firstName, lastName: lastName)
            completionHandler(udacityUser, nil)
            
        })
        task.resume()
    }
}
