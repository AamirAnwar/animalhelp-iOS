//
//  CustomColors.swift
//  animalhelp
//
//  Created by Aamir  on 04/01/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import Foundation
import UIKit

let CustomColorMainTheme = UIColor.init(hex:0xEB4545)
let CustomColorDarkGray = UIColor.init(hex:0x8F8F8F)
let CustomColorLightGray = UIColor.init(hex:0x9B9B9B)
let CustomColorTextBlack = UIColor.init(hex:0x494949)
let CustomColorFacebookBlue = UIColor.init(hex:0x385591)
let CustomColorGoogleOrange = UIColor.init(hex:0xD34836)
let CustomColorSeparatorGrey = UIColor.init(hex:0xE8E8E8)
let CustomColorGreen = UIColor.init(hex:0x16AC16)



extension UIColor {
    convenience init(red:Int, green:Int, blue:Int) {
        guard (red >= 0 && red <= 255) && (green >= 0 && green <= 255) && (blue >= 0 && blue <= 255) else {
            self.init()
            return
        }
        let redComponent = CGFloat.init(red)/255.0
        let greenComponent = CGFloat.init(green)/255.0
        let blueComponent = CGFloat.init(blue)/255.0
        self.init(red: redComponent, green: greenComponent, blue: blueComponent, alpha: 1.0)
    }
    
    convenience init(hex:Int) {
        self.init(red: (hex >> 16) & 0xFF, green: (hex >> 8) & 0xFF, blue: (hex) & 0xFF)
    }
}
