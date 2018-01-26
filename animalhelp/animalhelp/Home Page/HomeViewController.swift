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
class HomeViewController: BaseViewController, HomeViewModelDelegate, DrawerViewUIDelegate {
    
    static let inset:CGFloat = 10
    var totalPan:CGFloat = 0
    var delta:CGFloat = 0
    let drawerView = DrawerView()
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
    
    var maxStateHeight:CGFloat {
        get {
            return self.view.height() - self.customNavBar.height() - self.tabBarHeight
        }
    }
    
    var maxStateY:CGFloat {
        get {
            return self.view.originY() + self.customNavBar.height()
        }
    }
    
    var singleClinicStateY:CGFloat {
        get {
            return self.view.height() - (self.tabBarHeight + kSingleClinicStateHeight)
        }
    }
    
    var singleClinicStateHeight:CGFloat {
        get {
            return kSingleClinicStateHeight
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
        self.viewModel.delegate = self
        self.viewModel.updateViewState()
    }
    
    fileprivate func setupViews() {
        self.createGoogleMapView()
        self.setupMyLocationButton()
        self.setupNearestClinicButton()
        self.setupDrawerView()
    }
    
    fileprivate func setupDrawerView() {
        self.view.addSubview(self.drawerView)
        self.drawerView.frame = CGRect.init(x: 0, y: self.view.height(), width: self.view.width(), height: kDrawerMinimizedStateHeight)
        // Set delegate
        self.drawerView.delegate = self.viewModel
        self.drawerView.uiDelegate = self
        
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
            make.top.equalTo(self.customNavBar.snp.bottom)
         self.mapViewBottomConstraint =  make.bottom.equalToSuperview()
        }
    }
    
