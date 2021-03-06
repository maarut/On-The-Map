//
//  ParseClient.swift
//  On The Map
//
//  Created by Maarut Chandegra on 04/05/2016.
//  Copyright © 2016 Maarut Chandegra. All rights reserved.
//

import Foundation

private func orderedDescending(string: String) -> String
{
    return "-\(string)"
}

class ParseClient
{
    private (set) var session = NSURLSession.sharedSession()
    
    private init() { }
    
    // MARK: - Singleton getter
    static func sharedInstance() -> ParseClient
    {
        struct DispatchOnce { static var token = 0; static var value: ParseClient? }
        dispatch_once(&DispatchOnce.token) { DispatchOnce.value = ParseClient() }
        return DispatchOnce.value!
    }
    
    // MARK: - Public Functions
    func getStudentData(completionHandler: ([StudentData]?, NSError?) -> Void)
    {
        let options: [String: AnyObject] = [StudentDataParameters.Limit: StudentDataStore.studentDataLimit,
                                            StudentDataParameters.Order: orderedDescending(StudentDataFields.UpdatedAt)]
        getStudentDataWithOptions(options, completionHandler: completionHandler)
    }
    
    func postStudentData(studentData: StudentData, overwritingPreviousValue: Bool, completionHandler: (Bool, NSError?) -> Void) -> NSURLSessionDataTask?
    {
        if !overwritingPreviousValue {
            return createStudentDataRemotely(studentData, completionHandler: completionHandler)
        }
        if let oldValue = locallyCachedValueFor(studentData), objectId = oldValue.objectId {
            return updateStudentDataWithObjectId(objectId, withNewValue: studentData, completionHandler: completionHandler)
        }
        else {
            return searchRemotelyForStudentData(studentData) { (oldValue, error) in
                guard error == nil else {
                    completionHandler(false, error!)
                    return
                }
                if let oldValue = oldValue, objectId = oldValue.objectId {
                    self.updateStudentDataWithObjectId(objectId, withNewValue: studentData, completionHandler: completionHandler)
                }
                else {
                    self.createStudentDataRemotely(studentData, completionHandler: completionHandler)
                }
            }
        }
    }
    
    func getCurrentlyLoggedInUsersPreviousPost(completionHandler: (StudentData?, NSError?) -> Void)
    {
        guard let user = UdacityClient.sharedInstance().user else {
            let userInfo = [NSLocalizedDescriptionKey: "User not logged in. Cannot complete request"]
            completionHandler(nil, NSError(domain: "ParseClient.currentlyLoggedInUserHasPreviouslyPosted", code: 1, userInfo: userInfo))
            return
        }
        let studentData = StudentData(objectId: nil, uniqueKey: "\(user.userId)", firstName: user.firstName, lastName: user.lastName, mapString: "", mediaURL: "", latitude: 0.0, longitude: 0.0)
        
        if let oldValue = locallyCachedValueFor(studentData) {
            completionHandler(oldValue, nil)
        }
        else {
            searchRemotelyForStudentData(studentData) { (oldValue, error) in
                guard error == nil else {
                    completionHandler(nil, error!)
                    return
                }
                completionHandler(oldValue, nil)
            }
        }
        
    }
    
    // MARK: - Private Functions
    private func createStudentDataRemotely(studentData: StudentData, completionHandler: (Bool, NSError?) -> Void) -> NSURLSessionDataTask
    {
        let task = taskForPOSTMethod(Methods.StudentLocation, studentData: studentData) {
            if $0.error != nil { completionHandler(false, $0.error!) }
            else { completionHandler(true, nil) }
        }
        task.resume()
        return task
    }
    
    private func updateStudentDataWithObjectId(objectId: String, withNewValue newValue: StudentData, completionHandler: (Bool, NSError?) -> Void) -> NSURLSessionDataTask
    {
        let method = "\(Methods.StudentLocation)/\(objectId)"
        let task = taskForPUTMethod(method, studentData: newValue) {
            if $0.error != nil { completionHandler(false, $0.error!) }
            else { completionHandler(true, nil) }
        }
        task.resume()
        return task
    }
    
    private func searchRemotelyForStudentData(
        studentData: StudentData, completionHandler: (StudentData?, NSError?) -> Void) -> NSURLSessionDataTask
    {
        let condition: [String: AnyObject] = [StudentDataFields.UniqueKey: studentData.uniqueKey]
        let json: NSData!
        do {
            json = try NSJSONSerialization.dataWithJSONObject(condition, options: NSJSONWritingOptions(rawValue: 0))
        }
        catch {
            let e = error as NSError
            NSLog("Unable to JSONify dictionary \(condition)\n\(e.description)\n\(e.localizedDescription)")
            json = nil
        }
        let conditionString = NSString(data: json, encoding: NSUTF8StringEncoding)!
        return getStudentDataWithOptions([StudentDataParameters.Where: conditionString]) { (searchResults, error) in
            guard error == nil else {
                completionHandler(nil, error!)
                return
            }
            guard let searchResults = searchResults else {
                let userInfo = [NSLocalizedDescriptionKey: "No student data returned"]
                completionHandler(nil, NSError(domain: "ParseClient.updateStudentDataWithNewValue", code: 1, userInfo: userInfo))
                return
            }
            if let oldValue = searchResults.first( { $0.firstName == studentData.firstName && $0.lastName == studentData.lastName } ) {
                completionHandler(oldValue, nil)
            }
            else {
                completionHandler(nil, nil)
            }
        }
    }
    
    private func locallyCachedValueFor(studentData: StudentData) -> StudentData?
    {
        if let previousValue = StudentDataStore.studentData.first( { studentData.uniqueKey == $0.uniqueKey } ) {
            return previousValue
        }
        return nil
    }
    
    private func getStudentDataWithOptions(options: [String: AnyObject], completionHandler: ([StudentData]?, NSError?) -> Void) -> NSURLSessionDataTask
    {
        let task = taskForGETMethod(Methods.StudentLocation, parameters: options) { (data, error) in
            func sendError(errorStr: String)
            {
                let userInfo = [NSLocalizedDescriptionKey: errorStr]
                completionHandler(nil, NSError(domain: "getStudentDataWithOptions", code: 1, userInfo: userInfo))
            }
            
            guard error == nil else {
                completionHandler(nil, error)
                return
            }
            
            guard let data = data as? [String: AnyObject] else {
                sendError("Unable to parse returned JSON object")
                return
            }
            
            guard let results = data[ParseClient.StudentDataResponseKeys.Results] as? [[String: AnyObject]] else {
                sendError("Unable to find key \"\(ParseClient.StudentDataResponseKeys.Results)\"")
                return
            }
            
            let studentLocations: [StudentData]!
            do {
                studentLocations = try StudentData.parseJSONData(results)
            }
            catch {
                studentLocations = nil
                completionHandler(nil, (error as NSError))
                return
            }
            completionHandler(studentLocations, nil)
            
        }
        task.resume()
        return task
    }
}
