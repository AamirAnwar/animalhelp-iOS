//
//  ClinicCollectionViewCell.swift
//  animalhelp
//
//  Created by Aamir  on 12/01/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
let kRoundRectButtonWidth:CGFloat = 100
let kCustomButtonHeight:CGFloat = 33

protocol ClinicCollectionViewCellDelegate {
    func didTapGoogleMapsButton(sender:UICollectionViewCell)
}

class ClinicCollectionViewCell:UICollectionViewCell {
    var delegate:ClinicCollectionViewCellDelegate? = nil
    var bottomSeparator:CustomSeparator = {
        let separator = CustomSeparator.separator
        return separator
        
    }()
    let locationIconLabel:UILabel = {
        let label = UILabel()
        label.text = NSString.fontAwesomeIconString(forEnum: FAIcon.FAMapMarker)
        label.font = UIFont.init(name: kFontAwesomeFamilyName, size: 23)
        label.textColor = CustomColorTextBlack
        return label
        
    }()
    
    let nameLabel:UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.font = CustomFontButtonTitle
        label.textColor = CustomColorTextBlack
        label.numberOfLines = 2
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
    
    let addressLabel:UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.font = CustomFontSmallBodyMedium
        label.textColor = CustomColorTextBlack
        label.numberOfLines = 0
        return label
    }()
    
    let phoneLabel:UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.font = CustomFontSmallBodyMedium
        label.textColor = CustomColorTextBlack
        label.numberOfLines = 0
        return label
    }()
    
    let distanceLabel:UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.font = CustomFontHeadingSmall
        label.textColor = CustomColorMainTheme
        return label
    }()
    
    let navigateButton:UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Navigate", for: .normal)
        button.setTitleColor(CustomColorMainTheme, for: .normal)
        button.backgroundColor = UIColor.white
        button.layer.cornerRadius = 3*kCornerRadius
        button.layer.borderColor = CustomColorMainTheme.cgColor
        button.layer.borderWidth = 1
        button.titleLabel?.font = CustomFontSmallBodyMedium
        return button
    }()
    
    let callButton:UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Call", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = CustomColorMainTheme
        button.layer.cornerRadius = 3*kCornerRadius
        button.titleLabel?.font = CustomFontSmallBodyMedium
        return button
    }()
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init with coder not implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        // Create views here
        
//        self.contentView.backgroundColor = UIColor.red.withAlphaComponent(0.3)
        
        self.contentView.addSubview(nameLabel)
        self.contentView.addSubview(addressLabel)
        self.contentView.addSubview(phoneLabel)
        self.contentView.addSubview(navigateButton)
        self.contentView.addSubview(callButton)
        self.contentView.addSubview(distanceLabel)
        self.contentView.addSubview(locationIconLabel)
        self.contentView.addSubview(self.bottomSeparator)
        
        locationIconLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(kSidePadding)
            make.top.equalToSuperview().offset(13)
        }
        
        nameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(locationIconLabel.snp.top)
            make.leading.equalTo(locationIconLabel.snp.trailing).offset(8)
        }
        
        distanceLabel.snp.makeConstraints { (make) in
            make.top.equalTo(nameLabel.snp.top)
            make.trailing.equalToSuperview().inset(kSidePadding)
            make.leading.greaterThanOrEqualTo(nameLabel.snp.trailing).offset(10)
            
        }
        
        addressLabel.snp.makeConstraints { (make) in
            make.top.equalTo(nameLabel.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(kSidePadding)
            make.trailing.equalToSuperview().inset(kSidePadding)
        }
        
        phoneLabel.snp.makeConstraints { (make) in
            make.top.equalTo(addressLabel.snp.bottom).offset(8)
            make.leading.equalTo(addressLabel.snp.leading)
            make.trailing.equalTo(addressLabel.snp.trailing)
        }
        
        navigateButton.snp.makeConstraints { (make) in
            make.top.equalTo(phoneLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview().offset(-(kRoundRectButtonWidth/2 + 13))
            make.width.equalTo(kRoundRectButtonWidth)
            make.height.equalTo(kCustomButtonHeight)
        }
        
        callButton.snp.makeConstraints { (make) in
            make.top.equalTo(navigateButton.snp.top)
            make.centerX.equalToSuperview().offset((kRoundRectButtonWidth/2 + 13))
            make.width.equalTo(kRoundRectButtonWidth)
            make.height.equalTo(kCustomButtonHeight)
            make.bottom.equalToSuperview().inset(13)
        }
        
        self.bottomSeparator.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(kSidePadding)
            make.trailing.equalToSuperview().inset(kSidePadding)
        }
        self.bottomSeparator.isHidden = true
        
        navigateButton.addTarget(self, action: #selector(googleMapsButtonTapped), for: .touchUpInside)
        nameLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        distanceLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
    }
    
    func setClinic(_ clinic:Clinic?) {
        if let clinic = clinic {
            nameLabel.text = clinic.name
            addressLabel.text = "Address - \(clinic.address)"
//            phoneLabel.text = "Phone - \(clinic.mobile)"
            if let distance = clinic.distance {
                distanceLabel.text = "\(distance) km"
            }
        }
    }
    @objc func googleMapsButtonTapped() {
        self.delegate?.didTapGoogleMapsButton(sender:self)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        distanceLabel.preferredMaxLayoutWidth = self.frame.size.width/2
        self.nameLabel.sizeToFit()
        
    }
}
