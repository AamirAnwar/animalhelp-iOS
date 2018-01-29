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
    
    static func getMissingPets(completion:@escaping ([MissingPet], Error?) -> Void) {
        // Get current city ID
        APIService.sharedService.request(.missingPets(cityID:1), completion: { (result) in
            switch result {
            case .success(let response):
                do {
                    _ = try response.filterSuccessfulStatusCodes()
                    let data = try response.mapJSON()
                    print(data)
                    if let jsonDictionary = data as? NSDictionary {
                        completion(self.parse(json: jsonDictionary), nil)
                    }
                    else {
                        completion([],nil)
                    }
                    
                    
                } catch let error {
                    // Error occured
                    completion([],nil)
                    print(error)
                }
            case .failure(let error):
                completion([],error)
                print(error)
            }
        })
    }
    
    static func searchWithQuery(query:String,completion:@escaping ([MissingPet], Error?) -> Void) {
        // Get current city ID
        APIService.sharedService.request(.petSearch(cityID:1,query:query), completion: { (result) in
            switch result {
            case .success(let response):
                do {
                    _ = try response.filterSuccessfulStatusCodes()
                    let data = try response.mapJSON()
                    print(data)
                    if let jsonDictionary = data as? NSDictionary {
                        completion(self.parse(json: jsonDictionary), nil)
                    } else {
                        completion([], nil)
                    }
                    
                } catch let error {
                    // Error occured
                    completion([], error)
                    print(error)
                }
            case .failure(let error):
                print(error)
            }
        })
    }
    
    fileprivate static func parse(json:NSDictionary) -> [MissingPet] {
        print(json)
        let decoder = JSONDecoder()
        var missingPets = [MissingPet]()
        if let missingPetDict = json.value(forKey: "pets") as? Array<NSDictionary> {
            guard missingPetDict.count > 0 else {return []}
            for dict in missingPetDict {
                do {
                    let missingPet = try decoder.decode(MissingPet.self, from: JSONSerialization.data(withJSONObject: dict, options: .init(rawValue: 0)))
                    missingPets += [missingPet]
                } catch let error {
                    print(error)
                    return []
                }
            }
        }
        
        return missingPets
    }
    
    
}
