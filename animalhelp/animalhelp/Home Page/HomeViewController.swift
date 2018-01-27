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

let kMapButtonSize:CGFloat = 44
let kMapButtonFontSize:CGFloat = 22

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
    var state:HomeViewState = .InitialSetup {
        didSet {
            self.refreshDrawerWithState(self.state)
        }
    }
    let myLocationButton:UIButton = {
       let button = UIButton(type: .system)
        
        button.setTitle(NSString.fontAwesomeIconString(forEnum: FAIcon.FACrosshairs), for: .normal)
        button.titleLabel?.font = UIFont.init(name: kFontAwesomeFamilyName, size: kMapButtonFontSize)
        button.setTitleColor(CustomColorTextBlack, for: .normal)
        button.backgroundColor = UIColor.white
        button.layer.cornerRadius = kCornerRadius
        button.contentEdgeInsets = UIEdgeInsetsMake(inset, inset, inset, inset)
        button.layer.borderColor = CustomColorSeparatorGrey.cgColor
        button.layer.borderWidth = 1
        return button
    }()
    
    let showNearestClinicButton:UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSString.fontAwesomeIconString(forEnum: FAIcon.FAMapMarker), for: .normal)
        button.titleLabel?.font = UIFont.init(name: kFontAwesomeFamilyName, size: kMapButtonFontSize)
        button.setTitleColor(CustomColorTextBlack, for: .normal)
        button.layer.borderColor = CustomColorSeparatorGrey.cgColor
        button.layer.borderWidth = 1
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
        if self.viewModel.locationManager.isLocationPermissionGranted {
            self.customNavBar.setTitle("Detecting Location")
        }
        else {
            self.customNavBar.setTitle("Set Location")
        }
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
            make.size.equalTo(kMapButtonSize)
        }
        myLocationButton.addTarget(self, action: #selector(didTapMyLocationButton), for: .touchUpInside)
    }
    
    fileprivate func setupNearestClinicButton() {
        view.addSubview(self.showNearestClinicButton)
        self.showNearestClinicButton.snp.makeConstraints { (make) in
            make.trailing.equalTo(myLocationButton.snp.trailing)
            make.top.equalTo(myLocationButton.snp.bottom).offset(20)
            make.size.equalTo(kMapButtonSize)
        }
        self.showNearestClinicButton.addTarget(self, action: #selector(didTapShowNearestClinic), for: .touchUpInside)
    }
    
    
    fileprivate func createGoogleMapView() {
        view.addSubview(googleMapView)
        self.googleMapView.delegate = self.viewModel
        self.googleMapView.frame = CGRect.init(x: 0.0, y: CustomNavigationBar.kCustomNavBarHeight, width: self.view.width(), height: self.view.height() - (self.customNavBar.height() + self.tabBarHeight))
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
        if let userLocation = self.viewModel.locationManager.userLocation,let marker = clinicMarker {
            self.refreshUserMarker()
            let userLocationCoordinate = CLLocationCoordinate2D.init(latitude: userLocation.latitude, longitude: userLocation.longitude)
            let bounds = GMSCoordinateBounds(coordinate: marker.position, coordinate: userLocationCoordinate)
            let inset = 50 + self.tabBarHeight
            let camera = googleMapView.camera(for: bounds , insets: UIEdgeInsetsMake(inset, inset, inset, inset))!
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
    

    func showUserLocation(location:AppLocation) {
        let camera = GMSCameraPosition.camera(withLatitude: location.latitude,
                                              longitude: location.longitude,
                                              zoom: zoomLevel)
        googleMapView.animate(to: camera)
        if let clinics = self.viewModel.nearbyClinics, clinics.isEmpty == false {
            self.refreshUserMarker()
        }
        else {
            self.transitionTo(state: .MinimizedDrawer)
        }
        
    }
    
    func refreshUserMarker() {
        if let userMarker = self.viewModel.userLocationMarker {
            userMarker.map = googleMapView
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
    
    override func locationChanged() {
        UtilityFunctions.setUserLocationInNavBar(customNavBar: self.customNavBar)
    }
    
    
    fileprivate func refreshDrawerWithState(_ state:HomeViewState) {
        switch self.state {
        case .InitialSetup:break;
        case .UserLocationUnknown:
//            UIView.animate(withDuration: 0.3, animations: {
                self.drawerView.setY(CustomNavigationBar.kCustomNavBarHeight)
                self.drawerView.setHeight(self.view.height() - (CustomNavigationBar.kCustomNavBarHeight + self.tabBarHeight))
            self.drawerView.layoutIfNeeded()
//            })
        case .HiddenDrawer:
            UIView.animate(withDuration: 0.3, animations: {
                self.drawerView.setY(self.view.height())
            })
        case .MinimizedDrawer:
            self.drawerView.setY(self.view.height())
            self.drawerView.setHeight(kDrawerMinimizedStateHeight)
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
        print("Going from state \(self.state) to \(state)")
        
        switch state {
        case .UserLocationUnknown:
            self.updateVisibleMapElements(self,true)
            self.drawerView.showUnknownLocationState()
            UIView.animate(withDuration: 0.3, animations: {
                self.googleMapView.setHeight(self.view.height() - (self.tabBarHeight + self.customNavBar.height()))
            })
            
        case .HiddenDrawer:
            self.updateVisibleMapElements(self,false)
            UIView.animate(withDuration: 0.3, animations: {
                self.googleMapView.setHeight(self.view.height() - (self.tabBarHeight + self.customNavBar.height()))
            })
            
            
        case .MinimizedDrawer:
            //Tell drawer to minimize itself with a message
            self.updateVisibleMapElements(self,false)
            self.drawerView.isHidden = false
            UIView.animate(withDuration: 0.2, animations: {
            self.googleMapView.setHeight(self.view.height() - (self.tabBarHeight + self.customNavBar.height() + kDrawerMinimizedStateHeight))
            })
            self.drawerView.switchToMinimizedDrawer(title: "Finding clinics around you")
            
            
        case .SingleClinicDrawer:
            //Tell drawer to show nearest clinic only with a left to right swipeable inteface
            if let clinics = self.viewModel.nearbyClinics, let markers = self.viewModel.nearbyClinicsMarkers, clinics.isEmpty == false && markers.isEmpty == false {
                let closure:()->Void = {
                    self.updateVisibleMapElements(self,false)
                    self.drawerView.switchToSingleDrawer()
                    self.drawerView.showClinics(clinics)
                    self.drawerView.isHidden = false
                    self.state = state
                }
                
                if self.state == .MinimizedDrawer {
                    UIView.animate(withDuration: 0.3, animations: {
                        self.googleMapView.setHeight(self.view.height() - (self.tabBarHeight + CustomNavigationBar.kCustomNavBarHeight))})
                    UIView.animate(withDuration: 0.5, animations: {
                        self.drawerView.setY(self.view.height())
                        
                    }, completion: { (_) in
                        closure()
                        UIView.animate(withDuration: 0.3, delay: 0.3, options: [.curveEaseOut], animations: {
                            self.googleMapView.setHeight(self.view.height() - (self.tabBarHeight + CustomNavigationBar.kCustomNavBarHeight + kSingleClinicStateHeight))
                        }, completion: nil)
                    })
                    return
                }
                else {
                    closure()
                    UIView.animate(withDuration: 0.3, animations: {
                        self.googleMapView.setHeight(self.view.height() - (self.tabBarHeight + self.customNavBar.height() + kSingleClinicStateHeight))
                    })
                }
            }
            
            
        case .MaximizedDrawer:
            //Tell drawer to expand to cover it's superview and show all clinics like a list view
            self.updateVisibleMapElements(self,false)
            self.drawerView.switchToMaximizedDrawer()
            self.drawerView.isHidden = false
            
            
        case .InitialSetup:
            self.drawerView.isHidden = true
            print("Drawer view still in initial setup")
            UIView.animate(withDuration: 0.1, animations: {
                self.googleMapView.setHeight(self.view.height() - (self.tabBarHeight + self.customNavBar.height()))
            })
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

