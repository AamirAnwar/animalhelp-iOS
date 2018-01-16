//
//  MissingPetDetailViewController.swift
//  animalhelp
//
//  Created by Aamir  on 16/01/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import Foundation
import UIKit

class MissingPetViewController:BaseViewController {
    var pet:MissingPet!
    var imageView:UIImageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customNavBar.setTitle("\(pet.type!)")
        self.view.addSubview(imageView)
        self.imageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(120)
        }
        self.imageView.contentMode = .scaleAspectFill
        self.imageView.clipsToBounds = true
        
        if let urlString = self.pet.imageURL, let url = URL(string:urlString) {
            self.getDataFromUrl(url: url) { data, response, error in
                guard let data = data, error == nil else { return }
                print(response?.suggestedFilename ?? url.lastPathComponent)
                print("Download Finished")
                DispatchQueue.main.async() {
                    self.imageView.image = UIImage(data: data)
                }
            }
        }

    }
    
    func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
            }.resume()
    }
}
