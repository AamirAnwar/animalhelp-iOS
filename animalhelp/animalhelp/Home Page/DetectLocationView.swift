//
//  DetectLocationView.swift
//  animalhelp
//
//  Created by Aamir  on 28/01/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import UIKit

protocol DetectLocationViewDelegate {
    func didTapDetectLocation()
    func didTapManuallySelectLocation()
}


class DetectLocationView: UIView {

    let locationPinImageView = UIImageView(image: #imageLiteral(resourceName: "LocationPin"))
    let graphicImageView = UIImageView.init(image: #imageLiteral(resourceName: "Onboarding_Art"))
    let infoLabel = UILabel()
    let detectLocationButton = UIButton(type: .system)
    let manualLocationButton = UIButton(type: .system)
    var delegate:DetectLocationViewDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Init with coder not implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUnkownLocationView()
    }
    
    fileprivate func setupUnkownLocationView() {
        self.addSubview(graphicImageView)
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
        manualLocationButton.setTitleColor(CustomColorDarkGray, for: .normal)
        manualLocationButton.layer.cornerRadius = kCornerRadius
        manualLocationButton.layer.borderWidth = 1
        manualLocationButton.titleLabel?.font = CustomFontButtonTitle
        manualLocationButton.layer.borderColor = CustomColorDarkGray.cgColor
        manualLocationButton.addTarget(self, action: #selector(manuallySelectLocationButtonTapped), for: .touchUpInside)
        
        graphicImageView.contentMode = .scaleAspectFit
        graphicImageView.clipsToBounds = true
        
        manualLocationButton.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(kSidePadding)
            make.trailing.equalToSuperview().inset(kSidePadding)
            make.height.equalTo(detectLocationButton.snp.height)
            make.bottom.equalTo(self.snp.bottom).offset(-20)
        }
        
        detectLocationButton.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(kSidePadding)
            make.trailing.equalToSuperview().inset(kSidePadding)
            make.bottom.equalTo(manualLocationButton.snp.top).offset(-16)
            make.height.equalTo(kStandardButtonHeight)
        }
        
        infoLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(detectLocationButton.snp.top).offset(-16)
            make.leading.equalToSuperview().offset(kSidePadding)
            make.trailing.equalToSuperview().inset(kSidePadding)
        }
        
        locationPinImageView.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.infoLabel.snp.top).offset(-8)
            make.centerX.equalToSuperview()
            make.height.equalTo(34)
            make.width.equalTo(22)
        }
        
        graphicImageView.snp.makeConstraints { (make) in
            make.top.greaterThanOrEqualToSuperview().offset(CustomNavigationBar.kCustomNavBarHeight)
            make.leading.equalToSuperview().offset(kSidePadding)
            make.trailing.equalToSuperview().inset(kSidePadding)
            make.bottom.equalTo(self.locationPinImageView.snp.top).offset(-16)
        }
    }
    
    //MARK: Button Callbacks
    @objc fileprivate func detectLocationButtonTapped() {
        self.delegate?.didTapDetectLocation()
    }
    
    @objc fileprivate func manuallySelectLocationButtonTapped() {
        self.delegate?.didTapManuallySelectLocation()
    }
    
}
