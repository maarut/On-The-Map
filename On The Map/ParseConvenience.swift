//
//  ParseConvenience.swift
//  On The Map
//
//  Created by Maarut Chandegra on 04/05/2016.
//  Copyright © 2016 Maarut Chandegra. All rights reserved.
//

import Foundation

extension ParseClient {
    func taskForGETMethod(method: String, parameters: [String: AnyObject], completionHandler: (data: AnyObject?, error: NSError?) -> Void) -> NSURLSessionDataTask
    {
        let url = buildURLWithParameters(parameters, withPathExtension: method)
        let request = buildRequestWithURL(url)
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            func sendError(error: String)
            {
                let userInfo = [NSLocalizedDescriptionKey: error]
                completionHandler(data: nil, error: NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            guard error == nil else {
                completionHandler(data: nil, error: error!)
                return
            }
            
            guard let data = data else {
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
    
    private func buildURLWithParameters(parameters: [String: AnyObject], withPathExtension pathExtension: String = "") -> NSURL
    {
        let components = NSURLComponents()
        components.scheme = Constants.ApiScheme
        components.host = Constants.ApiHost
        components.path = Constants.ApiPath + "\(pathExtension)"
        components.queryItems = [NSURLQueryItem]()
        
        parameters.forEach { components.queryItems!.append(NSURLQueryItem(name: $0, value: "\($1)")) }
        
        return components.URL!
    }
    
    private func buildRequestWithURL(url: NSURL) -> NSURLRequest
    {
        let request = NSMutableURLRequest(URL: url)
        request.addValue(Headers.ApplicationID.value, forHTTPHeaderField: Headers.ApplicationID.httpHeader)
        request.addValue(Headers.APIKey.value, forHTTPHeaderField: Headers.APIKey.httpHeader)
        return request
    }
}