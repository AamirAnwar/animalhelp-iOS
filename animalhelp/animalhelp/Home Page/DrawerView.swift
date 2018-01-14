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
    func didTapOpenInGoogleMaps(forIndex indexPath:IndexPath)
    func didTapStickyButton(seeMore:Bool)
}

class DrawerView:UIView {
    let locationPinImageView = UIImageView(image: #imageLiteral(resourceName: "LocationPin"))
    let infoLabel = UILabel()
    let detectLocationButton = UIButton(type: .system)
    let manualLocationButton = UIButton(type: .system)
    let stickyButton = UIButton(type: .system)
    let onboardingContainerView = UIView()
    let tapGesture = UITapGestureRecognizer()
    var delegate:DrawerViewDelegate? = nil
    var flowLayout:UICollectionViewFlowLayout = {
       let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        return layout
    }()
    var collectionView:UICollectionView!
    let clinicCellReuseIdentifier = "ClinicCellReuseIdentifier"
    var nearestClinic:NearestClinic? = nil
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init with coder not implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        self.collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: self.flowLayout)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.isPagingEnabled = true
        self.collectionView.backgroundColor = UIColor.white
        self.collectionView.register(ClinicCollectionViewCell.self, forCellWithReuseIdentifier: self.clinicCellReuseIdentifier)
        self.addSubview(self.collectionView)
        self.collectionView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            make.height.greaterThanOrEqualTo(kCollectionViewHeight)
        }
        
        self.addSubview(self.stickyButton)
        self.stickyButton.setTitleColor(CustomColorMainTheme, for: .normal)
        self.stickyButton.titleLabel?.font = CustomFontHeadingSmall
        self.stickyButton.layer.borderWidth = 1
        self.stickyButton.layer.borderColor = CustomColorMainTheme.cgColor
        let inset:CGFloat = 8
        self.stickyButton.contentEdgeInsets = UIEdgeInsetsMake(3, inset, 3, inset)
        self.stickyButton.setTitle("See more clinics", for: .normal)
        self.stickyButton.layer.cornerRadius = 2*kCornerRadius
        self.stickyButton.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().inset(10)
            make.centerX.equalToSuperview()
        }
        self.stickyButton.addTarget(self, action: #selector(didTapSeeAllClinics), for: .touchUpInside)
    }
    
    fileprivate func setupUnkownLocationView() {
        guard onboardingContainerView.superview == nil else {
            return
        }
        
        self.addSubview(onboardingContainerView)
        onboardingContainerView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        onboardingContainerView.addSubview(locationPinImageView)
        onboardingContainerView.addSubview(infoLabel)
        onboardingContainerView.addSubview(manualLocationButton)
        onboardingContainerView.addSubview(detectLocationButton)
        
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
        self.onboardingContainerView.isHidden = true
        self.collectionView.isHidden = false
        self.stickyButton.isHidden = false
        self.nearestClinic = clinic
        self.collectionView.reloadData()
    }
    
    public func showUnknownLocationState() {
        self.onboardingContainerView.isHidden = false
        self.collectionView.isHidden = true
        self.stickyButton.isHidden = true
        setupUnkownLocationView()
    }

    
    //MARK: Button Callbacks
    @objc fileprivate func detectLocationButtonTapped() {
        self.delegate?.didTapDetectLocation()
    }
    
    @objc fileprivate func manuallySelectLocationButtonTapped() {
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

extension DrawerView:UICollectionViewDelegate,UICollectionViewDelegateFlowLayout, UICollectionViewDataSource,ClinicCollectionViewCellDelegate {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.clinicCellReuseIdentifier, for: indexPath) as! ClinicCollectionViewCell
        cell.setNearestClinic(self.nearestClinic)
        cell.delegate = self
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // TODO implement self sizing cells
        return CGSize(width: self.collectionView.frame.size.width, height: 250)
    }
    
    func didTapGoogleMapsButton(sender: UICollectionViewCell) {
        if let indexPath = self.collectionView.indexPath(for: sender) {
            self.delegate?.didTapOpenInGoogleMaps(forIndex: indexPath)
        }
    }
    
    @objc func didTapSeeAllClinics() {
        var seeMore = false
        if self.flowLayout.scrollDirection == .vertical {
            self.flowLayout.scrollDirection = .horizontal
            self.collectionView.isPagingEnabled = true
            UIView.transition(with: self.stickyButton, duration: 0.3, options: .transitionCrossDissolve, animations: {
                self.stickyButton.setTitleColor(CustomColorMainTheme, for: .normal)
                self.stickyButton.backgroundColor = UIColor.white
            }, completion: nil)
            
        }
        else {
            self.collectionView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
            self.flowLayout.scrollDirection = .vertical
            self.collectionView.isPagingEnabled = false
            UIView.transition(with: self.stickyButton, duration: 0.3, options: .transitionCrossDissolve, animations: {
                self.stickyButton.setTitleColor(UIColor.white, for: .normal)
                self.stickyButton.backgroundColor = CustomColorMainTheme
            }, completion: nil)
            seeMore = true
        }
        self.collectionView.setCollectionViewLayout(self.flowLayout, animated: false)
        // TODO - Transition to maximized drawer
        self.delegate?.didTapStickyButton(seeMore: seeMore)
    }
    
    
    
}
