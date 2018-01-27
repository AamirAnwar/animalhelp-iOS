//
//  CustomSeparator.swift
//  animalhelp
//
//  Created by Aamir  on 19/01/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import Foundation
import UIKit

class CustomSeparator:UIView {
    static var separator:CustomSeparator {
        get {
            let sep = CustomSeparator()
            sep.backgroundColor = CustomColorSeparatorGrey
            sep.snp.makeConstraints { (make) in
                make.height.equalTo(kSeparatorHeight)
            }
            return sep
        }
    }
}

