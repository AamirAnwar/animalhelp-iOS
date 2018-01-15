//
//  HomeViewModel.swift
//  animalhelp
//
//  Created by Aamir  on 29/11/17.
//  Copyright © 2017 AamirAnwar. All rights reserved.
//

import Foundation
import Moya
import CoreLocation
import GoogleMaps


protocol HomeViewModelDelegate {
    func locationServicesDenied() -> Void
    func didUpdate(_ updatedMarker:GMSMarker) -> Void
    func showUserLocation(location:CLLocation)->Void
    func transitionTo(state:HomeViewState)
    func showDrawerWith(clinic:NearestClinic)
}

class HomeViewModel:NSObject {
    let APIService = MoyaProvider<APIService>()
    let locationManager = CLLocationManager()
    var detectedLocation:CLLocation?
    var timer:Timer?
    var timeoutDuration:CFTimeInterval = 10.0
    var delegate:HomeViewModelDelegate?
    var nearestClinic:NearestClinic?
    var nearestClinicMarker:GMSMarker?
    var isLocationPermissionGranted:Bool {
        get {
            return CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways
        }
    }
    
    func updateViewState() {
        if self.isLocationPermissionGranted == false {
            self.delegate?.transitionTo(state: .UserLocationUnknown)
        }
        else {
            if self.detectedLocation != nil {
//                self.updateNearestClinic()
            }
            else {
                self.startDetectingLocation()
            }
        }
    }
    
    func startDetectingLocation() {
        let authStatus = CLLocationManager.authorizationStatus()
        guard authStatus != .denied && authStatus != .restricted else {
            self.delegate?.locationServicesDenied()
            return
        }
        
        locationManager.delegate = self
        if authStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        else {
            
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.startLocationDetectionTimer()
            locationManager.startUpdatingLocation()
        }
    }
    
    func stopDetectingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    func updateNearestClinic() {
        if let location = self.detectedLocation {
            APIService.request(.nearestClinic(lat: "\(location.coordinate.latitude)", lon: "\(location.coordinate.longitude)"), completion: { (result) in
                switch result {
                case .success(let response):
                    do {
                        _ = try response.filterSuccessfulStatusCodes()
                        let data = try response.mapJSON()
                        print(data)
                        if let jsonDictionary = data as? NSDictionary {
                            self.handleJSON(json: jsonDictionary)
                        }
                        
                    } catch let error {
                        // Error occured
                        print(error)
                    }
                case .failure(let error):
                    print(error)
                }
            })
        }
    }
    
    func handleJSON(json:NSDictionary) {
        let decoder = JSONDecoder()
        do {
            nearestClinic = try decoder.decode(NearestClinic.self, from: JSONSerialization.data(withJSONObject: json, options: .init(rawValue: 0)))
        } catch let error {
            print("error! \(error)")
            return;
        }
        if let nearestClinic = nearestClinic {
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: nearestClinic.clinic.lat, longitude: nearestClinic.clinic.lon)
            marker.title = nearestClinic.clinic.name
            marker.snippet = nearestClinic.clinic.address
            self.nearestClinicMarker = marker
            self.delegate?.transitionTo(state: .SingleClinicDrawer)
            self.delegate?.didUpdate(marker)
        }
    }
    
    fileprivate func startLocationDetectionTimer() {
        self.timer = Timer.scheduledTimer(withTimeInterval: timeoutDuration, repeats: false, block: { (timer) in
            print("Stopping location services!")
            if let location = self.detectedLocation {
                self.delegate?.transitionTo(state: .MinimizedDrawer)
                self.delegate?.showUserLocation(location: location)
                self.stopDetectingLocation()
            }
            else {
                // TODO Unable to get your location. Send a callback to the viewcontroller/view
            }
            timer.invalidate()
        })
    }
    
}
extension HomeViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
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
            
            if self.detectedLocation == nil || self.detectedLocation!.horizontalAccuracy > location.horizontalAccuracy {
                self.detectedLocation = location
                self.delegate?.transitionTo(state: .HiddenDrawer)
                self.delegate?.showUserLocation(location: location)
                self.stopDetectingLocation()
            }
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.startDetectingLocation()
    }
}

extension HomeViewModel:DrawerViewDelegate {
    func didTapHideDrawerButton() {
        self.delegate?.transitionTo(state: .HiddenDrawer)
    }
    
    func didTapStickyButton(seeMore: Bool) {
        if seeMore {
                self.delegate?.transitionTo(state: .MaximizedDrawer)
        }
        else {
            self.delegate?.transitionTo(state: .SingleClinicDrawer)
        }
        
    }
    
    func didTapOpenInGoogleMaps(forIndex indexPath: IndexPath) {
        if let clinic = self.nearestClinic {
            let urlString = "comgooglemaps://?daddr=\(clinic.clinic.address)&directionsmode=driving".addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
            if let urlString = urlString ,let url = URL(string:urlString) ,(UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
                
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                
            } else {
                print("Unable to open in google maps \(clinic)");
            }
        }
   }
    
    func didTapManuallySelectLocation() {
        //TODO Start manual selection flow
    }
    
    func didTapDetectLocation() {
        //Start detecting location if there is no location
        if self.detectedLocation == nil {
            self.startDetectingLocation()
        }
    }
}

extension HomeViewModel:GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if let nearestClinic = self.nearestClinic, self.nearestClinicMarker == marker {
            self.delegate?.transitionTo(state: .SingleClinicDrawer)
            self.delegate?.showDrawerWith(clinic: nearestClinic)
        }
        return true
    }
}


