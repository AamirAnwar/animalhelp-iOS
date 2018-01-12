//
//  DrawerView.swift
//  animalhelp
//
//  Created by Aamir  on 04/01/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

protocol DrawerViewDelegate {
    func didTapDetectLocation()
    func didTapManuallySelectLocation()
}
let kCollectionViewHeight:CGFloat = 257

class DrawerView:UIView {
    let locationPinImageView = UIImageView(image: #imageLiteral(resourceName: "LocationPin"))
    let infoLabel = UILabel()
    let detectLocationButton = UIButton(type: .system)
    let manualLocationButton = UIButton(type: .system)
    let tapGesture = UITapGestureRecognizer()
    var delegate:DrawerViewDelegate? = nil
    var flowLayout = UICollectionViewFlowLayout()
    var collectionView:UICollectionView!
    let clinicCellReuseIdentifier = "ClinicCellReuseIdentifier"
    var nearestClinic:NearestClinic? = nil
    required init?(coder aDecoder: NSCoder) {
        fatalError("init with coder not implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        
        self.flowLayout = UICollectionViewFlowLayout()
        self.collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: self.flowLayout)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.backgroundColor = UIColor.white
        self.collectionView.register(ClinicCollectionViewCell.self, forCellWithReuseIdentifier: self.clinicCellReuseIdentifier)
        self.addSubview(self.collectionView)
        self.collectionView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            make.height.equalTo(kCollectionViewHeight)
        }
    }
    
    fileprivate func createOnboardingView() {
        self.addSubview(locationPinImageView)
        self.addSubview(infoLabel)
        self.addSubview(manualLocationButton)
        self.addSubview(detectLocationButton)
        
        infoLabel.text = "We need your location to find clinics around you"
        infoLabel.numberOfLines = 0
        infoLabel.font = CustomFontBodyMedium
        infoLabel.textAlignment = .center
        
        detectLocationButton.setTitle("Detect Location", for: .normal)
        detectLocationButton.setTitleColor(UIColor.white, for: .normal)
        detectLocationButton.backgroundColor = CustomColorMainTheme
        detectLocationButton.layer.cornerRadius = kCornerRadius
        detectLocationButton.titleLabel?.font = CustomFontButtonTitle
        detectLocationButton.addTarget(self, action: #selector(detectLocationButtonTapped), for: .touchUpInside)
        
        manualLocationButton.setTitle("Manually Select Location", for: .normal)
        manualLocationButton.setTitleColor(CustomColorLightGray, for: .normal)
        manualLocationButton.layer.cornerRadius = kCornerRadius
        manualLocationButton.layer.borderWidth = 1
        manualLocationButton.titleLabel?.font = CustomFontButtonTitle
        manualLocationButton.layer.borderColor = CustomColorLightGray.cgColor
        manualLocationButton.addTarget(self, action: #selector(manuallySelectLocationButtonTapped), for: .touchUpInside)
        
        locationPinImageView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
        }
        
        infoLabel.snp.makeConstraints { (make) in
            make.top.equalTo(locationPinImageView.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().offset(-8)
        }
        
        detectLocationButton.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
            make.top.equalTo(infoLabel.snp.bottom).offset(16)
            make.height.equalTo(kStandardButtonHeight)
        }
        
        manualLocationButton.snp.makeConstraints { (make) in
            make.leading.equalTo(detectLocationButton.snp.leading)
            make.trailing.equalTo(detectLocationButton.snp.trailing)
            make.top.equalTo(detectLocationButton.snp.bottom).offset(16)
            make.height.equalTo(detectLocationButton.snp.height)
            make.bottom.equalTo(self.snp.bottom).offset(-20)
        }
    }
    
    func showClinic(clinic:NearestClinic) {
        self.nearestClinic = clinic
        self.collectionView.reloadData()
    }
    
    @objc func detectLocationButtonTapped() {
        self.delegate?.didTapDetectLocation()
    }
    
    @objc func manuallySelectLocationButtonTapped() {
        self.delegate?.didTapManuallySelectLocation()
    }
    
    @objc fileprivate func drawerTapped() {
        UIView.animate(withDuration: 0.2) {
            if self.transform.isIdentity {
                self.transform = CGAffineTransform.init(translationX: 0, y: 50)
            }
            else {
                self.transform = .identity
            }
        }
    }
}

extension DrawerView:UICollectionViewDelegate,UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.clinicCellReuseIdentifier, for: indexPath) as! ClinicCollectionViewCell
        cell.setNearestClinic(self.nearestClinic)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.collectionView.frame.size.width, height: self.collectionView.frame.size.height)
    }
}
