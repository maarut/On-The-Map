//
//  ParseClient.swift
//  On The Map
//
//  Created by Maarut Chandegra on 04/05/2016.
//  Copyright © 2016 Maarut Chandegra. All rights reserved.
//

import Foundation

class ParseClient
{
    private (set) var session = NSURLSession.sharedSession()
    
    private init() { }
    
    static func sharedInstance() -> ParseClient
    {
        struct DispatchOnce { static var token = 0; static var value: ParseClient? }
        dispatch_once(&DispatchOnce.token) { DispatchOnce.value = ParseClient() }
        return DispatchOnce.value!
    }
    
    func getStudentData(completionHandler: ([StudentData]?, NSError?) -> Void)
    {
        let options: [String: AnyObject] = [StudentDataParameters.Limit: 100, StudentDataParameters.Order: "-\(StudentDataFields.UpdatedAt)"]
        getStudentDataWithOptions(options, completionHandler: completionHandler)
    }
    
    func postStudentData(studentData: StudentData, overwritingPreviousValue: Bool, errorHandler: (NSError) -> Void)
    {
        if !overwritingPreviousValue {
            createStudentDataRemotely(studentData, errorHandler: errorHandler)
            return
        }
        if let oldValue = locallyCachedValueFor(studentData), objectId = oldValue.objectId {
            updateStudentDataWithObjectId(objectId, withNewValue: studentData, errorHandler: errorHandler)
        }
        else {
            searchRemotelyForStudentData(studentData) { (oldValue, error) in
                guard error == nil else {
                    errorHandler(error!)
                    return
                }
                if let oldValue = oldValue, objectId = oldValue.objectId {
                    self.updateStudentDataWithObjectId(objectId, withNewValue: studentData, errorHandler: errorHandler)
                }
                else {
                    self.createStudentDataRemotely(studentData, errorHandler: errorHandler)
                }
            }
        }
    }
    
    // Generally to be used by UI code. Ensures a shorter timeout than NSURLSession.sharedSession()
    func hasBeenPostedPreviously(studentData: StudentData, completionHandler: (Bool?, NSError?) -> Void)
    {
        if let _ = locallyCachedValueFor(studentData) {
            completionHandler(true, nil)
        }
        else {
            // Hack to avoid using a specific URL session with a very short timeout to deal with this request.
            let lock = NSLock()
            var hasCompleted = false
            let task = searchRemotelyForStudentData(studentData) { (oldValue, error) in
                do {
                    lock.lock()
                    defer { lock.unlock() }
                    if hasCompleted { return }
                    hasCompleted = true
                }
                guard error == nil else {
                    completionHandler(nil, error!)
                    return
                }
                completionHandler(oldValue != nil, nil)
            }
            after(3.seconds()) {
                do {
                    lock.lock()
                    defer { lock.unlock() }
                    if hasCompleted { return }
                    hasCompleted = true
                }
                task.cancel()
                completionHandler(false, nil)
            }
        }
        
    }
    
    private func createStudentDataRemotely(studentData: StudentData, errorHandler: (NSError) -> Void)
    {
        taskForPOSTMethod(Methods.StudentLocation, studentData: studentData) {
            if $0.error != nil { errorHandler($0.error!) }
        }.resume()
    }
    
    private func updateStudentDataWithObjectId(objectId: String, withNewValue newValue: StudentData, errorHandler: (NSError) -> Void)
    {
        let method = "\(Methods.StudentLocation)/\(objectId)"
        let task = taskForPUTMethod(method, studentData: newValue) { if $0.error != nil { errorHandler($0.error!) } }
        task.resume()
    }
    
    private func searchRemotelyForStudentData(studentData: StudentData, completionHandler: (StudentData?, NSError?) -> Void) -> NSURLSessionDataTask
    {
        let condition: [String: AnyObject] = [StudentDataFields.UniqueKey: studentData.uniqueKey]
        let json: NSData!
        do {
            json = try NSJSONSerialization.dataWithJSONObject(condition, options: NSJSONWritingOptions(rawValue: 0))
        }
        catch {
            NSLog("Unable to JSONify dictionary \(condition)")
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
