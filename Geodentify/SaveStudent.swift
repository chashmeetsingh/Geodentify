//
//  SaveStudent.swift
//  Geodentify
//
//  Created by Y50-70 on 17/09/16.
//  Copyright © 2016 Chashmeet Singh. All rights reserved.
//

import Foundation

final class SaveStudent{
    var students = [UdacityUser]()

    func setStudentData(data: [UdacityUser]){
        students = data
    }

    func getStudentData() -> [UdacityUser]{
        return students
    }

    class func sharedInstance() -> SaveStudent {
        struct Singleton {
            static var sharedInstance = SaveStudent()
        }
        return Singleton.sharedInstance
    }
    
}
