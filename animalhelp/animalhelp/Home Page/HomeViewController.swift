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
    lazy var appleMapView = MKMapView()
    var nearestClinicMarker:GMSMarker?
    
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
        self.createGoogleMapView()
        self.setupMyLocationButton()
        self.setupNearestClinicButton()
        self.setupDrawerView()
        self.viewModel.delegate = self
        self.viewModel.startDetectingLocation()
    }
    
    fileprivate func setupDrawerView() {
        self.view.addSubview(self.drawerView)
        drawerView.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-44)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            
//            make.height.equalTo(self.view.snp.height).multipliedBy(0.4)
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
    
    
    
    fileprivate func createAppleMapsView() {
        view.addSubview(appleMapView)
        appleMapView.delegate = self
        appleMapView.showsUserLocation = true
        appleMapView.snp.makeConstraints { (make) in
            make.top.equalTo(self.navigationController!.navigationBar.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    fileprivate func createGoogleMapView() {
        view.addSubview(googleMapView)
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
    
    func updateMarkerWith(NearestClinic nearestClinic:NearestClinic) {
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: nearestClinic.clinic.lat, longitude: nearestClinic.clinic.lon)
        marker.title = nearestClinic.clinic.name
        marker.snippet = nearestClinic.clinic.address
        marker.map = self.googleMapView
        self.nearestClinicMarker = marker
    }
    
    func didUpdate(_ nearestClinic:NearestClinic) -> Void {
        updateMarkerWith(NearestClinic: nearestClinic)
        showNearestClinic(withMarker: self.nearestClinicMarker)
    }
    
    func showNearestClinic(withMarker clinicMarker: GMSMarker?) {
        if let marker = clinicMarker {
            let bounds = GMSCoordinateBounds(coordinate: marker.position, coordinate: googleMapView.myLocation!.coordinate)
            let camera = googleMapView.camera(for: bounds , insets: UIEdgeInsetsMake(50, 0, 50, 0))!
            googleMapView.camera = camera
        }
    }
    

    func showUserLocation(location:CLLocation) {
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
        self.showNearestClinic(withMarker: self.nearestClinicMarker)
    }
    
    func createBlurredMapImage()->UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, true, 1)
        self.googleMapView.drawHierarchy(in: self.view.bounds, afterScreenUpdates: true)
        let screenshot = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        let blurredImage = screenshot.applyBlur(withRadius: 7, tintColor: UIColor.white.withAlphaComponent(0.3), saturationDeltaFactor: 1.8, maskImage: nil)
        return blurredImage
        
//        let imageView = UIImageView(image: blurredImage)
//        imageView.frame = self.view.bounds
//        self.view.insertSubview(imageView, belowSubview: self.drawerView)
    }

}

extension HomeViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        appleMapView.showAnnotations([userLocation], animated: true)
    }
}

