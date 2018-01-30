//
//  LocationManager.swift
//  animalhelp
//
//  Created by Aamir  on 21/01/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import UIKit
import CoreLocation

protocol LocationManagerDelegate {
    func locationServicesDenied()
    func userLocationDidChange()
}
class LocationManager: NSObject {
    
    fileprivate let locationManager = CLLocationManager()
    public var userLocation:AppLocation? {
        didSet {
            NotificationCenter.default.post(kNotificationUserLocationChanged)
            self.delegate?.userLocationDidChange()
        }
    }
    fileprivate var timer:Timer? = nil
    fileprivate var timeoutDuration:CFTimeInterval = 10.0
    fileprivate let geocoder = CLGeocoder()
    fileprivate var placeMark:CLPlacemark? = nil
    fileprivate var performingReverseGeocoding = false
    fileprivate var isDetectingLocation = false {
        didSet {
            if isDetectingLocation == false {
                self.bufferLocation = nil
            }
        }
    }
    fileprivate var bufferLocation:CLLocation? = nil
    static let sharedManager = LocationManager()
    
    public var delegate:LocationManagerDelegate? = nil
    public var isLocationPermissionGranted:Bool {
        get {
            return CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways
        }
    }
    
    public var userLocality:String? {
        get {
            return self.userLocation?.name
        }
    }
    
    func startDetectingLocation() {
        let authStatus = CLLocationManager.authorizationStatus()
        guard authStatus != .denied && authStatus != .restricted else {
            NotificationCenter.default.post(kNotificationLocationPerimissionDenied)
            self.delegate?.locationServicesDenied()
            return
        }
        
        self.locationManager.delegate = self
        if authStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        else {
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            self.startLocationDetectionTimer()
            locationManager.startUpdatingLocation()
            isDetectingLocation = true
            NotificationCenter.default.post(kNotificationDidStartUpdatingLocation)
        }
    }
    
    fileprivate func startLocationDetectionTimer() {
        self.timer = Timer.scheduledTimer(withTimeInterval: timeoutDuration, repeats: false, block: { (timer) in
            print("Detecting location took too long!")
            if self.isDetectingLocation {
                print("Stopping location services!")
                self.locationManager.stopUpdatingLocation()
                NotificationCenter.default.post(kNotificationUserLocationChanged)
            }
            
            if self.userLocation == nil {
                NotificationCenter.default.post(kNotificationLocationDetectionFailed)
            }
            timer.invalidate()
        })
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        NotificationCenter.default.post(kNotificationLocationDetectionFailed)
        self.isDetectingLocation = false
        print("Failed to update location")
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.last {
            print("Updated location with accuracy \(location)")
            
            if location.timestamp.timeIntervalSinceNow < -5 {
                return
            }
            if location.horizontalAccuracy < 0 {
                return
            }
            
            if self.bufferLocation == nil || self.bufferLocation!.horizontalAccuracy > location.horizontalAccuracy {
                
                if self.performingReverseGeocoding == false {
                    performingReverseGeocoding = true
                    geocoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
                        self.performingReverseGeocoding = false
                        if let error = error {
                            print("Reverse geocode failed! \(error.localizedDescription)")
                            return
                        }
                        if let place = placemarks?.first {
                            self.placeMark = place
                            self.bufferLocation = location
                            self.userLocation = AppLocation.init(from: place)
                            NotificationCenter.default.post(kNotificationUserLocationChanged)
                            self.delegate?.userLocationDidChange()
                            self.locationManager.stopUpdatingLocation()
                            self.isDetectingLocation = false
                        }
                    })
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.startDetectingLocation()
    }
}
