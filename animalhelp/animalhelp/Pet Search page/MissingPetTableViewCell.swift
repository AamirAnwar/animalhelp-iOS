//
//  MissingPetTableViewCell.swift
//  animalhelp
//
//  Created by Aamir  on 19/01/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import Foundation
import UIKit
let kMissingPetImageHeight:CGFloat = 265

class MissingPetTableViewCell:UITableViewCell {
    
    let containerView = UIView()
    let petImageView = UIImageView()
    let petBreedLabel:UILabel = {
       let label = UILabel()
        label.textAlignment = .center
        label.textColor = CustomColorTextBlack
        label.font = CustomFontTitleBold
        return label
    }()
    
    let petDescLabel:UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = CustomColorLightGray
        label.font = CustomFontSmallBodyMedium
        label.numberOfLines = 0
        return label
    }()
    
    let missingSinceLabel:UILabel = {
        let label = UILabel()
        label.textAlignment = .natural
        label.textColor = CustomColorLightGray
        label.font = CustomFontSmallBodyMedium
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
    
    let petTypeLabel:UILabel = {
        let label = UILabel()
        label.textAlignment = .natural
        label.textColor = CustomColorLightGray
        label.font = CustomFontSmallBodyMedium
        return label
    }()
    
    let markLabel:UILabel = {
        let label = UILabel()
        label.textAlignment = .natural
        label.textColor = UIColor.white
        label.font = CustomFontSmallBodyMedium
        label.backgroundColor = CustomColorDarkGray
        label.clipsToBounds = true
        return label
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Init with coder not implemented")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        
        self.petImageView.image = #imageLiteral(resourceName: "defaultProfileImage")
        self.petImageView.contentMode = .scaleAspectFill
        self.petImageView.clipsToBounds = true
        self.petImageView.layer.cornerRadius = kCornerRadius
        
        self.contentView.backgroundColor = UIColor.clear
        self.contentView.addSubview(self.containerView)
        self.containerView.layer.cornerRadius = kCornerRadius

        self.containerView.addSubview(self.petImageView)
        self.containerView.addSubview(self.petBreedLabel)
        self.containerView.addSubview(self.petDescLabel)
        self.containerView.addSubview(self.petTypeLabel)
        self.containerView.addSubview(self.locationLabel)
        self.containerView.addSubview(self.missingSinceLabel)
        self.containerView.addSubview(self.markLabel)
        
        self.containerView.backgroundColor = UIColor.white
        
        self.containerView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(13)
            make.bottom.equalToSuperview().inset(13)
            make.leading.equalToSuperview().offset(kSidePadding)
            make.trailing.equalToSuperview().inset(kSidePadding)
        }
        
        self.petImageView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().inset(8)
            make.height.equalTo(kMissingPetImageHeight)
        }
        
        self.petBreedLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.petImageView.snp.bottom).offset(8)
            make.leading.equalTo(self.petImageView.snp.leading)
            make.trailing.equalTo(self.petImageView.snp.trailing)
        }
        
        self.petDescLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.petBreedLabel.snp.bottom).offset(8)
            make.leading.equalTo(self.petBreedLabel.snp.leading)
            make.trailing.equalTo(self.petBreedLabel.snp.trailing)
        }
        
        self.missingSinceLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(self.petDescLabel.snp.leading).offset(14)
            make.width.lessThanOrEqualTo(self.containerView.snp.width).multipliedBy(0.5)
            make.top.equalTo(self.petDescLabel.snp.bottom).offset(16)
        }
        
        self.locationLabel.snp.makeConstraints { (make) in
            make.trailing.equalTo(self.petDescLabel.snp.trailing)
            make.top.equalTo(self.missingSinceLabel.snp.top)
            make.width.lessThanOrEqualTo(self.containerView.snp.width).multipliedBy(0.5)
        }
        
        self.petTypeLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.locationLabel.snp.bottom).offset(11)
            make.width.lessThanOrEqualTo(self.containerView.snp.width).multipliedBy(0.5)
            make.leading.equalTo(self.missingSinceLabel.snp.leading)
        }
        
        self.markLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.petTypeLabel.snp.top)
            make.trailing.equalTo(self.locationLabel.snp.trailing)
            make.width.lessThanOrEqualTo(self.containerView.snp.width).multipliedBy(0.5)
            make.bottom.equalToSuperview().inset(13)
        }
        
        UtilityFunctions.assignDotTo(self.petTypeLabel)
        UtilityFunctions.assignDotTo(missingSinceLabel)
        UtilityFunctions.assignDotTo(self.locationLabel)
    }
    
    func setMissingPet(_ pet:MissingPet) {
        self.petBreedLabel.text = pet.breed ?? ""
        self.petDescLabel.text = pet.petDescription ?? ""
        self.locationLabel.text = pet.lastKnownLocation ?? ""
        self.petTypeLabel.text = pet.type
        self.markLabel.text = " \(pet.distFeatures ?? "") "
        self.missingSinceLabel.text = pet.missingSince
        
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if self.containerView.frame.height > 0 &&  self.containerView.layer.shadowPath == nil {
            UtilityFunctions.addShadowTo(view: self.containerView)
            self.markLabel.layer.cornerRadius = 2*kCornerRadius
            self.layoutIfNeeded()
        }
    }
}