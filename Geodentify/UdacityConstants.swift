//
//  UdacityConstants.swift
//  Geodentify
//
//  Created by Y50-70 on 13/09/16.
//  Copyright © 2016 Chashmeet Singh. All rights reserved.
//

import Foundation
import UIKit

// MARK: - UdacityClient (Constants)

extension UdacityClient {

    // MARK: Udacity
    struct Udacity {
        static let ApiScheme = "https"
        static let ApiHost = "www.udacity.com"
        static let ApiParseHost = "parse.udacity.com"
    }

    // MARK: Udacity Parameter Keys
    struct UdacityParameterKeys {
        static let SessionID = "session_id"
        static let Username = "username"
        static let Password = "password"
        static let Limit = "limit"
    }

    // MARK: Udacity Response Keys
    struct UdactiyResponseKeys {
        static let Key = "key"
        static let Registered = "registered"
        static let Expiration = "expiration"
        static let Session = "session"
        static let SessionID = "id"
        static let Account = "account"
    }

    // Mark: Parse Parameter Keys
    struct ParseParamterKeys {
        static let AppID = "X-Parse-Application-Id"
        static let APIKey = "X-Parse-REST-API-Key"
    }

    // Mark: Parse Parameter Values
    struct ParseParamterValues {
        static let AppID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let APIKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        static let UserLimit = 100
    }

    // Mark: Parse Response Keys
    struct ParseResponseKeys {
        static let ObjectID = "objectId"
        static let LastName = "lastName"
        static let FirstName = "firstName"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let MediaUrl = "mediaURL"
        static let UserID = "uniqueKey"
        static let MapString = "mapString"
        static let Results = "results"
    }

    // Mark: User Data Response Keys
    struct PublicUserDataResponseKeys {
        static let User = "user"
        static let Nickname = "nickname"
        static let Lastname = "last_name"
    }

    // MARK: UI
    struct UI {
        static let LoginColorTop = UIColor(red: 0.345, green: 0.839, blue: 0.988, alpha: 1.0).CGColor
        static let LoginColorBottom = UIColor(red: 0.023, green: 0.569, blue: 0.910, alpha: 1.0).CGColor
        static let GreyColor = UIColor(red: 0.702, green: 0.863, blue: 0.929, alpha:1.0)
        static let BlueColor = UIColor(red: 0.0, green:0.502, blue:0.839, alpha: 1.0)
    }
}
