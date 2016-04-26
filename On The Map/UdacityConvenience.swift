//
//  UdacityConvenience.swift
//  On The Map
//
//  Created by Maarut Chandegra on 25/04/2016.
//  Copyright © 2016 Maarut Chandegra. All rights reserved.
//

import Foundation

extension UdacityClient {
    
    func taskForDELETEMethod(method: String, completionHandler: (data: AnyObject?, error: NSError?) -> Void) -> NSURLSessionDataTask
    {
        let url = udacityURL(withPathExtension: method)
        let request = urlRequestForDELETE(url)
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            func sendError(error: String)
            {
                let userInfo = [NSLocalizedDescriptionKey: error]
                completionHandler(data: nil, error: NSError(domain: "taskForDELETEMethod", code: 1, userInfo: userInfo))
            }
            
            guard error == nil else {
                completionHandler(data: nil, error: error!)
                return
            }
            
            guard let data = data?.subdataWithRange(NSRange(location: 5, length: (data?.length ?? 5) - 5)) else {
                sendError("No data was returned by the request!")
                return
            }
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode < 300 else {
                sendError("Status code in the 2xx range not received.")
                return
            }
            
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            }
            catch {
                parsedResult = nil
                completionHandler(data: nil, error: (error as NSError))
                return
            }
            
            completionHandler(data: parsedResult, error: nil)
            
        }
        return task
    }
    
    func taskForPOSTMethod(method: String, parameters: [String: AnyObject], httpBody: [String: AnyObject], completionHandler: (data: AnyObject?, error: NSError?) -> Void) -> NSURLSessionDataTask
    {
        let url = udacityURL(withPathExtension: method)
        let request = urlRequestForPOSTWithBody(httpBody, forURL: url)
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            func sendError(error: String)
            {
                let userInfo = [NSLocalizedDescriptionKey: error]
                completionHandler(data: nil, error: NSError(domain: "taskForPOSTMethod", code: 1, userInfo: userInfo))
            }
            
            guard error == nil else {
                completionHandler(data: nil, error: error!)
                return
            }
            
            /* GUARD: Was there any data returned? And was there more than 5 bytes of data? */
            guard let data = data?.subdataWithRange(NSRange(location: 5, length: (data?.length ?? 5) - 5)) else {
                sendError("No data was returned by the request!")
                return
            }
            
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            }
            catch {
                parsedResult = nil
                completionHandler(data: nil, error: (error as NSError))
                return
            }
            
            if let statusCode = (response as? NSHTTPURLResponse)?.statusCode {
                switch statusCode {
                case 200 ..< 300:
                    // Everything is OK. Carry on.
                    break
                case 403:
                    let userInfo = [ResponseKeys.ForbiddenResponseKey: parsedResult]
                    completionHandler(data: nil, error: NSError(domain: "taskForPOSTMethod", code: ResponseKeys.ForbiddenResponseErrorCode, userInfo: userInfo))
                    return
                default:
                    sendError("The request returned an unexpected status code.")
                    return
                }
            }
            
            completionHandler(data: parsedResult, error: nil)
        }
        return task
    }
    
    private func udacityURL(withPathExtension withPathExtension: String = "") -> NSURL {
        let components = NSURLComponents()
        components.scheme = Constants.ApiScheme
        components.host = Constants.ApiHost
        components.path = Constants.ApiPath + "\(withPathExtension)"
        
        return components.URL!
    }
    
    private func urlRequestForDELETE(url: NSURL) -> NSURLRequest
    {
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        
        let xsrfCookie = sharedCookieStorage.cookies!.filter { $0.name == "XSRF-TOKEN" }.first
        let httpHeaderFields: [String: String]
        if let xsrfCookie = xsrfCookie {
            httpHeaderFields = ["X-XSRF-TOKEN": xsrfCookie.value]
        }
        else {
            httpHeaderFields = [:]
        }
        
        return baseURLRequest(url, method: "DELETE", httpHeaderFields: httpHeaderFields)
    }
    
    private func urlRequestForPOSTWithBody(body: [String: AnyObject], forURL url: NSURL) -> NSURLRequest
    {
        let request = baseURLRequest(url, method: "POST", httpHeaderFields: ["Accept": "application/json", "Content-Type": "application/json"])
        
        let json: NSData?
        do {
            json = try NSJSONSerialization.dataWithJSONObject(body, options: NSJSONWritingOptions(rawValue: 0))
        }
        catch {
            json = nil
            NSLog("Could not construct JSON out of data: \(error as NSError)")
        }
        request.HTTPBody = json
        
        return request
    }
    
    private func baseURLRequest(url: NSURL, method: String, httpHeaderFields: [String: String]) -> NSMutableURLRequest
    {
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = method
        httpHeaderFields.forEach { request.addValue($1, forHTTPHeaderField: $0) }
        
        return request
    }
}