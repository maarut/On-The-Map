//
//  StudentData.swift
//  On The Map
//
//  Created by Maarut Chandegra on 04/05/2016.
//  Copyright © 2016 Maarut Chandegra. All rights reserved.
//

import Foundation

struct StudentData
{
    var objectId: String?
    var uniqueKey: String
    var firstName: String
    var lastName: String
    var mapString: String
    var mediaURL: String
    var latitude: Float
    var longitude: Float
    
    static func parseJSONData(data: [[String: AnyObject]]) throws -> [StudentData]
    {
        return try data.flatMap {
            func throwError(errorMsg: String) throws
            {
                let userInfo = [NSLocalizedDescriptionKey: errorMsg]
                throw NSError(domain: "StudentData.parseJSONData", code: 1, userInfo: userInfo)
            }
            guard let objectId = $0[ParseClient.StudentDataFields.ObjectId] as? String else {
                try throwError("Could not find key \"\(ParseClient.StudentDataFields.ObjectId)\"")
                return nil
            }
            guard let uniqueKey = $0[ParseClient.StudentDataFields.UniqueKey] as? String else {
                try throwError("Could not find key \"\(ParseClient.StudentDataFields.UniqueKey)\"")
                return nil
            }
            guard let firstName = $0[ParseClient.StudentDataFields.FirstName] as? String else {
                try throwError("Could not find key \"\(ParseClient.StudentDataFields.FirstName)\"")
                return nil
            }
            guard let lastName = $0[ParseClient.StudentDataFields.LastName] as? String else {
                try throwError("Could not find key \"\(ParseClient.StudentDataFields.LastName)\"")
                return nil
            }
            guard let mapString = $0[ParseClient.StudentDataFields.MapString] as? String else {
                try throwError("Could not find key \"\(ParseClient.StudentDataFields.MapString)\"")
                return nil
            }
            guard let mediaURL = $0[ParseClient.StudentDataFields.MediaURL] as? String else {
                try throwError("Could not find key \"\(ParseClient.StudentDataFields.MediaURL)\"")
                return nil
            }
            guard let latitude = $0[ParseClient.StudentDataFields.Latitude] as? Float else {
                try throwError("Could not find key \"\(ParseClient.StudentDataFields.Latitude)\"")
                return nil
            }
            guard let longitude = $0[ParseClient.StudentDataFields.Longitude] as? Float else {
                try throwError("Could not find key \"\(ParseClient.StudentDataFields.Longitude)\"")
                return nil
            }
            
            return StudentData(objectId: objectId, uniqueKey: uniqueKey, firstName: firstName, lastName: lastName, mapString: mapString, mediaURL: mediaURL, latitude: latitude, longitude: longitude)
            
        }
    }
    
    func toJSON() -> NSData
    {
        let dict = toDictionary()
        let data: NSData
        do {
            try data = NSJSONSerialization.dataWithJSONObject(dict, options: NSJSONWritingOptions(rawValue: 0))
        }
        catch {
            NSLog((error as NSError).localizedDescription)
            data = NSData()
        }
        return data
    }
    
    private func toDictionary() -> [String: AnyObject]
    {
        return [
            ParseClient.StudentDataFields.UniqueKey: uniqueKey,
            ParseClient.StudentDataFields.FirstName: firstName,
            ParseClient.StudentDataFields.LastName: lastName,
            ParseClient.StudentDataFields.MapString: mapString,
            ParseClient.StudentDataFields.MediaURL: mediaURL,
            ParseClient.StudentDataFields.Latitude: latitude,
            ParseClient.StudentDataFields.Longitude: longitude,
        ]
    }
}