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


enum HomeViewState {
    case InitialSetup
    case UserLocationUnknown
    case HiddenDrawer
    case MinimizedDrawer
    case SingleClinicDrawer
    case MaximizedDrawer
}
class HomeViewController: BaseViewController, HomeViewModelDelegate {
  
    let drawerView = DrawerView()
    static let inset:CGFloat = 10
    var drawerViewTopConstraint:ConstraintMakerEditable? = nil
    var mapViewBottomConstraint:ConstraintMakerEditable? = nil
    var state:HomeViewState = .InitialSetup {
        didSet {
            self.refreshDrawerWithState(self.state)
        }
    }
    let myLocationButton:UIButton = {
       let button = UIButton(type: .system)
        button.setTitle("My Location", for: .normal)
        button.titleLabel?.font = CustomFontSmallBodyMedium
        button.setTitleColor(CustomColorTextBlack, for: .normal)
        button.backgroundColor = UIColor.white
        button.layer.cornerRadius = kCornerRadius
        button.contentEdgeInsets = UIEdgeInsetsMake(inset, inset, inset, inset)
        return button
    }()
    
    let showNearestClinicButton:UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Nearest Clinic", for: .normal)
        button.setTitleColor(CustomColorTextBlack, for: .normal)
        button.titleLabel?.font = CustomFontSmallBodyMedium
        button.backgroundColor = UIColor.white
        button.layer.cornerRadius = kCornerRadius
        button.contentEdgeInsets = UIEdgeInsetsMake(inset, inset, inset, inset)
        return button
    }()
    
    var googleMapView:GMSMapView = {
        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
        return GMSMapView.map(withFrame: CGRect.zero, camera: camera)
    }()
    let zoomLevel:Float = 15.0
    var viewModel:HomeViewModel!
    var updateVisibleMapElements = { (homeView:HomeViewController,isHidden:Bool) in
        homeView.googleMapView.isHidden = isHidden
        homeView.myLocationButton.isHidden = isHidden
        homeView.showNearestClinicButton.isHidden = isHidden
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
        self.viewModel.delegate = self
        self.viewModel.updateViewState()
        self.customNavBar.enableRightButtonWithTitle("List")
    }
    
    override func didTapRightBarButton() {
        if self.state == .MaximizedDrawer {
            self.customNavBar.rightBarButton?.setTitle("List", for: .normal)
            self.transitionTo(state:.HiddenDrawer)
        }
        else {
            self.customNavBar.rightBarButton?.setTitle("Map", for: .normal)
            self.transitionTo(state:.MaximizedDrawer)
        }
    }
    
    override func didTapLocationButton() {
        // Open location selection flow
        let vc = SelectLocationViewController()
        present(vc,animated:true)
    }
    
    fileprivate func setupViews() {
        self.createGoogleMapView()
        self.setupMyLocationButton()
        self.setupNearestClinicButton()
        self.setupDrawerView()
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
            make.top.equalTo(myLocationButton.snp.bottom).offset(20)
        }
        self.showNearestClinicButton.addTarget(self, action: #selector(didTapShowNearestClinic), for: .touchUpInside)
    }
    
    
    fileprivate func createGoogleMapView() {
        view.addSubview(googleMapView)
        self.googleMapView.delegate = self.viewModel
        googleMapView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            // Adding some space for the navigation bar shadow
            make.top.equalTo(self.customNavBar.snp.bottom).offset(4)
         self.mapViewBottomConstraint =  make.bottom.equalToSuperview()
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
    
    fileprivate func refreshDrawerWithState(_ state:HomeViewState) {
        if let topConstraint = self.drawerViewTopConstraint?.constraint {
            if state == .MaximizedDrawer {
                topConstraint.activate()
            }
            else if state == .SingleClinicDrawer || state == .UserLocationUnknown {
                topConstraint.deactivate()
            }
        }
        else {
            drawerView.snp.makeConstraints { (make) in
                self.drawerViewTopConstraint = make.top.equalToSuperview().offset(CustomNavigationBar.kCustomNavBarHeight + 4)
            }
            self.refreshDrawerWithState(state)
            return
        }
        
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    func didUpdate(_ updatedMarker:GMSMarker) -> Void {
        updatedMarker.map = self.googleMapView
        showNearestClinic(withMarker: updatedMarker)
    }
    
    func zoomIntoNearestClinic() {
        self.showNearestClinic(withMarker: self.viewModel.nearestClinicMarker)
    }
    
    func showNearestClinic(withMarker clinicMarker: GMSMarker?) {
        if let marker = clinicMarker {
            let bounds = GMSCoordinateBounds(coordinate: marker.position, coordinate: googleMapView.myLocation!.coordinate)
            
            let camera = googleMapView.camera(for: bounds , insets: UIEdgeInsetsMake(50 + self.tabBarHeight, 0, 50 + self.tabBarHeight, 0))!
            googleMapView.camera = camera
        }
        else {
            self.viewModel.getNearbyClinics()
        }
    }
    
    func showMarkers(markers:[GMSMarker]) {
        for marker in markers {
            marker.map = self.googleMapView
        }
    }
    
    func showDrawerWith(clinic: Clinic) {
        //TODO
//        self.drawerView.showClinic(clinic: clinic)
    }
    
    func showDrawerWith(selectedIndex:Int, clinics:[Clinic]) {
        // TODO fix parameter ordering
        self.drawerView.showClinics(clinics, selectedIndex: selectedIndex)
    }
    

    func showUserLocation(location:CLLocation) {
        // update current location
        if let locality = LocationManager.sharedManager.userLocality {
            self.customNavBar.setTitle(locality)
        }
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                              longitude: location.coordinate.longitude,
                                              zoom: zoomLevel)
        googleMapView.isMyLocationEnabled = true
        googleMapView.animate(to: camera)
    }
    
    func zoomToMarker(_ marker:GMSMarker) {
        let camera = GMSCameraPosition.camera(withLatitude: marker.position.latitude,
                                              longitude: marker.position.longitude,
                                              zoom: zoomLevel)
        googleMapView.animate(to: camera)
    }
    
    func locationServicesDenied() {
        self.showLocationServicesDeniedAlert()
    }
    
    func showLastKnownUserLocation() {
        if let location = LocationManager.sharedManager.userLocation {
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

    func transitionTo(state:HomeViewState) {
        guard self.state != state else {
            return
        }
        switch state {
        case .UserLocationUnknown:
            self.updateVisibleMapElements(self,true)
            self.drawerView.showUnknownLocationState()
            self.mapViewBottomConstraint?.constraint.update(inset: 0)
            
        case .HiddenDrawer:
            UIView.animate(withDuration: 0.3, animations: {
                self.drawerView.transform.translatedBy(x: 0, y: self.view.frame.size.height)
            }, completion: { (_) in
                self.drawerView.isHidden = true
                self.drawerView.transform = .identity
                self.mapViewBottomConstraint?.constraint.update(inset: 0)
            })
            
            
        case .MinimizedDrawer:
            self.updateVisibleMapElements(self,false)
            //Tell drawer to minimize itself with a message
            
        case .SingleClinicDrawer:
            //Tell drawer to show nearest clinic only with left to right swipeable inteface
            // Must have a non-nil nearest clinic
            if let clinics = self.viewModel.nearbyClinics, let markers = self.viewModel.nearbyClinicsMarkers, clinics.isEmpty == false && markers.isEmpty == false {
                self.updateVisibleMapElements(self,false)
                self.drawerView.switchToSingleDrawer()
                self.drawerView.showClinics(clinics)
                let updatedInset = kCollectionViewHeight + self.tabBarHeight
                self.mapViewBottomConstraint?.constraint.update(inset: updatedInset)
                self.drawerView.isHidden = false
            }
            
            
        case .MaximizedDrawer:
            //Tell drawer to expand to cover it's superview and show all clinics like a list view
            self.updateVisibleMapElements(self,false)
            self.drawerView.switchToMaximizedDrawer()
            self.drawerView.isHidden = false
            
            
        case .InitialSetup:
            print("Drawer view still in initial setup")
//            Do Nothing
        }
        
        self.state = state
    }
        
}
