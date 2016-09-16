//
//  UdacityUser.swift
//  Geodentify
//
//  Created by Y50-70 on 13/09/16.
//  Copyright © 2016 Chashmeet Singh. All rights reserved.
//

// MARK: - UdacityUser

struct UdacityUser {

    // MARK: Properties

    var objectID: String
    var uniqueKey: String
    var firstName: String
    var lastName: String
    var mediaURL: String
    var latitude: Double
    var longitude: Double

    // MARK: Initializers

    // construct a UdacityUser from a dictionary
    init(dictionary: [String:AnyObject]) {
        if let objectID = dictionary[UdacityClient.ParseResponseKeys.ObjectID] {
            self.objectID = objectID as! String
        } else {
            self.objectID = ""
        }
        if let uniqueKey = dictionary[UdacityClient.ParseResponseKeys.UserID] {
            self.uniqueKey = uniqueKey as! String
        } else {
            self.uniqueKey = ""
        }
        if let firstName = dictionary[UdacityClient.ParseResponseKeys.FirstName] {
            self.firstName = firstName as! String
        } else {
            self.firstName = ""
        }
        if let lastName = dictionary[UdacityClient.ParseResponseKeys.LastName] {
            self.lastName = lastName as! String
        } else {
            self.lastName = ""
        }
        if let mediaURL = dictionary[UdacityClient.ParseResponseKeys.MediaUrl] {
            self.mediaURL = mediaURL as! String
        } else {
            self.mediaURL = ""
        }
        if let latitude = dictionary[UdacityClient.ParseResponseKeys.Latitude] {
            self.latitude = latitude as! Double
        } else {
            self.latitude = 0.0
        }
        if let longitude = dictionary[UdacityClient.ParseResponseKeys.Longitude] {
            self.longitude = longitude as! Double
        } else {
            self.longitude = 0.0
        }
    }

    static func getNewUser(result: [String:AnyObject]) -> UdacityUser {

        let user = UdacityUser(dictionary: result)

        return user
    }

    static func usersFromResults(results: [[String:AnyObject]]) -> [UdacityUser] {

        var users = [UdacityUser]()

        // iterate through array of dictionaries, each Movie is a dictionary
        for result in results {
            users.append(UdacityUser(dictionary: result))
        }

        return users
    }
}
