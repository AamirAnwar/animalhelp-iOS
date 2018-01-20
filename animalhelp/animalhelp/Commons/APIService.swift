//
//  APIService.swift
//  animalhelp
//
//  Created by Aamir  on 29/11/17.
//  Copyright © 2017 AamirAnwar. All rights reserved.
//

import Foundation
import Moya

enum APIService {
    static let defaultHeaders = ["user_client":"ios"]
    static let sharedService = MoyaProvider<APIService>()
    case nearestClinic(lat:String, lon:String)
    case clinics(lat:String, lon:String)
    case missingPets(cityID:Int)
    case imageURL(urlString:String)
}

extension APIService: TargetType {
    var baseURL: URL {
        switch self {
        case .imageURL(let urlString):
            if let url = URL(string:urlString) {
                return url
            }
        default:break;
        }
        return URL(string: "https://lit-escarpment-51045.herokuapp.com")!
    }
    
    var path: String {
        switch self {
        case .nearestClinic: return "/clinics/nearest"
        case .clinics:return "/clinics"
        case .missingPets:return "/missing_pets"
        default:return ""
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .nearestClinic,.clinics,.missingPets,.imageURL:return .get
        
        }
    }
    
    var sampleData: Data {
        switch self {
        case .nearestClinic,.clinics,.missingPets,.imageURL :return Data()
            
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .clinics(let lat, let lon),.nearestClinic(let lat, let lon):
            return Moya.Task.requestParameters(parameters: ["lat":lat,"lon":lon], encoding: URLEncoding.queryString)
        case .missingPets(let cityID):
            return Moya.Task.requestParameters(parameters: ["city_id":cityID], encoding: URLEncoding.queryString)
        case .imageURL:
            return Moya.Task.requestPlain
        }
    }
    
    var headers: [String : String]? {
        return APIService.defaultHeaders
    }
}
