//
//  HomeViewModel.swift
//  animalhelp
//
//  Created by Aamir  on 29/11/17.
//  Copyright © 2017 AamirAnwar. All rights reserved.
//

import Foundation
import Moya
import GoogleMaps


protocol HomeViewModelDelegate {
    func locationServicesDenied() -> Void
    func didUpdate(_ updatedMarker:GMSMarker) -> Void
    func showUserLocation(location:AppLocation)->Void
    func transitionTo(state:HomeViewState)
    func showDrawerWith(clinics:[Clinic],scrollToIndex index:Int)
    func showMarkers(markers:[GMSMarker])
    func zoomIntoNearestClinic()
    func zoomToMarker(_ marker:GMSMarker)
    func showEmptyStateView()
    func hideEmptyStateView()
    func didTapLocationButton()
    func showLoader()
    func hideLoader()
}

class HomeViewModel:NSObject {
    
    let locationManager = animalhelp.LocationManager.sharedManager
    let APIService = animalhelp.APIService.sharedService
    var delegate:HomeViewModelDelegate?
    var nearestClinic:Clinic? {
        get {
            return self.nearbyClinics?.first
        }
    }
    var nearbyClinics:[Clinic]?
    var nearbyClinicsMarkers:[GMSMarker]?
    var userLocationMarker:GMSMarker?
    var nearestClinicMarker:GMSMarker? {
        get {
            return self.nearbyClinicsMarkers?.first
        }
    }
    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(self.didChangeUserLocation), name: kNotificationUserLocationChanged.name, object: nil)
           NotificationCenter.default.addObserver(self, selector: #selector(self.locationPermissionDenied), name: kNotificationLocationPerimissionDenied.name, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.startedDetectingLocation), name: kNotificationDidStartUpdatingLocation.name, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.locationDetectionFailed), name: kNotificationLocationDetectionFailed.name, object: nil)
    }
    
    @objc func startedDetectingLocation() {
        self.delegate?.showLoader()
    }
    
    @objc func locationDetectionFailed() {
        self.delegate?.hideLoader()
    }
    
    @objc func didChangeUserLocation() {
        if let location = self.locationManager.userLocation {
            self.delegate?.hideLoader()
            self.delegate?.hideEmptyStateView()
            self.delegate?.transitionTo(state: .MinimizedDrawer)
            self.getNearbyClinics()
            
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            marker.title = location.name
            marker.icon = GMSMarker.markerImage(with: CustomColorGreen)
            marker.appearAnimation = .pop
            // Clear the previous marker
            userLocationMarker?.map = nil
            userLocationMarker = marker
            
            
            self.delegate?.showUserLocation(location: location)
        }
        else {
            self.delegate?.transitionTo(state: .UserLocationUnknown)
        }
    }
    
    @objc func locationPermissionDenied() {
        self.delegate?.locationServicesDenied()
    }
    
    func updateViewState() {
        if self.locationManager.isLocationPermissionGranted == false {
            self.delegate?.transitionTo(state: .UserLocationUnknown)
        }
        else {
            if self.locationManager.userLocation == nil {
                self.locationManager.startDetectingLocation()
            }
        }
    }
    
    func getNearbyClinics() {
        self.delegate?.showLoader()
        Clinic.getNearbyClinics { (clinics) in
            guard clinics.isEmpty == false else {
                self.delegate?.showEmptyStateView()
                return
            }
            self.nearbyClinics = clinics
            // Remove any previous markers from the map
            if let clinicMarkers = self.nearbyClinicsMarkers {
                clinicMarkers.forEach({ (marker) in
                    marker.map = nil
                })
            }
            self.nearbyClinicsMarkers = clinics.map({ (clinic) -> GMSMarker in
                return self.createMarkerWithClinic(clinic: clinic)
            })
            self.delegate?.hideLoader()
            self.delegate?.hideEmptyStateView()
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
        marker.appearAnimation = .pop
        return marker
    }
}

extension HomeViewModel:DrawerViewDelegate {
    
    func didTapFindNearbyClinics() {
//        self.getNearbyClinics()
    }
    
    func didSwipeToClinicAt(index:Int) {
        if let markers = self.nearbyClinicsMarkers, markers.count > index {
            self.delegate?.zoomToMarker(markers[index])
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
        self.delegate?.didTapLocationButton()
    }
    
    func didTapDetectLocation() {
        //Start detecting location if there is no location
        if self.locationManager.userLocation == nil {
            self.locationManager.startDetectingLocation()
        }
    }
}

extension HomeViewModel:GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if let clinics = self.nearbyClinics, let markers = self.nearbyClinicsMarkers {
            if let index = markers.index(of: marker) {
                self.delegate?.transitionTo(state: .SingleClinicDrawer)
                self.delegate?.showDrawerWith(clinics: clinics, scrollToIndex: index)
            }
        }
        return true
    }
}


