//
//  PetSearchViewModel.swift
//  animalhelp
//
//  Created by Aamir  on 16/01/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import Foundation
import UIKit
import Moya

protocol PetSearchViewModelDelegate {
    func didUpdateMissingPets()
}
    


class PetSearchViewModel {
    let APIService = MoyaProvider<APIService>()
    var delegate:PetSearchViewModelDelegate? = nil
    var missingPets:[MissingPet] = []
    func searchForMissingPets() {
        APIService.request(.missingPets(cityID:1), completion: { (result) in
            switch result {
            case .success(let response):
                do {
                    _ = try response.filterSuccessfulStatusCodes()
                    let data = try response.mapJSON()
                    print(data)
                    if let jsonDictionary = data as? NSDictionary {
                        self.parse(json: jsonDictionary)
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
    fileprivate func parse(json:NSDictionary) {
        print(json)
        let decoder = JSONDecoder()
        if let missingPetDict = json.value(forKey: "pets") as? Array<NSDictionary> {
            guard missingPetDict.count > 0 else {return}
            
            var missingPets = [MissingPet]()
            
            for dict in missingPetDict {
                do {
                    let missingPet = try decoder.decode(MissingPet.self, from: JSONSerialization.data(withJSONObject: dict, options: .init(rawValue: 0)))
                    
                    missingPets += [missingPet]
                } catch let error {
                    print(error)
                    return
                }
            }
            
            self.missingPets = missingPets
            if let urlString = self.missingPets.first?.imageURL, let petImageURL = URL(string:urlString) {
                
            }
            self.delegate?.didUpdateMissingPets()
        }
        
        
    }
    
    
}
