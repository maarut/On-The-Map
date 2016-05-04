//
//  StudentLocation.swift
//  On The Map
//
//  Created by Maarut Chandegra on 04/05/2016.
//  Copyright © 2016 Maarut Chandegra. All rights reserved.
//

import Foundation

struct StudentLocation {
    var objectId: String?
    var uniqueKey: String
    var firstName: String
    var lastName: String
    var mapString: String
    var mediaURL: String
    var latitude: Float
    var longitude: Float
    
    static func parseJSONData(data: [[String: AnyObject]]) throws -> [StudentLocation]
    {
        return try data.flatMap {
            func throwError(errorMsg: String) throws
            {
                let userInfo = [NSLocalizedDescriptionKey: errorMsg]
                throw NSError(domain: "parseJSONData", code: 1, userInfo: userInfo)
            }
            guard let objectId = $0[ParseClient.StudentLocationFields.ObjectId] as? String else {
                try throwError("Could not find key \"\(ParseClient.StudentLocationFields.ObjectId)\"")
                return nil
            }
            guard let uniqueKey = $0[ParseClient.StudentLocationFields.UniqueKey] as? String else {
                try throwError("Could not find key \"\(ParseClient.StudentLocationFields.UniqueKey)\"")
                return nil
            }
            guard let firstName = $0[ParseClient.StudentLocationFields.FirstName] as? String else {
                try throwError("Could not find key \"\(ParseClient.StudentLocationFields.FirstName)\"")
                return nil
            }
            guard let lastName = $0[ParseClient.StudentLocationFields.LastName] as? String else {
                try throwError("Could not find key \"\(ParseClient.StudentLocationFields.LastName)\"")
                return nil
            }
            guard let mapString = $0[ParseClient.StudentLocationFields.MapString] as? String else {
                try throwError("Could not find key \"\(ParseClient.StudentLocationFields.MapString)\"")
                return nil
            }
            guard let mediaURL = $0[ParseClient.StudentLocationFields.MediaURL] as? String else {
                try throwError("Could not find key \"\(ParseClient.StudentLocationFields.MediaURL)\"")
                return nil
            }
            guard let latitude = $0[ParseClient.StudentLocationFields.Latitude] as? Float else {
                try throwError("Could not find key \"\(ParseClient.StudentLocationFields.Latitude)\"")
                return nil
            }
            guard let longitude = $0[ParseClient.StudentLocationFields.Longitude] as? Float else {
                try throwError("Could not find key \"\(ParseClient.StudentLocationFields.Longitude)\"")
                return nil
            }
            
            return StudentLocation(objectId: objectId, uniqueKey: uniqueKey, firstName: firstName, lastName: lastName, mapString: mapString, mediaURL: mediaURL, latitude: latitude, longitude: longitude)
            
        }
    }
}