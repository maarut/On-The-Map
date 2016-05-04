//
//  ParseConstants.swift
//  On The Map
//
//  Created by Maarut Chandegra on 03/05/2016.
//  Copyright © 2016 Maarut Chandegra. All rights reserved.
//

extension ParseClient {
    struct Headers {
        static let ApplicationID = (httpHeader: "X-Parse-Application-Id", value: "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr")
        static let APIKey = (httpHeader: "X-Parse-REST-API-Key", value: "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY")
    }
    
    struct Constants {
        
        
        static let ApiScheme = "https"
        static let ApiHost = "api.parse.com"
        static let ApiPath = "/1/classes/"
    }
    
    struct Methods {
        static let StudentLocation = "StudentLocation"
    }
    
    struct StudentLocationParameters {
        static let Limit = "limit"
        static let Order = "order"
        static let Skip = "skip"
        static let Where = "where"
    }
    
    struct StudentLocationResponseKeys {
        static let Results = "results"
    }
    
    struct StudentLocationFields {
        static let ObjectId = "objectId"
        static let UniqueKey = "uniqueKey"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let MapString = "mapString"
        static let MediaURL = "mediaURL"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let UpdatedAt = "updatedAt"
    }
    
}