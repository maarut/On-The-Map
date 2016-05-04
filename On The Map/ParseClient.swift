//
//  ParseClient.swift
//  On The Map
//
//  Created by Maarut Chandegra on 04/05/2016.
//  Copyright © 2016 Maarut Chandegra. All rights reserved.
//

import Foundation

class ParseClient {
    private (set) var session = NSURLSession.sharedSession()
    
    private init() { }
    
    static func sharedInstance() -> ParseClient
    {
        struct DispatchOnce { static var token = 0; static var value: ParseClient? }
        dispatch_once(&DispatchOnce.token) { DispatchOnce.value = ParseClient() }
        return DispatchOnce.value!
    }
    
    func getStudentLocations(completionHandler: ([StudentLocation]?, NSError?) -> Void)
    {
        let options: [String: AnyObject] = [StudentLocationParameters.Limit: 100, StudentLocationParameters.Order: "-\(StudentLocationFields.UpdatedAt)"]
        let task = taskForGETMethod(Methods.StudentLocation, parameters: options) { (data, error) in
            func sendError(errorStr: String)
            {
                let userInfo = [NSLocalizedDescriptionKey: errorStr]
                completionHandler(nil, NSError(domain: "getStudentLocations", code: 1, userInfo: userInfo))
            }
            
            guard let data = data as? [String: AnyObject] else {
                sendError("Unable to parse returned JSON object")
                return
            }
            
            guard let results = data[ParseClient.StudentLocationResponseKeys.Results] as? [[String: AnyObject]] else {
                sendError("Unable to find key \"\(ParseClient.StudentLocationResponseKeys.Results)\"")
                return
            }
            
            let studentLocations: [StudentLocation]!
            do {
                studentLocations = try StudentLocation.parseJSONData(results)
            }
            catch {
                studentLocations = nil
                completionHandler(nil, (error as NSError))
                return
            }
            completionHandler(studentLocations, nil)
            
        }
        task.resume()
    }
    
    func postStudentLocation(studentData: AnyObject, completionHandler: () -> Void)
    {
        
    }
    
    func updateStudentLocation(updatedStudentData: AnyObject, completionHandler: () -> Void)
    {
        
    }
}
