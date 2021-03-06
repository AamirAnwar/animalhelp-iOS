//
//  CustomLocation.swift
//  animalhelp
//
//  Created by Aamir  on 21/01/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import Foundation
import CoreLocation

class AppLocation:NSObject, Codable {
    var name:String
    var latitude:Double
    var longitude:Double

    enum CodingKeys: String, CodingKey {
        case name = "name"
        case latitude = "lat"
        case longitude = "lon"
    }
    
    init(name:String, lat:Double, lon:Double) {
        self.name = name
        self.latitude = lat
        self.longitude = lon
        super.init()
    }
    
    init?(from placemark:CLPlacemark) {
        guard let name = placemark.name,let location = placemark.location else {return nil}
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
        self.name = name
        super.init()
    }
    
    init(from location:CustomLocation) {
        self.latitude = Double.init(location.latitude)
        self.longitude = Double.init(location.longitude)
        self.name = location.name
        super.init()
    }
    
    static func getActiveCities(completion:@escaping ([AppLocation], Error?) -> Void) {
        APIService.sharedService.request(.activeCities) { (result) in
            switch result {
            case .failure(let error):
                print("error! \(error.localizedDescription)")
                completion([],error)
            case .success(let response):
                do {
                    _ = try response.filterSuccessfulStatusCodes()
                    let data = try response.mapJSON()
                    if let responseDict = data as? NSDictionary {
                        completion(self.parseActiveCities(responseDict),nil)
                    }
                } catch let error {
                    print(error.localizedDescription)
                }
                
            }
        }
    }
    
    static func parseActiveCities(_ jsonDict:NSDictionary) -> [AppLocation] {
        let decoder = JSONDecoder()
        if let locationsDict = jsonDict.value(forKey: "cities") as? Array<NSDictionary> {
            guard locationsDict.isEmpty == false else {return []}
            var parsedLocations = [AppLocation]()
            for dict in locationsDict {
                do {
                    let location = try decoder.decode(AppLocation.self, from: JSONSerialization.data(withJSONObject: dict, options: .init(rawValue: 0)))
                    parsedLocations += [location]
                } catch let error {
                    print(error)
                    return []
                }
            }
            return parsedLocations
        }
        return []
    }
}



struct CustomLocation:Codable {
    var formattedAddress:String
    var latitude:Float
    var longitude:Float
    var id:String
    var name:String
    
    enum CodingKeys: String, CodingKey {
        case formattedAddress = "formatted_address"
        case id = "id"
        case name = "name"
        case geometry
    }
    
    enum GeometryKeys:String, CodingKey {
        case location = "location"
    }
    
    enum LocationKeys:String, CodingKey {
        case latitude = "lat"
        case longitude = "lng"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try values.decode(String.self, forKey:.name)
        self.id = try values.decode(String.self, forKey:.id)
        self.formattedAddress = try values.decode(String.self, forKey:.formattedAddress)
        let geometry = try values.nestedContainer(keyedBy:GeometryKeys.self, forKey: .geometry)
        let location = try geometry.nestedContainer(keyedBy: LocationKeys.self, forKey: .location)
        self.latitude = try location.decode(Float.self, forKey: .latitude)
        self.longitude = try location.decode(Float.self, forKey: .longitude)
    }
    
    func encode(to encoder: Encoder) throws {
        // TODO
    }
    
    
    public static func performLocationSearchWith(UserQuery query:String?, completion: @escaping ([CustomLocation])->Void) {
        if let query = query {
            var queryString = query.lowercased() as NSString
            queryString = queryString.replacingOccurrences(of: " ", with: "+") as NSString
            APIService.sharedService.request(.locationSearch(query: queryString as String), completion: { (result) in
                switch result {
                case .failure(let error):print("\(error.localizedDescription)")
                case.success(let response):
                    do {
                        _ = try response.filterSuccessfulStatusCodes()
                        let data = try response.mapJSON()
                        if let responseDict = data as? NSDictionary {
                            completion( self.parseLocations(responseDict))
                        }
                    } catch let error {
                        print(error.localizedDescription)
                    }
                }
            })
        }
        
    }
    
    fileprivate static func parseLocations(_ jsonDict:NSDictionary) -> [CustomLocation] {
        let decoder = JSONDecoder()
        if let locationsDict = jsonDict.value(forKey: "results") as? Array<NSDictionary> {
            guard locationsDict.isEmpty == false else {return []}
            var parsedLocations = [CustomLocation]()
            for dict in locationsDict {
                do {
                    let location = try decoder.decode(CustomLocation.self, from: JSONSerialization.data(withJSONObject: dict, options: .init(rawValue: 0)))
                    parsedLocations += [location]
                } catch let error {
                    print(error)
                    return []
                }
            }
            return parsedLocations
        }
        return []
    }
    
}
