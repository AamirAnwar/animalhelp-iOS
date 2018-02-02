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
    func showUserLocation(location:AppLocation)->Void
    func transitionTo(state:HomeViewState)
    func didRefreshClinics()
    func showDrawerWith(clinics:[Clinic],scrollToIndex index:Int)
    func showMarkers(markers:[GMSMarker])
    func zoomIntoNearestClinic()
    func zoomToMarker(_ marker:GMSMarker)
    func showEmptyStateView()
    func hideEmptyStateView()
    func didTapLocationButton()
    func showLoader()
    func hideLoader()
    func showMiniDrawer(withMessage message:String)
    func zoomToFit(markers:[GMSMarker])
}

class HomeViewModel:NSObject {
    
    let locationManager = animalhelp.LocationManager.sharedManager
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
        self.delegate?.showEmptyStateView()
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
            let iconView = self.createMarkerIconView(withIcon:FAIcon.FAUser,textColor: UIColor.white, backgroundColor:CustomColorMainTheme)
            marker.iconView = iconView
            marker.iconView?.layer.cornerRadius = iconView.width()/2
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
        Clinic.getNearbyClinics { (clinics, error) in
            self.delegate?.hideLoader()
            guard error == nil else {
                self.delegate?.showEmptyStateView()
                UtilityFunctions.showErrorDropdown()
                return
            }
            
            // Remove any previous markers from the map
            if let clinicMarkers = self.nearbyClinicsMarkers {
                clinicMarkers.forEach({ (marker) in
                    marker.map = nil
                })
            }
            // Update data
            self.nearbyClinics = clinics
            self.nearbyClinicsMarkers = clinics.map({ (clinic) -> GMSMarker in
                return self.createMarkerWithClinic(clinic: clinic)
            })
            self.delegate?.didRefreshClinics()
            
            guard clinics.isEmpty == false else {
                let message = "No clinics around you :("
                self.delegate?.showMiniDrawer(withMessage: message)
                return
            }
            
            self.delegate?.hideLoader()
            self.delegate?.hideEmptyStateView()
            self.delegate?.showMarkers(markers:self.nearbyClinicsMarkers!)
            if var markers = self.nearbyClinicsMarkers {
                if let userLocationMarker = self.userLocationMarker {
                    markers.append(userLocationMarker)
                }
                self.delegate?.zoomToFit(markers: markers)
            }
        }
    }

    func createMarkerWithClinic(clinic:Clinic)->GMSMarker {
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: clinic.lat, longitude: clinic.lon)
        marker.title = clinic.name
        marker.snippet = clinic.address
        marker.appearAnimation = .pop
        let iconView = self.createMarkerIconView(withIcon:FAIcon.FAPlus,textColor: CustomColorMainTheme, backgroundColor: UIColor.white, borderColor: CustomColorSeparatorGrey)
        marker.iconView = iconView
        marker.iconView?.layer.cornerRadius = iconView.width()/2
        return marker
    }
    
    func createMarkerIconView(withIcon icon:FAIcon, textColor:UIColor, backgroundColor:UIColor, borderColor:UIColor? = nil)->UIView {
        let iconLabel = UILabel()
        iconLabel.textAlignment = .center
        iconLabel.font = UIFont.init(name: kFontAwesomeFamilyName, size: 19)
        iconLabel.text = NSString.fontAwesomeIconString(forEnum: icon)
        iconLabel.textColor = textColor
        iconLabel.frame.size = CGSize(width: 30, height: 30)
        iconLabel.layer.cornerRadius = 15
        iconLabel.backgroundColor = backgroundColor
        if let borderColor = borderColor {
            iconLabel.layer.borderColor = borderColor.cgColor
            iconLabel.layer.borderWidth = 1
        }
        
        iconLabel.clipsToBounds = true
        return iconLabel
    }
}

extension HomeViewModel:DrawerViewDelegate {
    
    func didTapMiniMessageButton() {
        if self.nearestClinic != nil {
            self.delegate?.transitionTo(state: .SingleClinicDrawer)
        }
    }
    
    func didSwipeToClinicAt(index:Int) {
        if let markers = self.nearbyClinicsMarkers, markers.count > index {
            self.delegate?.zoomToMarker(markers[index])
        }
    }

    func didTapOpenInGoogleMaps(forIndex indexPath: IndexPath) {
        guard let nearbyClinics = self.nearbyClinicsMarkers, indexPath.row < nearbyClinics.count else {return}
        if let clinic = self.nearbyClinics?[indexPath.row] {
            UtilityFunctions.openAddressInGoogleMaps(clinic.address)
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


