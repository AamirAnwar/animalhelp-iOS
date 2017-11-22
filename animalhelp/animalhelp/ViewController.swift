//
//  ViewController.swift
//  animalhelp
//
//  Created by Aamir  on 15/11/17.
//  Copyright © 2017 AamirAnwar. All rights reserved.
//

import UIKit
import SnapKit
import CoreLocation

struct Clinic:Codable {
    var _id:String
    var name:String
    var lon:Double
    var lat:Double
    var city:String
    var mobile:String
}

struct NearestClinic:Codable {
    var distance:Double
    var clinic:Clinic
}

class ViewController: UIViewController {
    let showLocationButton:UIButton = UIButton(type: .system)
    let locationLabel = UILabel()
    let locationManager = CLLocationManager()
    var location:CLLocation?
    let defaultSession = URLSession(configuration: .default)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        view.backgroundColor = UIColor.white
        view.addSubview(locationLabel)
        view.addSubview(showLocationButton)
        
        locationLabel.text = "Nothing here yet"
        locationLabel.textColor = UIColor.black
        locationLabel.numberOfLines = 0
        locationLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().inset(UIEdgeInsetsMake(90, 0, 0, 0))
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        
        
        showLocationButton.setTitle("Get Location", for: .normal)
        showLocationButton.addTarget(self, action: #selector(didTapShowLocation), for: .touchUpInside)
        showLocationButton.snp.makeConstraints { (make) in
            make.top.equalTo(self.locationLabel.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
        }
        
    }
    
    @objc func didTapShowLocation() {
        locationLabel.text = "Tapped the button"
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
    
    func showLocationServicesDeniedAlert() {
        let alert = UIAlertController(
            title: "Location Services Disabled",
            message: "Please enable location services for this app in Settings.",
            preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default,
                                     handler: nil)
        present(alert, animated: true, completion: nil)
        alert.addAction(okAction)
    }
    
    func updateLabels() {
        if let location = self.location {
            self.locationLabel.text = "Location is \(location.coordinate.latitude) and \(location.coordinate.longitude)"
        }
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
            self.locationLabel.text = "\(nearestClinic.clinic.name) is \(nearestClinic.distance)km away from you!"
        } catch let error {
            print("error! \(error)")
        }
        

    }
}



extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to update location")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.last
        if let location = location {
            print("Updated location with \(location)")
            self.updateLabels()
            self.updateNearestClinic()
            manager.stopUpdatingLocation()
        }
        
        
    }
}

