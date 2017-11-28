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
import Moya
import MapKit
import GoogleMaps

class HomeViewController: UIViewController {
    let showLocationButton:UIButton = UIButton(type: .system)
    lazy var appleMapView = MKMapView()
    var googleMapView:GMSMapView = {
        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
        return GMSMapView.map(withFrame: CGRect.zero, camera: camera)
    }()
    
    let locationManager = CLLocationManager()
    var location:CLLocation?
    let defaultSession = URLSession(configuration: .default)
    let zoomLevel:Float = 15
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        view.backgroundColor = UIColor.white
        self.navigationItem.title = "Your Location"
        createGoogleMapView()
        startDetectingLocation()
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
        // Create a GMSCameraPosition that tells the map to display the
        // coordinate -33.86,151.20 at zoom level 6.
        view.addSubview(googleMapView)
        googleMapView.isMyLocationEnabled = true
        googleMapView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
//        // Creates a marker in the center of the map.
//        let marker = GMSMarker()
//        marker.position = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
//        marker.title = "Sydney"
//        marker.snippet = "Australia"
//        marker.map = googleMapView
        
    }
    
    func startDetectingLocation() {
        let authStatus = CLLocationManager.authorizationStatus()
        if authStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        else if authStatus == .denied || authStatus == .restricted {
            showLocationServicesDeniedAlert()
            return
        }
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
    }
    
    func stopDetectingLocation() {
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
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

    func updateNearestClinic() {
        if let location = self.location {
            if let url = URL(string: "http://localhost:3000/clinics/distance?lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)") {
                print("Hitting \(url.absoluteString)")
                let dataTask = defaultSession.dataTask(with: url) {data, response, error in
                    if let error = error {
                        print(error)
                    }
                    else if let data = data {
                        if let response = response as? HTTPURLResponse, response.statusCode == 200, let jsonString = String(data: data, encoding: String.Encoding.utf8) {
                            print(jsonString)
                            DispatchQueue.main.async {
                                self.handleJSONString(jsonString: jsonString)
                            }
                        }
                    }
                }
                dataTask.resume()
            }
        }
    }
    
    func handleJSONString(jsonString:String) {
        let decoder = JSONDecoder()
        do {
            let nearestClinic = try decoder.decode(NearestClinic.self, from: jsonString.data(using: .utf8)!)
            print("Final clinic \(nearestClinic)")
//            self.locationLabel.text = "\(nearestClinic.clinic.name) is \(nearestClinic.distance)km away from you!"
        } catch let error {
            print("error! \(error)")
        }
    }
}



extension HomeViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to update location")
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.last
        if let location = location {
            print("Updated location with \(location)")
            let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                                  longitude: location.coordinate.longitude,
                                                  zoom: zoomLevel)
                googleMapView.animate(to: camera)
            self.stopDetectingLocation()
        }
        
        
    }
}

extension HomeViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        appleMapView.showAnnotations([userLocation], animated: true)
    }
}

