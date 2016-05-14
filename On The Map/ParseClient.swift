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
    
    func postStudentData(studentData: StudentData, errorHandler: (NSError) -> Void)
    {
        if let oldValue = locallyCachedValueFor(studentData), objectId = oldValue.objectId {
            updateStudentDataWithObjectId(objectId, withNewValue: studentData, errorHandler: errorHandler)
        }
        else {
            searchForRemoteValueForStudentData(studentData) { (oldValue, error) in
                guard error == nil else {
                    errorHandler(error!)
                    return
                }
                if let oldValue = oldValue, objectId = oldValue.objectId {
                    self.updateStudentDataWithObjectId(objectId, withNewValue: studentData, errorHandler: errorHandler)
                }
                else {
                    let task = self.taskForPOSTMethod(Methods.StudentLocation, studentData: studentData) { (data, error) in
                        if error != nil { errorHandler(error!) }
                    }
                    task.resume()
                }
            }
            
        }
    }
    
    private func updateStudentDataWithObjectId(objectId: String, withNewValue newValue: StudentData, errorHandler: (NSError) -> Void)
    {
        let method = "\(Methods.StudentLocation)/\(objectId)"
        let task = taskForPUTMethod(method, studentData: newValue) { (_, error) in
            if error != nil { errorHandler(error!) }
        }
        task.resume()
    }
    
    private func searchForRemoteValueForStudentData(studentData: StudentData, completionHandler: (StudentData?, NSError?) -> Void)
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
        getStudentDataWithOptions([StudentDataParameters.Where: conditionString]) { (searchResults, error) in
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
    
    private func getStudentDataWithOptions(options: [String: AnyObject], completionHandler: ([StudentData]?, NSError?) -> Void)
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
    }
}
