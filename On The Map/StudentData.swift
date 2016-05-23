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
    
    init(objectId: String?, uniqueKey: String, firstName: String, lastName: String, mapString: String,
         mediaURL: String, latitude: Float, longitude: Float)
    {
        self.objectId = objectId
        self.uniqueKey = uniqueKey
        self.firstName = firstName
        self.lastName = lastName
        self.mapString = mapString
        self.mediaURL = mediaURL
        self.latitude = latitude
        self.longitude = longitude
    }
    
    init?(data: [String: AnyObject]) throws
    {
        func throwError(errorMsg: String) throws
        {
            let userInfo = [NSLocalizedDescriptionKey: errorMsg]
            throw NSError(domain: "StudentData.parseJSONData", code: 1, userInfo: userInfo)
        }
        guard let objectId = data[ParseClient.StudentDataFields.ObjectId] as? String else {
            try throwError("Could not find key \"\(ParseClient.StudentDataFields.ObjectId)\"")
            return nil
        }
        guard let uniqueKey = data[ParseClient.StudentDataFields.UniqueKey] as? String else {
            try throwError("Could not find key \"\(ParseClient.StudentDataFields.UniqueKey)\"")
            return nil
        }
        guard let firstName = data[ParseClient.StudentDataFields.FirstName] as? String else {
            try throwError("Could not find key \"\(ParseClient.StudentDataFields.FirstName)\"")
            return nil
        }
        guard let lastName = data[ParseClient.StudentDataFields.LastName] as? String else {
            try throwError("Could not find key \"\(ParseClient.StudentDataFields.LastName)\"")
            return nil
        }
        guard let mapString = data[ParseClient.StudentDataFields.MapString] as? String else {
            try throwError("Could not find key \"\(ParseClient.StudentDataFields.MapString)\"")
            return nil
        }
        guard let mediaURL = data[ParseClient.StudentDataFields.MediaURL] as? String else {
            try throwError("Could not find key \"\(ParseClient.StudentDataFields.MediaURL)\"")
            return nil
        }
        guard let latitude = data[ParseClient.StudentDataFields.Latitude] as? Float else {
            try throwError("Could not find key \"\(ParseClient.StudentDataFields.Latitude)\"")
            return nil
        }
        guard let longitude = data[ParseClient.StudentDataFields.Longitude] as? Float else {
            try throwError("Could not find key \"\(ParseClient.StudentDataFields.Longitude)\"")
            return nil
        }
        self.objectId = objectId
        self.uniqueKey = uniqueKey
        self.firstName = firstName
        self.lastName = lastName
        self.mapString = mapString
        self.mediaURL = mediaURL
        self.latitude = latitude
        self.longitude = longitude
        
    }
    
    static func parseJSONData(data: [[String: AnyObject]]) throws -> [StudentData]
    {
        return try data.flatMap { try StudentData(data: $0) }
    }
    
    func toJSON() -> NSData
    {
        let dict = toDictionary()
        let data: NSData
        do {
            try data = NSJSONSerialization.dataWithJSONObject(dict, options: NSJSONWritingOptions(rawValue: 0))
        }
        catch {
            let e = error as NSError
            NSLog(e.description + "\n" + e.localizedDescription)
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