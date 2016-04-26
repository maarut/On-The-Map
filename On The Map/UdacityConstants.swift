//
//  UdacityConstants.swift
//  On The Map
//
//  Created by Maarut Chandegra on 25/04/2016.
//  Copyright © 2016 Maarut Chandegra. All rights reserved.
//

import UIKit

extension UdacityClient {
    struct Constants {
        // MARK: URLs
        static let ApiScheme = "https"
        static let ApiHost = "www.udacity.com"
        static let ApiPath = "/api/"

    }
    
    struct Methods {
        static let Session = "session"
        static let Users = "users"
    }
    
    struct ResponseKeys {
        static let ForbiddenResponseKey = "UdacityClient.403ForbiddenResponseKey"
        static let ForbiddenResponseErrorCode = 403
    }
    struct UserLoginResponseKeys {
        static let Account = "account"
        static let AccountId = "key"
    }
}
