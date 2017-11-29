//
//  Clinic.swift
//  animalhelp
//
//  Created by Aamir  on 25/11/17.
//  Copyright © 2017 AamirAnwar. All rights reserved.
//

import Foundation

struct Clinic:Codable {
    var _id:String
    var name:String
    var lon:Double
    var lat:Double
    var city:String
    var mobile:String
    var address:String
}

struct NearestClinic:Codable {
    var distance:Double
    var clinic:Clinic
}
