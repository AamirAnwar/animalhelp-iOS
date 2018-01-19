//
//  CustomUIKitExtensions.swift
//  animalhelp
//
//  Created by Aamir  on 19/01/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import Foundation

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
