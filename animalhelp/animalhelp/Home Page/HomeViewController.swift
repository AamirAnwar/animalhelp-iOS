//
//  HomeViewController.swift
//  animalhelp
//
//  Created by Aamir  on 15/11/17.
//  Copyright © 2017 AamirAnwar. All rights reserved.
//

import UIKit
import SnapKit
import CoreLocation
import MapKit
import GoogleMaps
import Moya

class HomeViewController: BaseViewController, HomeViewModelDelegate {
  
    let drawerView = DrawerView()
    var drawerViewTopConstraint:ConstraintMakerEditable? = nil
    let myLocationButton:UIButton = {
       let button = UIButton(type: .system)
        button.setTitle("My Location", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = UIColor.red
        return button
    }()
    
    let showNearestClinicButton:UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Nearest Clinic", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = UIColor.red
        return button
    }()
    
    var googleMapView:GMSMapView = {
        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
        return GMSMapView.map(withFrame: CGRect.zero, camera: camera)
    }()
    let zoomLevel:Float = 15
    var viewModel:HomeViewModel!
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Init with coder not implemented")
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.tabBarItem.title = "Clinics"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.navigationItem.title = "Your Location"
        self.viewModel.delegate = self
        self.setupViewsIfNeeded()
        self.setupDrawerView()
        
    }
    
    fileprivate func setupViewsIfNeeded() {
        guard self.viewModel.isLocationPermissionGranted else {
            return
        }
        
        self.createGoogleMapView()
        self.setupMyLocationButton()
        self.setupNearestClinicButton()
        self.viewModel.startDetectingLocation()
    }
    
    fileprivate func setupDrawerView() {
        self.view.addSubview(self.drawerView)
        drawerView.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-44)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        // Set delegate
        self.drawerView.delegate = self.viewModel
        if self.viewModel.isLocationPermissionGranted {
            self.drawerView.isHidden = true
        }
        
    }
    
    func expandDrawerView() {
        if self.drawerViewTopConstraint == nil {
            drawerView.snp.makeConstraints { (make) in
                self.drawerViewTopConstraint = make.top.equalToSuperview().offset(40)
            }
        }
        else {
            if let isActive = self.drawerViewTopConstraint?.constraint.isActive {
                if isActive {
                    self.drawerViewTopConstraint?.constraint.deactivate()
                }
                else {
                    self.drawerViewTopConstraint?.constraint.activate()
                }
            }
        }
        
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
 
    }
    
    fileprivate func setupMyLocationButton() {
        view.addSubview(self.myLocationButton)
        myLocationButton.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().offset(-20)
            make.top.equalTo(self.view.snp.top).offset(100)
        }
        myLocationButton.addTarget(self, action: #selector(didTapMyLocationButton), for: .touchUpInside)
    }
    
    fileprivate func setupNearestClinicButton() {
        view.addSubview(self.showNearestClinicButton)
        self.showNearestClinicButton.snp.makeConstraints { (make) in
            make.trailing.equalTo(myLocationButton.snp.trailing)
            make.top.equalTo(myLocationButton.snp.bottom).offset(50)
        }
        
        self.showNearestClinicButton.addTarget(self, action: #selector(didTapShowNearestClinic), for: .touchUpInside)
    }
    
    
    fileprivate func createGoogleMapView() {
        view.addSubview(googleMapView)
        self.googleMapView.delegate = self.viewModel
        googleMapView.isMyLocationEnabled = true
        googleMapView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    func showLocationServicesDeniedAlert() {
        let alert = UIAlertController(
            title: "Location Services Disabled",
            message: "Please enable location services for this app in Settings.",
            preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        present(alert, animated: true, completion: nil)
        alert.addAction(okAction)
    }
    
    func didUpdate(_ updatedMarker:GMSMarker) -> Void {
        updatedMarker.map = self.googleMapView
        showNearestClinic(withMarker: updatedMarker)
    }
    
    func showNearestClinic(withMarker clinicMarker: GMSMarker?) {
        if let marker = clinicMarker {
            let bounds = GMSCoordinateBounds(coordinate: marker.position, coordinate: googleMapView.myLocation!.coordinate)
            
            let camera = googleMapView.camera(for: bounds , insets: UIEdgeInsetsMake(50 + self.tabBarHeight, 0, 50 + self.tabBarHeight, 0))!
            googleMapView.camera = camera
        }
    }
    
    func showDrawerWith(clinic: NearestClinic) {
        self.showDrawer()
        self.drawerView.showClinic(clinic: clinic)
    }
    

    func showUserLocation(location:CLLocation) {
        
        self.setupViewsIfNeeded()
        
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                              longitude: location.coordinate.longitude,
                                              zoom: zoomLevel)
        googleMapView.animate(to: camera)
        
        
    }
    
    func locationServicesDenied() {
        self.showLocationServicesDeniedAlert()
    }
    
    func showLastKnownUserLocation() {
        if let location = self.viewModel.detectedLocation {
            self.showUserLocation(location: location)
        }
    }
    
    @objc func didTapMyLocationButton() {
        self.showLastKnownUserLocation()
    }
    
    @objc func didTapShowNearestClinic() {
        self.showNearestClinic(withMarker: self.viewModel.nearestClinicMarker)
    }
    
    func createBlurredMapImage()->UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, true, 1)
        self.googleMapView.drawHierarchy(in: self.view.bounds, afterScreenUpdates: true)
        let screenshot = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        let blurredImage = screenshot.applyBlur(withRadius: 7, tintColor: UIColor.white.withAlphaComponent(0.3), saturationDeltaFactor: 1.8, maskImage: nil)
        return blurredImage
    }

    func showDrawer() {
        self.view.bringSubview(toFront: self.drawerView)
        self.drawerView.isHidden = false
    }
    
    func hideDrawer() {
        self.drawerView.isHidden = true
    }
    
    
}

