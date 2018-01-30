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

public enum HomeViewState:Int {
    case InitialSetup
    case UserLocationUnknown
    case HiddenDrawer
    case MinimizedDrawer
    case SingleClinicDrawer
    case MaximizedDrawer
}

class HomeViewController: BaseViewController, HomeViewModelDelegate, DrawerViewUIDelegate {
    
    static let inset:CGFloat = 10
    var isTransitioning = false
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
    
    let hideButton:UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = UIFont.init(name: kFontAwesomeFamilyName, size: 14)
        button.setTitle(NSString.fontAwesomeIconString(forEnum: FAIcon.FAChevronDown), for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = CustomColorMainTheme
        button.contentEdgeInsets = UIEdgeInsetsMake(0, 3, 0, 3)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.viewModel.locationManager.isLocationPermissionGranted {
            self.customNavBar.setTitle(kStringDetecingLocation)
        }
        else {
            self.customNavBar.setTitle(kStringSetLocation)
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
        self.createHideButton()
    }
    
    fileprivate func createHideButton() {
        self.view.addSubview(self.hideButton)
        self.hideButton.layer.cornerRadius = ceil(kHideButtonSize/2)
        self.hideButton.addTarget(self, action: #selector(didTapHideDrawerButton), for: .touchUpInside)
        self.hideButton.frame = CGRect.init(x: view.width() - kDefaultPadding - kHideButtonSize, y: self.drawerView.originY() - kDefaultPadding, width: kHideButtonSize, height: kHideButtonSize)
    }
    
    fileprivate func createGoogleMapView() {
        view.addSubview(googleMapView)
        self.googleMapView.delegate = self.viewModel
        self.googleMapView.frame = CGRect.init(x: 0.0, y: CustomNavigationBar.kCustomNavBarHeight, width: self.view.width(), height: self.view.height() - (self.customNavBar.height() + self.tabBarHeight))
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

    func showLocationServicesDeniedAlert() {
        let alert = UIAlertController(
            title: "Location Services Disabled",
            message: "Please enable location services for this app in Settings.",
            preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        present(alert, animated: true, completion: nil)
        alert.addAction(okAction)
    }
    
    func didRefreshClinics() {
        if self.state == .HiddenDrawer || self.state == .MinimizedDrawer {
            self.showNearestClinicInMinimizedState()
        }
    }
    
    func showNearestClinicInMinimizedState() {
        if let nearestClinic = self.viewModel.nearestClinic {
            // Show message with nearest clinic name
            self.showMiniDrawer(withMessage:"Nearest Clinic - \(nearestClinic.name)")
        }
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
    
    func showDrawerWith(clinics:[Clinic],scrollToIndex index:Int) {
        self.drawerView.showClinics(clinics, scrollToIndex: index)
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
            self.showMiniDrawer(withMessage: kStringFindingLocation)
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
    
    
    override func didTapEmptyStateButton() {
        self.viewModel.getNearbyClinics()
        self.hideEmptyStateView()
        self.showLoader()
    }
    
    
    fileprivate func refreshDrawerWithState(_ state:HomeViewState) {
        switch self.state {
        case .InitialSetup:break;
        case .UserLocationUnknown:
            self.drawerView.setY(CustomNavigationBar.kCustomNavBarHeight)
            self.drawerView.setHeight(self.view.height() - (CustomNavigationBar.kCustomNavBarHeight + self.tabBarHeight))
            self.drawerView.layoutIfNeeded()

        case .HiddenDrawer:
            UIView.animate(withDuration: 0.3, animations: {
                self.drawerView.setY(self.view.height())
            })
        case .MinimizedDrawer:
            guard self.drawerView.originY() != (self.view.height() - (self.tabBarHeight + kDrawerMinimizedStateHeight)) else {return}
            self.drawerView.setY(self.view.height())
            self.drawerView.setHeight(kDrawerMinimizedStateHeight)
            UIView.animate(withDuration: 0.3, animations: {
                self.drawerView.setY(self.view.height() - (self.tabBarHeight + kDrawerMinimizedStateHeight))
            })
            
        case .SingleClinicDrawer:
            if self.drawerView.originY() >= self.maxStateY {
                UIView.animate(withDuration: 0.3, animations: {
                    self.drawerView.setY(self.view.height() - (self.tabBarHeight + kSingleClinicStateHeight))
                    self.updateHideButtonOriginY()
                    self.drawerView.setHeight(kSingleClinicStateHeight)
                }, completion:{ (_) in
                    self.setHideButtonVisibility(true, delay: 0.1)
                })
            }
            else {
                UIView.animate(withDuration: 0.3, animations: {
                    self.drawerView.setY(self.view.height())
                }, completion: { (_) in
                    UIView.animate(withDuration: 1, animations: {
                        self.drawerView.setY(self.view.height() - (self.tabBarHeight + kSingleClinicStateHeight))
                        self.updateHideButtonOriginY()
                    }, completion:{(_) in
                        self.setHideButtonVisibility(true, delay: 0.1)
                    })
                })
            }
            
        case .MaximizedDrawer:
            UIView.animate(withDuration: 0.2, delay: 0.0, options: [], animations: {
                self.drawerView.setY(self.view.originY() + self.customNavBar.height())
                self.drawerView.setHeight(self.view.height() - self.customNavBar.height() - self.tabBarHeight)
            }, completion: nil)
        }
    }
    
    func transitionTo(state:HomeViewState) {
        guard isTransitioning == false else {return}
        self.isTransitioning = true
        guard self.state != state else {
            self.isTransitioning = false
            return
        }
        switch state {
        case .UserLocationUnknown:
            self.updateVisibleMapElements(self,true)
            self.present(OnboardingViewController(), animated: true)
            UIView.animate(withDuration: 0.3, animations: {
                self.googleMapView.setHeight(self.view.height() - (self.tabBarHeight + self.customNavBar.height()))
            })
            
        case .HiddenDrawer:
            self.updateVisibleMapElements(self,false)
            UIView.animate(withDuration: 0.3, animations: {
                self.googleMapView.setHeight(self.view.height() - (self.tabBarHeight + self.customNavBar.height()))
            })
            
            
        case .MinimizedDrawer:
            // Default
            self.showMiniDrawer(withMessage: kStringFindingLocation)
            self.isTransitioning = false
            return
        
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
                
                switch self.state {
                case .MinimizedDrawer:
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
                    self.isTransitioning = false
                    return
                    
                default:
                    closure()
                    self.setHideButtonVisibility(true, delay:0.1)
                    UIView.animate(withDuration: 0.3, animations: {
                        self.googleMapView.setHeight(self.view.height() - (self.tabBarHeight + self.customNavBar.height() + kSingleClinicStateHeight))
                    })
                }
            }
            
            
        case .MaximizedDrawer:
            //Tell drawer to expand to cover it's superview and show all clinics like a list view
            guard let clinics = self.viewModel.nearbyClinics else {return}
            self.updateVisibleMapElements(self,false)
            self.drawerView.showClinics(clinics)
            self.drawerView.switchToMaximizedDrawer()
            self.drawerView.isHidden = false
            self.setHideButtonVisibility(false, delay: 0.1)
            
            
        case .InitialSetup:
            self.drawerView.isHidden = true
            UIView.animate(withDuration: 0.1, animations: {
                self.googleMapView.setHeight(self.view.height() - (self.tabBarHeight + self.customNavBar.height()))
            })
        }
        self.state = state
        self.isTransitioning = false
    }
    
    func showMiniDrawer(withMessage message:String) {
        guard isTransitioning == false else {return}
        isTransitioning = true
        //Tell drawer to minimize itself with a message
        guard self.state != .MinimizedDrawer else {
            UIView.transition(with: self.drawerView.miniMessageButton, duration: 0.3, options: [.curveEaseOut], animations: {
                    self.drawerView.switchToMinimizedDrawer(title:message)
            }, completion: nil)
            self.isTransitioning = false
            return
        }
        self.updateVisibleMapElements(self,false)
        self.drawerView.isHidden = false
        if self.state == .SingleClinicDrawer || self.state == .MaximizedDrawer {
            UIView.animate(withDuration: 0.4, animations: {
                self.drawerView.setY(self.view.height())
                self.googleMapView.setHeight(self.view.height() - (self.tabBarHeight + self.customNavBar.height()))
            }, completion: { (_) in
                
                self.drawerView.switchToMinimizedDrawer(title:message)
                self.drawerView.setHeight(kDrawerMinimizedStateHeight)
                UIView.animate(withDuration: 0.3, animations: {
                    self.googleMapView.setHeight(self.view.height() - (self.tabBarHeight + self.customNavBar.height() + kDrawerMinimizedStateHeight))
                    self.drawerView.setY(self.view.height() - (self.tabBarHeight + kDrawerMinimizedStateHeight))
                }, completion:{_ in
                    self.state = .MinimizedDrawer
                    self.isTransitioning = false
                })
            })
        }
        else {
            UIView.animate(withDuration: 0.2, animations: {
                self.googleMapView.setHeight(self.view.height() - (self.tabBarHeight + self.customNavBar.height() + kDrawerMinimizedStateHeight))
            })
            self.state = .MinimizedDrawer
            self.isTransitioning = false
        }

    }
    
    override func didTapRightBarButton() {
        
        switch self.state {
        case .MaximizedDrawer:
            self.customNavBar.setRightButtonIcon(icon:FAIcon.FAList)
            if let _ = self.viewModel.nearestClinic {
                self.showNearestClinicInMinimizedState()
            }
            else {
                self.transitionTo(state:.HiddenDrawer)
            }
        default:
            self.customNavBar.setRightButtonIcon(icon:FAIcon.FAmap)
            self.transitionTo(state:.MaximizedDrawer)
            
        }
    }
    
    override func didTapLocationButton() {
        // Open location selection flow
        let vc = SelectLocationViewController()
        present(vc,animated:true)
    }
    
    @objc func didTapHideDrawerButton() {
        self.setHideButtonVisibility(false, delay: 0.0)
        if let _ = self.viewModel.nearestClinic {
            self.showNearestClinicInMinimizedState()
        }
        else {
            self.transitionTo(state: .HiddenDrawer)
        }
    }
    
    func didPan(drawer:DrawerView, panGesture:UIPanGestureRecognizer) {
        let y = panGesture.translation(in: drawer).y
        
        switch panGesture.state {
        case .began :
            totalPan = 0
            delta = 0
        case .changed :
            delta = y - totalPan
            totalPan = y
            updateDrawerWithDelta(delta)
            
        case .cancelled,.ended:
            self.updateDrawerWithTotalDrag(drag: totalPan)
        default:
            break;
        }
        
    }
    
    func didScrollDownWithDelta(_ delta:CGFloat) {
        self.updateDrawerWithDelta(-delta)
    }
    
    func didEndDragging(WithTotalDrag drag:CGFloat) {
        self.updateDrawerWithTotalDrag(drag: drag)
    }
    
    func updateDrawerWithTotalDrag(drag:CGFloat) {
//        guard drag <= 0 else {return}
        
        if drag < kDrawerViewDragQuotient {
            self.drawerView.setScrollDirection(.vertical)
            self.transitionTo(state: .MaximizedDrawer)
        }
        else {
            UIView.animate(withDuration: 0.3, animations: {
                self.drawerView.setY(self.view.height() - (self.tabBarHeight + kSingleClinicStateHeight))
                self.updateHideButtonOriginY()
            }, completion: { (_) in
                self.drawerView.setHeight(kSingleClinicStateHeight)
                self.drawerView.setScrollDirection(.horizontal)
                self.transitionTo(state: .SingleClinicDrawer)
            })
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
            self.drawerView.setScrollDirection(.vertical)
        }
        else {
            self.drawerView.setScrollDirection(.horizontal)
        }
        
        self.drawerView.setY(finalY)
        self.drawerView.setHeight(finalHeight)
        
        // clean up related views
        updateHideButtonOriginY()
    }
    
    func updateHideButtonOriginY() {
        self.hideButton.setY(self.drawerView.originY() - kDefaultPadding - kHideButtonSize)
    }
    
    func setHideButtonVisibility(_ isVisible:Bool, delay:Double) {
        var transform = CGAffineTransform.identity
        if isVisible == false {
            transform = self.hideButton.transform.translatedBy(x: 100, y: 0)
        }
        UIView.animate(withDuration: 0.3, delay: delay, options: [.curveEaseInOut], animations: {
            self.hideButton.transform = transform
        }, completion: nil)
        
    }
    
    func isBeingDragged() -> Bool {
        return (self.drawerView.originY() < singleClinicStateY && self.drawerView.originY() > maxStateY)
    }
    

}