    override func didTapEmptyStateButton() {
        self.didTapLocationButton()
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
    
    func zoomIntoNearestClinic() {
        self.customNavBar.enableRightButtonWithIcon(icon: FAIcon.FAList)
        self.showNearestClinic(withMarker: self.viewModel.nearestClinicMarker)
    }
    
    func showNearestClinic(withMarker clinicMarker: GMSMarker?) {
        if let marker = clinicMarker {
            let bounds = GMSCoordinateBounds(coordinate: marker.position, coordinate: googleMapView.myLocation!.coordinate)
            
            let camera = googleMapView.camera(for: bounds , insets: UIEdgeInsetsMake(50 + self.tabBarHeight, 0, 50 + self.tabBarHeight, 0))!
            googleMapView.camera = camera
        }
    }
    
    func showMarkers(markers:[GMSMarker]) {
        for marker in markers {
            marker.map = self.googleMapView
        }
    }
    
    func showDrawerWith(selectedIndex:Int, clinics:[Clinic]) {
        // TODO fix parameter ordering
        self.drawerView.showClinics(clinics, selectedIndex: selectedIndex)
    }
    

    func showUserLocation(location:CLLocation) {
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                              longitude: location.coordinate.longitude,
                                              zoom: zoomLevel)
        googleMapView.isMyLocationEnabled = true
        googleMapView.animate(to: camera)
        if let clinics = self.viewModel.nearbyClinics, clinics.isEmpty == false {
            
        }
        else {
            self.transitionTo(state: .MinimizedDrawer)
        }
        
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
    
    
    fileprivate func refreshDrawerWithState(_ state:HomeViewState) {
        switch self.state {
        case .InitialSetup:break;
        case .UserLocationUnknown:
            UIView.animate(withDuration: 0.3, animations: {
                self.drawerView.setY(self.view.height() - (self.tabBarHeight + kDrawerUnknownLocationHeight))
                self.drawerView.setHeight(kDrawerUnknownLocationHeight)
            })
        case .HiddenDrawer:
            UIView.animate(withDuration: 0.3, animations: {
                self.drawerView.setY(self.view.height())
            })
        case .MinimizedDrawer:
            self.drawerView.setY(self.view.height())
            UIView.animate(withDuration: 0.3, animations: {
                self.drawerView.setY(self.view.height() - (self.tabBarHeight + kDrawerMinimizedStateHeight))
            })
            
        case .SingleClinicDrawer:
            if self.drawerView.originY() >= self.maxStateY {
                UIView.animate(withDuration: 0.3, animations: {
                    self.drawerView.setY(self.view.height() - (self.tabBarHeight + kSingleClinicStateHeight))
                    self.drawerView.setHeight(kSingleClinicStateHeight)
                })
            }
            else {
                UIView.animate(withDuration: 0.3, animations: {
                    self.drawerView.setY(self.view.height())
                }, completion: { (_) in
//                    self.drawerView.setHeight(kSingleClinicStateHeight)
                    UIView.animate(withDuration: 1, animations: {
                        self.drawerView.setY(self.view.height() - (self.tabBarHeight + kSingleClinicStateHeight))
                    })
                })
            }
            
        case .MaximizedDrawer:
            UIView.animate(withDuration: 0.3, delay: 0.0, options: [.curveEaseOut], animations: {
                self.drawerView.setY(self.view.originY() + self.customNavBar.height())
                self.drawerView.setHeight(self.view.height() - self.customNavBar.height() - self.tabBarHeight)
            }, completion: nil)
        }
    }
    
    func transitionTo(state:HomeViewState) {
        guard self.state != state else {
            return
        }
        switch state {
        case .UserLocationUnknown:
            self.updateVisibleMapElements(self,true)
            self.drawerView.showUnknownLocationState()
//            self.mapViewBottomConstraint?.constraint.update(inset: 0)
            
        case .HiddenDrawer:
            self.updateVisibleMapElements(self,false)
//            self.mapViewBottomConstraint?.constraint.update(inset: 0)
            
            
        case .MinimizedDrawer:
            //Tell drawer to minimize itself with a message
            self.updateVisibleMapElements(self,false)
            self.drawerView.isHidden = false
            let updatedInset = kDrawerMinimizedStateHeight + self.tabBarHeight
//            self.mapViewBottomConstraint?.constraint.update(inset: updatedInset)
            self.drawerView.switchToMinimizedDrawer(title: "Finding clinics around you")
            
            
        case .SingleClinicDrawer:
            //Tell drawer to show nearest clinic only with a left to right swipeable inteface
            if let clinics = self.viewModel.nearbyClinics, let markers = self.viewModel.nearbyClinicsMarkers, clinics.isEmpty == false && markers.isEmpty == false {
                self.updateVisibleMapElements(self,false)
                self.drawerView.switchToSingleDrawer()
                self.drawerView.showClinics(clinics)
                let updatedInset = kSingleClinicStateHeight + self.tabBarHeight
//                self.mapViewBottomConstraint?.constraint.update(inset: updatedInset)
                self.drawerView.isHidden = false
            }
            
            
        case .MaximizedDrawer:
            //Tell drawer to expand to cover it's superview and show all clinics like a list view
            self.updateVisibleMapElements(self,false)
            self.drawerView.switchToMaximizedDrawer()
            self.drawerView.isHidden = false
            
            
        case .InitialSetup:
            self.drawerView.isHidden = true
            print("Drawer view still in initial setup")
//            Do Nothing
        }
        self.state = state
    }
    
    override func didTapRightBarButton() {
        if self.state == .MaximizedDrawer {
            self.customNavBar.setRightButtonIcon(icon:FAIcon.FAList)
            self.transitionTo(state:.HiddenDrawer)
        }
        else {
            self.customNavBar.setRightButtonIcon(icon:FAIcon.FAmap)
            self.transitionTo(state:.MaximizedDrawer)
        }
    }
    
    override func didTapLocationButton() {
        // Open location selection flow
        let vc = SelectLocationViewController()
        present(vc,animated:true)
    }
    
    func didTapHideDrawerButton() {
        self.transitionTo(state: .HiddenDrawer)
    }
    
    func didPan(drawer:DrawerView, panGesture:UIPanGestureRecognizer) {
        print(panGesture.translation(in: drawer))
        let y = panGesture.translation(in: drawer).y
        switch panGesture.state {
        case .began :
            totalPan = 0
            delta = 0
        case .changed :
            delta = y - totalPan
            print("Delta : \(delta)")
            totalPan = y
            updateDrawerWithDelta(delta)
            
        case .cancelled,.ended:
            self.updateDrawerWithTotalDrag(drag: totalPan)
        default:
            print("ended")
        }
        
    }
    
    func didScrollDownWithDelta(_ delta:CGFloat) {
        self.updateDrawerWithDelta(-delta)
    }
    
    func didEndDragging(WithTotalDrag drag:CGFloat) {
        self.updateDrawerWithTotalDrag(drag: drag)
    }
    
    func updateDrawerWithTotalDrag(drag:CGFloat) {
        guard drag <= 0 else {return}
        
        if drag < -200 {
            self.drawerView.flowLayout.scrollDirection = .vertical
            self.transitionTo(state: .MaximizedDrawer)
            print("Maximize!")
        }
        else {
            
            UIView.animate(withDuration: 0.3, animations: {
                self.drawerView.setY(self.view.height() - (self.tabBarHeight + kSingleClinicStateHeight))
                self.drawerView.setHeight(kSingleClinicStateHeight)
            }, completion: { (_) in
                self.drawerView.flowLayout.scrollDirection = .horizontal
                self.transitionTo(state: .SingleClinicDrawer)
            })
            print("Minimize!")
        }
    }
    
    func updateDrawerWithDelta(_ delta:CGFloat) {
        let y = self.drawerView.originY()
        let height = self.drawerView.height()
        
        let updatedHeight = height - delta
        let updatedY = y + delta
        
        var finalHeight = updatedHeight
        var finalY = updatedY
        
        if finalHeight > self.maxStateHeight {
            finalHeight = self.maxStateHeight
        }
        if finalHeight < self.singleClinicStateHeight {
            finalHeight = self.singleClinicStateHeight
        }
        
        if finalY < self.maxStateY {
           finalY = self.maxStateY
        }
        
        if finalY > self.singleClinicStateY {
            finalY = self.singleClinicStateY
        }
//        print("\(finalY) - \(finalHeight)")
        
        if finalY < self.singleClinicStateY {
            self.drawerView.flowLayout.scrollDirection = .vertical
        }
        else {
            self.drawerView.flowLayout.scrollDirection = .horizontal
        }
        
        self.drawerView.setY(finalY)
        self.drawerView.setHeight(finalHeight)

    }
    
    
        
}

