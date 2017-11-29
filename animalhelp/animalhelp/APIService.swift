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
    case nearestClinic(lat:String, lon:String)
    case clinics
}

extension APIService: TargetType {
    var baseURL: URL {
        return URL(string: "http://localhost:3000")!
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
        case .nearestClinic(let lat, let lon): return Moya.Task.requestParameters(parameters: ["lat":lat,"lon":lon], encoding: URLEncoding.queryString)
         case .clinics: return Moya.Task.requestPlain
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .nearestClinic:return nil
        case .clinics:return nil
        }
    }
    
    
}
