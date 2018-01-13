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

protocol ClinicCollectionViewCellDelegate {
    func didTapGoogleMapsButton(sender:UICollectionViewCell)
}

class ClinicCollectionViewCell:UICollectionViewCell {
    var delegate:ClinicCollectionViewCellDelegate? = nil
    let bannerLabel:UILabel = {
       let label = UILabel(frame: CGRect.zero)
        label.text = "Nearest Help Center"
        label.font = CustomFontHeadingSmall
        label.textColor = CustomColorMainTheme
        label.textAlignment = .center
        return label
    }()
    
    let nameLabel:UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.font = CustomFontButtonTitle
        label.textColor = CustomColorTextBlack
        
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
    
    let googleMapsButton:UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Open in Google Maps", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = CustomColorMainTheme
        button.layer.cornerRadius = kCornerRadius
        button.titleLabel?.font = CustomFontButtonTitle
        return button
    }()
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init with coder not implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        // Create views here
        self.contentView.addSubview(bannerLabel)
        self.contentView.addSubview(nameLabel)
        self.contentView.addSubview(addressLabel)
        self.contentView.addSubview(phoneLabel)
        self.contentView.addSubview(googleMapsButton)
        
        
        bannerLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().offset(-12)
        }
        
        nameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(bannerLabel.snp.bottom).offset(8)
            make.leading.equalTo(bannerLabel.snp.leading)
            make.trailing.equalTo(bannerLabel.snp.trailing)
        }
        
        addressLabel.snp.makeConstraints { (make) in
            make.top.equalTo(nameLabel.snp.bottom).offset(8)
            make.leading.equalTo(nameLabel.snp.leading)
            make.trailing.equalTo(nameLabel.snp.trailing)
        }
        
        phoneLabel.snp.makeConstraints { (make) in
            make.top.equalTo(addressLabel.snp.bottom).offset(8)
            make.leading.equalTo(addressLabel.snp.leading)
            make.trailing.equalTo(addressLabel.snp.trailing)
        }
        
        googleMapsButton.snp.makeConstraints { (make) in
            make.top.equalTo(phoneLabel.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
            make.height.equalTo(kStandardButtonHeight)
        }
        
        googleMapsButton.addTarget(self, action: #selector(googleMapsButtonTapped), for: .touchUpInside)
    }
    
    func setNearestClinic(_ clinic:NearestClinic?) {
        if let clinic = clinic {
            // TODO fix this clinic.clinic with a better model
            nameLabel.text = clinic.clinic.name
            addressLabel.text = "Address - \(clinic.clinic.address)"
            phoneLabel.text = "Phone - \(clinic.clinic.mobile)"
            
        }
    }
    @objc func googleMapsButtonTapped() {
        self.delegate?.didTapGoogleMapsButton(sender:self)
    }
}
