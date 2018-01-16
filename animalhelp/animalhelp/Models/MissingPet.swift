//
//  MissingPet.swift
//  animalhelp
//
//  Created by Aamir  on 16/01/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import Foundation

class MissingPet:Codable {
    var type:String!
    var breed:String? = nil
    var age:String!
    var ownerContact:String!
    var missingSince:String!
    var reward:String? = nil
    var lastKnownLocation:String? = nil
    var petDescription:String? = nil
    var distFeatures:String? = nil
    var imageURL:String? = nil
    
    
    enum CodingKeys: String, CodingKey {
        case type = "type"
        case breed = "breed"
        case age = "age"
        case reward = "reward"
        case petDescription = "description"
        case ownerContact = "owner_contact"
        case missingSince = "missing_since"
        case lastKnownLocation = "last_known_location"
        case distFeatures = "distiguishing_features"
        case imageURL = "image_url"
    }
}
