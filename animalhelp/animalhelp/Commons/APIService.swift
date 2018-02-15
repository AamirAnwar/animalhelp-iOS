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
    case petSearch(cityID:Int, query:String)
    case imageURL(urlString:String)
    case locationSearch(query:String)
    case activeCities
}

extension APIService: TargetType {
    var baseURL: URL {
        switch self {
        case .imageURL(let urlString):
            if let url = URL(string:urlString) {
                return url
            }
        case .locationSearch(let query):
            
            if let location = LocationManager.sharedManager.userLocation {
                let lat = location.latitude
                let lon = location.longitude
                return URL(string:"https://maps.googleapis.com/maps/api/place/textsearch/json?query=\(query))&location=\(lat),\(lon)&radius=3000&key=\(GoogleMapsAPIKey!)")!
            }
            return URL(string:"https://maps.googleapis.com/maps/api/place/textsearch/json?query=\(query))&key=\(GoogleMapsAPIKey!)")!
        default:break;
        }
        return URL(string: "https://lit-escarpment-51045.herokuapp.com")!
    }
    
    var path: String {
        switch self {
        case .nearestClinic: return "/clinics/nearest"
        case .clinics:return "/clinics"
        case .missingPets:return "/missingpets"
        case .petSearch:return "/missingpets/search"
        case .activeCities: return "/active_cities"
            
        default:return ""
        }
    }
    
    var method: Moya.Method {
        switch self {
        default :return .get
        }
    }
    
    var sampleData: Data {
        switch self {
        default :return Data()
            
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .clinics(let lat, let lon),.nearestClinic(let lat, let lon):
            return Moya.Task.requestParameters(parameters: ["lat":lat,"lon":lon], encoding: URLEncoding.queryString)
        case .petSearch(let cityID, let query):
            return Moya.Task.requestParameters(parameters: ["city_id":cityID,"q":query], encoding: URLEncoding.queryString)
        case .missingPets(let cityID):
            return Moya.Task.requestParameters(parameters: ["city_id":cityID], encoding: URLEncoding.queryString)
        case .imageURL,.locationSearch:
            return Moya.Task.requestPlain
        case .activeCities:
            return Moya.Task.requestPlain
        }
    }
    
    var headers: [String : String]? {
        return APIService.defaultHeaders
    }
}
