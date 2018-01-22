//
//  Constants.swift
//  animalhelp
//
//  Created by Aamir  on 29/11/17.
//  Copyright © 2017 AamirAnwar. All rights reserved.
//

import Foundation
import UIKit

var GoogleMapsAPIKey:String?
let kCornerRadius:CGFloat = 4
let kStandardButtonHeight = 50
let kCollectionViewHeight:CGFloat = 277
let kSocialLoginButtonHeight:CGFloat = 48
let kSidePadding:CGFloat = 18
let kSeparatorHeight:CGFloat = 1
let kProfileImageHeight:CGFloat = 187
let kNotificationLoggedInSuccessfully = Notification(name: Notification.Name.init("kLoggedInSuccessfully"))
let kNotificationLoginFailed = Notification(name: Notification.Name.init("kLoginFailed"))
let kNotificationLoggedOutSuccessfully = Notification(name: Notification.Name.init("kLoggedOutSuccessfully"))
let kNotificationLogOutFailed = Notification(name: Notification.Name.init("kLogoutFailed"))

let kNotificationUserLocationChanged = Notification(name: Notification.Name.init("userLocationChanged"))
let kNotificationLocationPerimissionGiven = Notification(name: Notification.Name.init("LocationPerimissionGiven"))
let kNotificationLocationPerimissionDenied = Notification(name: Notification.Name.init("LocationPerimissionDenied"))


