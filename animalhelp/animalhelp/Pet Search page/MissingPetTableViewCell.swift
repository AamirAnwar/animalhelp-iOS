//
//  MissingPetTableViewCell.swift
//  animalhelp
//
//  Created by Aamir  on 19/01/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import Foundation
import UIKit

class MissingPetTableViewCell:UITableViewCell {
    
    let containerView = UIView()
    let petImageView = UIImageView()
    let petBreedLabel:UILabel = {
       let label = UILabel()
        label.textColor = CustomColorTextBlack
        label.font = CustomFontTitleBold
        return label
    }()
    
    let petDescLabel:UILabel = {
        let label = UILabel()
        label.textColor = CustomColorLightGray
        label.font = CustomFontBodyParagraphMedium
        label.numberOfLines = 2
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        return label
    }()
    
    let postedSinceLabel:UILabel = {
        let label = UILabel()
        label.textAlignment = .natural
        label.textColor = CustomColorLightGray
        label.font = CustomFontHeadingSmall
        return label
    }()
    
    let locationLabel:UILabel = {
        let label = UILabel()
        label.textAlignment = .natural
        label.textColor = CustomColorLightGray
        label.font = CustomFontSmallBodyMedium
        label.numberOfLines = 0
        return label
    }()
    
    let markLabel:UILabel = {
        let label = UILabel()
        label.textColor = CustomColorMainTheme
        label.font = CustomFontSmallBodyMedium
        label.backgroundColor = UIColor.white
        return label
    }()
    
    let locationIconLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.init(name: kFontAwesomeFamilyName, size: 17)
        label.text = NSString.fontAwesomeIconString(forEnum: FAIcon.FAMapMarker)
        label.textColor = CustomColorDarkGray
        return label
    }()
    
    let markIconLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.init(name: kFontAwesomeFamilyName, size: 15)
        label.text = NSString.fontAwesomeIconString(forEnum: FAIcon.FAExclamationCircle)
        label.textColor = CustomColorMainTheme
        return label
    }()
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Init with coder not implemented")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        
        self.petImageView.contentMode = .scaleAspectFill
        self.petImageView.clipsToBounds = true
        self.petImageView.layer.cornerRadius = kCornerRadius

        if #available(iOS 11, *) {
            self.petImageView.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
        }
        
        self.contentView.backgroundColor = UIColor.clear
        self.contentView.addSubview(self.containerView)
        self.containerView.layer.cornerRadius = kCornerRadius
        self.containerView.backgroundColor = UIColor.white

        self.containerView.addSubview(self.petImageView)
        self.containerView.addSubview(self.petBreedLabel)
        self.containerView.addSubview(self.petDescLabel)
        self.containerView.addSubview(self.locationLabel)
        self.containerView.addSubview(self.postedSinceLabel)
        self.containerView.addSubview(self.markLabel)
        self.containerView.addSubview(self.locationIconLabel)
        self.containerView.addSubview(self.markIconLabel)
        
        self.containerView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(13)
            make.bottom.equalToSuperview().inset(13)
            make.leading.equalToSuperview().offset(kSidePadding)
            make.trailing.equalToSuperview().inset(kSidePadding)
        }
        
        self.petImageView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(kMissingPetImageHeight)
        }
        
        self.petBreedLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.petImageView.snp.bottom).offset(8)
            make.leading.equalTo(self.petImageView.snp.leading).offset(kSidePadding)
            make.trailing.lessThanOrEqualTo(self.postedSinceLabel.snp.leading).offset(-kDefaultPadding)
        }
        
        self.postedSinceLabel.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().inset(kSidePadding)
            make.centerY.equalTo(self.petBreedLabel.snp.centerY)
        }
        
        self.petDescLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.petBreedLabel.snp.bottom).offset(kDefaultPadding)
            make.leading.equalToSuperview().offset(kSidePadding)
            make.trailing.equalToSuperview().inset(kSidePadding)
        }
        
        self.locationLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.petDescLabel.snp.bottom).offset(2*kDefaultPadding)
            make.leading.equalTo(self.locationIconLabel.snp.trailing).offset(4)
            make.trailing.equalToSuperview().inset(kSidePadding)
        }
        
        self.markLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.locationLabel.snp.bottom).offset(kDefaultPadding)
            make.leading.equalTo(self.markIconLabel.snp.trailing).offset(4)
            make.trailing.equalTo(self.locationLabel.snp.trailing)
            make.bottom.equalToSuperview().inset(13)
        }
        
        self.locationIconLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(kSidePadding)
            make.top.equalTo(self.locationLabel.snp.top).offset(2)
            make.width.equalTo(14)
        }
        
        self.markIconLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(self.locationIconLabel)
            make.top.equalTo(self.markLabel.snp.top).offset(2)
            make.width.equalTo(14)
            
        }
    }
    
    func setMissingPet(_ pet:MissingPet) {
        self.petBreedLabel.text = pet.breed ?? ""
        self.petDescLabel.text = pet.petDescription ?? ""
        self.locationLabel.text = pet.lastKnownLocation ?? ""
        self.markLabel.text = "\(pet.distFeatures ?? "")"
        self.postedSinceLabel.text = pet.missingSince
        self.petImageView.setImage(WithURL: pet.imageURL ?? "")
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if self.contentView.frame.height > 0 &&  self.containerView.layer.shadowPath == nil {
            self.containerView.layoutIfNeeded()
            UtilityFunctions.addShadowTo(view: self.containerView)
        }
    }
}
