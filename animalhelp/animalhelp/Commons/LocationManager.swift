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
    fileprivate var timer:Timer? = nil
    fileprivate var timeoutDuration:CFTimeInterval = 10.0
    fileprivate let geocoder = CLGeocoder()
    fileprivate var placeMark:CLPlacemark? = nil
    fileprivate var performingReverseGeocoding = false
    
    static let sharedManager = LocationManager()
    public var userLocation:CLLocation? = nil
    public var delegate:LocationManagerDelegate? = nil
    public var isLocationPermissionGranted:Bool {
        get {
            return CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways
        }
    }
    
    public var userLocality:String? {
        get {
            return self.placeMark?.name
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
            
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.startLocationDetectionTimer()
            locationManager.startUpdatingLocation()
            NotificationCenter.default.post(kNotificationDidStartUpdatingLocation)
        }
    }
    
    fileprivate func startLocationDetectionTimer() {
        self.timer = Timer.scheduledTimer(withTimeInterval: timeoutDuration, repeats: false, block: { (timer) in
            print("Stopping location services!")
            if let _ = self.userLocation {
                self.locationManager.stopUpdatingLocation()
            }
            else {
                // TODO Unable to get your location. Send a callback to the viewcontroller/view
                NotificationCenter.default.post(kNotificationUserLocationChanged)
                self.delegate?.userLocationDidChange()
            }
            timer.invalidate()
        })
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        NotificationCenter.default.post(kNotificationLocationDetectionFailed)
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
            
            if self.userLocation == nil || self.userLocation!.horizontalAccuracy > location.horizontalAccuracy {
                
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
                            self.userLocation = location
                            
                            NotificationCenter.default.post(kNotificationUserLocationChanged)
                            self.delegate?.userLocationDidChange()
                            self.locationManager.stopUpdatingLocation()
                        }
                        
                    })
                }
            }
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.startDetectingLocation()
    }
    
    func setLocation(_ newLocation:CLLocation) {
        self.userLocation = newLocation
        NotificationCenter.default.post(kNotificationUserLocationChanged)
        self.delegate?.userLocationDidChange()
    }
}
