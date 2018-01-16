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
    case nearestClinic(lat:String, lon:String)
    case clinics(lat:String, lon:String)
}

extension APIService: TargetType {
    var baseURL: URL {
        return URL(string: "https://lit-escarpment-51045.herokuapp.com")!
    }
    
    var path: String {
        switch self {
        case .nearestClinic: return "/clinics/nearest"
        case .clinics:return "/clinics"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .nearestClinic,.clinics:return .get
            
        }
    }
    
    var sampleData: Data {
        switch self {
        case .nearestClinic,.clinics :return Data()
            
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .clinics(let lat, let lon),.nearestClinic(let lat, let lon): return Moya.Task.requestParameters(parameters: ["lat":lat,"lon":lon], encoding: URLEncoding.queryString)
        }
    }
    
    var headers: [String : String]? {
        return APIService.defaultHeaders
    }
    
    
}
