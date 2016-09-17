//
//  UdacityClient.swift
//  Geodentify
//
//  Created by Y50-70 on 13/09/16.
//  Copyright © 2016 Chashmeet Singh. All rights reserved.
//

// MARK: - TMDBClient: NSObject

import Foundation

class UdacityClient : NSObject {

    // MARK: Properties

    // shared session
    var session = NSURLSession.sharedSession()

    // authentication state
    var sessionID: String!
    var userID: String!

    // MARK: Initializers

    override init() {
        super.init()
    }

    // MARK: GET

    func taskForGETMethod(host: String, method: String, parameters: [String:AnyObject], getSubData: Bool, completionHandlerForGET: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {

        /* 1. Set the parameters */
        var parameters = parameters

        /* 2/3. Build the URL, Configure the request */
        let request = NSMutableURLRequest(URL: udacityURLFromParameters(host, parameters: parameters, withPathExtension: method))
        request.addValue(UdacityClient.ParseParamterValues.AppID, forHTTPHeaderField: UdacityClient.ParseParamterKeys.AppID)
        request.addValue(UdacityClient.ParseParamterValues.APIKey, forHTTPHeaderField: UdacityClient.ParseParamterKeys.APIKey)

        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            func sendError(error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForGET(result: nil, error: NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }

            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(error)")
                return
            }

            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }

            /* GUARD: Was there any data returned? */
            guard var data = data else {
                sendError("No data was returned by the request!")
                return
            }

            if getSubData {
                data = data.subdataWithRange(NSMakeRange(5, data.length - 5))
            }

            /* 5/6. Parse the data and use the data (happens in completion handler) */
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForGET)
        }

        /* 7. Start the request */
        task.resume()

        return task
    }

    // MARK: POST

    func taskForPOSTMethod(host: String, method: String, parameters: [String:AnyObject], getSubData: Bool, jsonBody: String?, completionHandlerForPOST: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {

        /* 1. Set the parameters */
        var parameters = parameters

        /* 2/3. Build the URL, Configure the request */
        let request = NSMutableURLRequest(URL: udacityURLFromParameters(host, parameters: parameters, withPathExtension: method))
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(UdacityClient.ParseParamterValues.AppID, forHTTPHeaderField: UdacityClient.ParseParamterKeys.AppID)
        request.addValue(UdacityClient.ParseParamterValues.APIKey, forHTTPHeaderField: UdacityClient.ParseParamterKeys.APIKey)
        request.HTTPBody = jsonBody!.dataUsingEncoding(NSUTF8StringEncoding)

        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            func sendError(error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForPOST(result: nil, error: NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }

            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(error?.localizedDescription)")
                return
            }

            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }

            /* GUARD: Was there any data returned? */
            guard var data = data else {
                sendError("No data was returned by the request!")
                return
            }

            if getSubData {
                data = data.subdataWithRange(NSMakeRange(5, data.length - 5))
            }

            /* 5/6. Parse the data and use the data (happens in completion handler) */
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForPOST)
        }

        /* 7. Start the request */
        task.resume()

        return task
    }

    // MARK: DELETE

    func taskForDELETEMethod(host: String, method: String, parameters: [String:AnyObject], jsonBody: String, completionHandlerForDELETE: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {

        /* 1. Set the parameters */
        var parameters = parameters

        /* 2/3. Build the URL, Configure the request */
        let request = NSMutableURLRequest(URL: udacityURLFromParameters(host, parameters: parameters, withPathExtension: method))
        request.HTTPMethod = "DELETE"
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }

        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) { (data, response, error) in

            func sendError(error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForDELETE(result: nil, error: NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }

            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(error)")
                return
            }

            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }

            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }

            /* 5/6. Parse the data and use the data (happens in completion handler) */
            self.convertDataWithCompletionHandler(data.subdataWithRange(NSMakeRange(5, data.length - 5)), completionHandlerForConvertData: completionHandlerForDELETE)
        }

        /* 7. Start the request */
        task.resume()
        
        return task
    }

    // MARK: Helpers

    // given raw JSON, return a usable Foundation object
    private func convertDataWithCompletionHandler(data: NSData, completionHandlerForConvertData: (result: AnyObject!, error: NSError?) -> Void) {

        var parsedResult: AnyObject!
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(result: nil, error: NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }

        completionHandlerForConvertData(result: parsedResult, error: nil)
    }

    // create a URL from parameters
    private func udacityURLFromParameters(host: String, parameters: [String:AnyObject], withPathExtension: String? = nil) -> NSURL {

        let components = NSURLComponents()
        components.scheme = UdacityClient.Udacity.ApiScheme
        components.host = host
        components.path = withPathExtension ?? ""
        components.queryItems = [NSURLQueryItem]()

        for (key, value) in parameters {
            let queryItem = NSURLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }

        return components.URL!
    }

    // MARK: Shared Instance

    class func sharedInstance() -> UdacityClient {
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        return Singleton.sharedInstance
    }
}
