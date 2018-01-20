//
//  CustomUIKitExtensions.swift
//  animalhelp
//
//  Created by Aamir  on 19/01/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import Foundation

extension UIImageView {
    func setImage(WithURL url:String) {
        guard let _ = URL(string:url) else {return}
        APIService.sharedService.request(.imageURL(urlString: url)) { (result) in
            switch result {
            case .failure(let error):
                print("\(error.localizedDescription)")
            case .success(let response):
                DispatchQueue.main.async {
                    self.image = UIImage(data:response.data)
                }
            }
        }
    }
}

extension UITableViewCell {
    func showBottomPaddedSeparator() {
        let separator = CustomSeparator.paddedSeparator
        self.addSubview(separator)
        separator.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(kSidePadding)
            make.trailing.equalToSuperview().inset(kSidePadding)
        }
    }
    
}
