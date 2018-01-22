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
    var distance:Double? = nil
    
    static func getNearbyClinics(completion:@escaping ([Clinic])->Void) {
        if let location = LocationManager.sharedManager.userLocation {
            APIService.sharedService.request(.clinics(lat: "\(location.coordinate.latitude)", lon: "\(location.coordinate.longitude)"), completion: { (result) in
                switch result {
                case .success(let response):
                    do {
                        _ = try response.filterSuccessfulStatusCodes()
                        let data = try response.mapJSON()
                        print(data)
                        if let jsonDictionary = data as? NSDictionary {
                            completion(self.parseClinics(json: jsonDictionary))
                        }
                        
                    } catch let error {
                        // Error occured
                        print(error)
                    }
                case .failure(let error):
                    print(error)
                }
            })
        }
    }
    
    fileprivate static func parseClinics(json:NSDictionary) -> [Clinic] {
        let decoder = JSONDecoder()
        if let clinicDict = json.value(forKey: "clinics") as? Array<NSDictionary> {
            guard clinicDict.count > 0 else {return []}
            var parsedClinics = [Clinic]()
            for dict in clinicDict {
                do {
                    let clinic = try decoder.decode(Clinic.self, from: JSONSerialization.data(withJSONObject: dict, options: .init(rawValue: 0)))
                    parsedClinics += [clinic]
                } catch let error {
                    print(error)
                    return []
                }
            }
            return parsedClinics
        }
        return []
    }
    
}


