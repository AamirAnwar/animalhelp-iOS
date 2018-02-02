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
let kMissingPetImageHeight:CGFloat = 265
let kMinPopUpHeight:CGFloat = 200
let kCornerRadius:CGFloat = 4
let kStandardButtonHeight:CGFloat = 50
let kDefaultPadding:CGFloat = 8
let kDrawerUnknownLocationHeight:CGFloat = 280
let kDrawerMinimizedStateHeight:CGFloat = 30
let kSingleClinicStateHeight:CGFloat = 180
public let kDropdownAnimationDuration = 0.3
public let kStatusBarHeight:CGFloat = 20

let kCollectionViewHeight:CGFloat = 180
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
let kNotificationDidStartUpdatingLocation = Notification(name: Notification.Name.init("StartedUpatingLocation"))
let kNotificationLocationDetectionFailed = Notification(name: Notification.Name.init("LocationDetectionFailed"))

let kNotificationWillShowKeyboard = Notification(name: Notification.Name.UIKeyboardWillShow)
let kNotificationWillHideKeyboard = Notification(name: Notification.Name.UIKeyboardWillHide)

let kNotificationDidShowStatusBar = Notification(name: Notification.Name.init("didShowStatusBar"))
let kNotificationDidHideStatusBar = Notification(name: Notification.Name.init("didHideStatusBar"))

let kDrawerViewDragQuotient:CGFloat = -100
let kHideButtonSize:CGFloat = 20

let kUserProfileImageURLKey = "user_profile_image_key"
let kUserProfileNameKey = "user_name_key"

let kStringSetLocation = "Set Location"
let kStringFindingLocation = "Finding clinics around you"
let kStringDetecingLocation = "Detecting Location"
let kStringDetectLocation = "Detect Location"
let kDropdownCompletionKey = "completion"
