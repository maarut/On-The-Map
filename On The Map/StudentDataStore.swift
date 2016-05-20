//
//  StudentLocationStore.swift
//  On The Map
//
//  Created by Maarut Chandegra on 10/05/2016.
//  Copyright © 2016 Maarut Chandegra. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

enum PreviousPost {
    case Undetermined
    case NeverPosted
    case HasPosted(previousPost: StudentData)
}

class StudentDataStore
{
    static var locationDistanceLimit: CLLocationDistance = 1000000.0
    static var studentDataLimit = 100
    static private (set) var studentData: [StudentData] = []
    static var currentlyLoggedInUsersPreviousPost = PreviousPost.Undetermined
    
    private init() { }
    
    static func refreshStudentDataWithCompletionHandler(completionHandler: (didSucceed: Bool, error: NSError?) -> Void)
    {
        ParseClient.sharedInstance().getStudentData { (locations, error) in
            guard error == nil else {
                completionHandler(didSucceed: false, error: error)
                return
            }
            studentData = locations!
            completionHandler(didSucceed: true, error: nil)
        }
    }
    
    static func studentDataSurroundingLocation(location: CLLocation) -> [StudentData]
    {
        var distanceSpan = locationDistanceLimit
        let sortedStudentData = studentData.sort {
            let one = CLLocation(latitude: CLLocationDegrees($0.latitude), longitude: CLLocationDegrees($0.longitude))
            let two = CLLocation(latitude: CLLocationDegrees($1.latitude), longitude: CLLocationDegrees($1.longitude))
            return one.distanceFromLocation(location) < two.distanceFromLocation(location)
        }
        
        
        return sortedStudentData.filter {
            let l = CLLocation(latitude: CLLocationDegrees($0.latitude),
                longitude: CLLocationDegrees($0.longitude))
            let distanceFromLocation = l.distanceFromLocation(location)
            if distanceFromLocation < distanceSpan {
                distanceSpan = distanceFromLocation + locationDistanceLimit
                return true
            }
            return false
        }
    }
    
    
}