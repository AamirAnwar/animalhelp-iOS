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
    func didGetSearchResults(_ results:[MissingPet])
    func showLoader()
    func hideLoader()
    func showEmptyStateView()
}
    


class PetSearchViewModel {
    let APIService = animalhelp.APIService.sharedService
    var delegate:PetSearchViewModelDelegate? = nil
    var missingPets:[MissingPet] = []
    var searchResults:[MissingPet] = []
    
    
    func searchPetsWithQuery(_ query:String) {
        self.delegate?.showLoader()
        var q = query.lowercased() as NSString
        q = q.replacingOccurrences(of: " ", with: "+") as NSString
        MissingPet.searchWithQuery(query: q as String) { (pets, error) in
            self.delegate?.hideLoader()
            guard error == nil else {
                self.delegate?.showEmptyStateView()
                return
            }
            self.searchResults = pets
            self.delegate?.didGetSearchResults(pets)
        }
    }
    
    func searchForMissingPets() {
        self.delegate?.showLoader()
        MissingPet.getMissingPets { (pets, error) in
            self.delegate?.hideLoader()
            guard error == nil else {
                self.delegate?.showEmptyStateView()
                return
            }
            
            self.missingPets = pets
            self.delegate?.didUpdateMissingPets()
        }
    }
    fileprivate func parse(json:NSDictionary) {
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
            self.delegate?.hideLoader()
            self.missingPets = missingPets
            self.delegate?.didUpdateMissingPets()
        }
        
        
    }
    
    
}
