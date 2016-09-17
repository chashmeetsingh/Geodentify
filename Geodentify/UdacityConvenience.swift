//
//  UdacityConvenience.swift
//  Geodentify
//
//  Created by Y50-70 on 14/09/16.
//  Copyright © 2016 Chashmeet Singh. All rights reserved.
//

import Foundation
import UIKit

extension UdacityClient {

    func authenticateWithViewController(jsonBody: String, hostViewController: UIViewController, completionHandlerForAuth: (success: Bool, errorString: String?) -> Void) {
        
        taskForPOSTMethod(UdacityClient.Udacity.ApiHost, method: "/api/session", parameters: [:], getSubData: true, jsonBody: jsonBody, completionHandlerForPOST: { (results, error) in
            if let error = error {
                print(error)
                completionHandlerForAuth(success: false, errorString: error.localizedDescription)
            } else if let session = results[UdacityClient.UdactiyResponseKeys.Session], let user = results[UdacityClient.UdactiyResponseKeys.Account] {

                guard let sessionID = session![UdacityClient.UdactiyResponseKeys.SessionID] as? String else {
                    completionHandlerForAuth(success: false, errorString: "Cannot find key '\(UdacityClient.UdactiyResponseKeys.SessionID)' in \(results)")
                    return
                }
                self.sessionID = sessionID

                guard let userID = user![UdacityClient.UdactiyResponseKeys.Key] as? String else {
                    completionHandlerForAuth(success: false, errorString: "Cannot find key '\(UdacityClient.UdactiyResponseKeys.Key)' in \(results)")
                    return
                }
                self.userID = userID
                completionHandlerForAuth(success: true, errorString: nil)

            } else {
                completionHandlerForAuth(success: false, errorString: "Cannot find key '\(UdacityClient.UdactiyResponseKeys.Session)' in \(results)")
            }
        })

    }

    func fetchUsersList(hostViewController: UIViewController, completionHandlerForUserList: (result: [UdacityUser]?, error: NSError?) -> Void) {
        let methodParameters: [String : AnyObject] = [
            UdacityClient.UdacityParameterKeys.Limit: UdacityClient.ParseParamterValues.UserLimit,
            UdacityClient.UdacityParameterKeys.Sort: "-updatedAt"
        ]

        taskForGETMethod(UdacityClient.Udacity.ApiParseHost, method: "/parse/classes/StudentLocation", parameters: methodParameters,getSubData: false, completionHandlerForGET: { (results, error) in
            if error != nil {
                completionHandlerForUserList(result: nil, error: error)
            } else {

                if let results = results[UdacityClient.ParseResponseKeys.Results] as? [[String:AnyObject]] {
                    let users = UdacityUser.usersFromResults(results)
                    completionHandlerForUserList(result: users, error: nil)
                } else {
                    completionHandlerForUserList(result: nil, error: NSError(domain: "fetchUsersList parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse fetchUsersList"]))
                }
            }
        })
    }

    func logOutUser(hostViewController: UIViewController, completionHandlerForUserSignOut: (result: Bool, error: NSError?) -> Void) {
        taskForDELETEMethod(UdacityClient.Udacity.ApiHost, method: "/api/session", parameters: [:], jsonBody: "", completionHandlerForDELETE: { (results, error) in
            if error != nil {
                completionHandlerForUserSignOut(result: false, error: error)
            } else {
                completionHandlerForUserSignOut(result: true, error: nil)
            }
        })
    }

    func getCurrentUserData(hostViewController: UIViewController, completionHandlerForCurrentUser: (result: Bool, error: NSError?, user: User?) -> Void) {
        taskForGETMethod(UdacityClient.Udacity.ApiHost, method: "/api/users/\(self.userID)", parameters: [:], getSubData: true, completionHandlerForGET: { (results, error) in
            if error != nil {
                completionHandlerForCurrentUser(result: false, error: error, user: nil)
            } else {
                guard let userData = results[UdacityClient.PublicUserDataResponseKeys.User] as? [String:AnyObject] else  {
                    completionHandlerForCurrentUser(result: false, error: error, user: nil)
                    return
                }
                var user = User()
                user.id = self.userID
                if let nickname = userData[UdacityClient.PublicUserDataResponseKeys.Nickname] {
                    user.firstName = nickname as! String
                }

                if let lastname = userData[UdacityClient.PublicUserDataResponseKeys.Lastname] {
                    user.lastName = lastname as! String
                }
                completionHandlerForCurrentUser(result: true, error: nil, user: user)
            }
        })
    }

    func postPin(jsonBody: String, hostViewController: UIViewController, completionHandlerForPostPin: (result: Bool, error: NSError?) -> Void){

        taskForPOSTMethod(UdacityClient.Udacity.ApiParseHost, method: "/parse/classes/StudentLocation", parameters: [:], getSubData: false, jsonBody: jsonBody, completionHandlerForPOST: { (results, error) in
            if error == nil {
                completionHandlerForPostPin(result: true, error: nil)
            } else {
                completionHandlerForPostPin(result: false, error: error)
            }
        })
    }

}
