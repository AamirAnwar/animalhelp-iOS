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
    func showDrawerWith(clinic:Clinic)
    func showDrawerWith(selectedIndex:Int, clinics:[Clinic])
    func showMarkers(markers:[GMSMarker])
    func zoomIntoNearestClinic()
    func zoomToMarker(_ marker:GMSMarker)
}

class HomeViewModel:NSObject {
    let APIService = MoyaProvider<APIService>()
    let locationManager = CLLocationManager()
    var detectedLocation:CLLocation?
    var timer:Timer?
    var timeoutDuration:CFTimeInterval = 10.0
    var delegate:HomeViewModelDelegate?
    var nearestClinic:Clinic? {
        get {
            return self.nearbyClinics?.first
        }
    }
    var nearbyClinics:[Clinic]?
    var nearbyClinicsMarkers:[GMSMarker]?
    var nearestClinicMarker:GMSMarker? {
        get {
            return self.nearbyClinicsMarkers?.first
        }
    }
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
    
    func getNearbyClinics() {
        // TODO - Pass in City here
        if let location = self.detectedLocation {
            APIService.request(.clinics(lat: "\(location.coordinate.latitude)", lon: "\(location.coordinate.longitude)"), completion: { (result) in
                switch result {
                case .success(let response):
                    do {
                        _ = try response.filterSuccessfulStatusCodes()
                        let data = try response.mapJSON()
                        print(data)
                        if let jsonDictionary = data as? NSDictionary {
                            self.parseClinics(json: jsonDictionary)
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
    
    func parseClinics(json:NSDictionary) {
        print(json)
        let decoder = JSONDecoder()
        if let clinicDict = json.value(forKey: "clinics") as? Array<NSDictionary> {
            guard clinicDict.count > 0 else {return}
            
            var parsedClinics = [Clinic]()

            for dict in clinicDict {
                do {
                    let clinic = try decoder.decode(Clinic.self, from: JSONSerialization.data(withJSONObject: dict, options: .init(rawValue: 0)))

                    parsedClinics += [clinic]
                } catch let error {
                    print(error)
                    return
                }
            }
            self.nearbyClinics = parsedClinics
            
            // Remove any previous markers from the map
            if let clinicMarkers = self.nearbyClinicsMarkers {
                clinicMarkers.forEach({ (marker) in
                    marker.map = nil
                })
            }
            
            self.nearbyClinicsMarkers = parsedClinics.map({ (clinic) -> GMSMarker in
                return self.createMarkerWithClinic(clinic: clinic)
            })
            self.delegate?.showMarkers(markers:self.nearbyClinicsMarkers!)
            self.delegate?.transitionTo(state: .SingleClinicDrawer)
            self.delegate?.zoomIntoNearestClinic()

        }
    }
    
    func createMarkerWithClinic(clinic:Clinic)->GMSMarker {
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: clinic.lat, longitude: clinic.lon)
        marker.title = clinic.name
        marker.snippet = clinic.address
        return marker
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
    func didSwipeToClinicAt(index:Int) {
        if let markers = self.nearbyClinicsMarkers, markers.count > index {
            self.delegate?.zoomToMarker(markers[index])
        }
        
    }
    
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
        guard let nearbyClinics = self.nearbyClinicsMarkers, indexPath.row < nearbyClinics.count else {return}
        if let clinic = self.nearbyClinics?[indexPath.row] {
            let urlString = "comgooglemaps://?daddr=\(clinic.address)&directionsmode=driving".addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
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
        if let clinics = self.nearbyClinics, let markers = self.nearbyClinicsMarkers {
            if let index = markers.index(of: marker) {
                self.delegate?.transitionTo(state: .SingleClinicDrawer)
                self.delegate?.showDrawerWith(selectedIndex: index, clinics: clinics)
            }
            
        }
        return true
    }
}


