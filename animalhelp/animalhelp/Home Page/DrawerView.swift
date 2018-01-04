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

class DrawerView:UIView {
    let locationPinImageView = UIImageView(image: #imageLiteral(resourceName: "LocationPin"))
    let infoLabel = UILabel()
    let detectLocationButton = UIButton(type: .system)
    let manualLocationButton = UIButton(type: .system)
    let tapGesture = UITapGestureRecognizer()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init with coder not implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        tapGesture.addTarget(self, action: #selector(drawerTapped))
        self.backgroundColor = UIColor.white
        self.addGestureRecognizer(tapGesture)
        self.createLayout()
    }
    func createLayout() {
        
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
        
        manualLocationButton.setTitle("Manually Select Location", for: .normal)
        manualLocationButton.setTitleColor(CustomColorLightGray, for: .normal)
        manualLocationButton.layer.cornerRadius = kCornerRadius
        manualLocationButton.layer.borderWidth = 1
        manualLocationButton.titleLabel?.font = CustomFontButtonTitle
        manualLocationButton.layer.borderColor = CustomColorLightGray.cgColor
        
        
        
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
            make.height.equalTo(50)
        }
        
        manualLocationButton.snp.makeConstraints { (make) in
            make.leading.equalTo(detectLocationButton.snp.leading)
            make.trailing.equalTo(detectLocationButton.snp.trailing)
            make.top.equalTo(detectLocationButton.snp.bottom).offset(16)
            make.height.equalTo(detectLocationButton.snp.height)
            make.bottom.equalTo(self.snp.bottom).offset(-20)
        }
    }
    
    
    @objc func drawerTapped() {
        UIView.animate(withDuration: 0.2) {
            if self.transform.isIdentity {
                self.transform = CGAffineTransform.init(translationX: 0, y: 50)
            }
            else {
                self.transform = .identity
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        print("Did layout subviews")
    }
    
    override func didMoveToSuperview() {
        
    }
}
