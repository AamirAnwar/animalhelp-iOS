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
    
    let markLabelButton:UIButton = {
        let button = UIButton()
        button.setTitleColor(CustomColorMainTheme, for: .normal)
        button.titleLabel?.font = CustomFontSmallBodyMedium
        button.layer.borderColor = CustomColorMainTheme.cgColor
        button.layer.borderWidth = 1
        let inset:CGFloat = 5
        button.contentEdgeInsets = UIEdgeInsetsMake(inset, inset, inset, inset)
        button.backgroundColor = UIColor.white
        return button
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

        self.containerView.addSubview(self.petImageView)
        self.containerView.addSubview(self.petBreedLabel)
        self.containerView.addSubview(self.petDescLabel)
        self.containerView.addSubview(self.petTypeLabel)
        self.containerView.addSubview(self.locationLabel)
        self.containerView.addSubview(self.missingSinceLabel)
        self.containerView.addSubview(self.markLabelButton)
        
        self.containerView.backgroundColor = UIColor.white
        
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
            make.leading.equalTo(self.petImageView.snp.leading).offset(8)
            make.trailing.equalTo(self.petImageView.snp.trailing).inset(8)
        }
        
        self.petDescLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.petBreedLabel.snp.bottom).offset(8)
            make.leading.equalTo(self.petBreedLabel.snp.leading)
            make.trailing.equalTo(self.petBreedLabel.snp.trailing)
        }
        
        self.missingSinceLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(self.petDescLabel.snp.leading).offset(16)
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
        
        self.markLabelButton.snp.makeConstraints { (make) in
            make.top.equalTo(self.petTypeLabel.snp.top)
            make.trailing.equalTo(self.locationLabel.snp.trailing)
            make.width.lessThanOrEqualTo(self.containerView.snp.width).multipliedBy(0.5)
            make.bottom.equalToSuperview().inset(13)
        }
        
        
        UtilityFunctions.assignFontLabelTo(self.petTypeLabel, icon: FAIcon.FAodnoklassniki)
        UtilityFunctions.assignFontLabelTo(self.missingSinceLabel, icon: FAIcon.FAClockO)
        UtilityFunctions.assignFontLabelTo(self.locationLabel, icon: FAIcon.FAMapMarker)
    }
    
    func setMissingPet(_ pet:MissingPet) {
        self.petBreedLabel.text = pet.breed ?? ""
        self.petDescLabel.text = pet.petDescription ?? ""
        self.locationLabel.text = pet.lastKnownLocation ?? ""
        self.petTypeLabel.text = pet.type
        self.markLabelButton.setTitle("\(pet.distFeatures ?? "")", for: .normal)
        self.missingSinceLabel.text = pet.missingSince
        self.petImageView.setImage(WithURL: pet.imageURL ?? "")
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if self.contentView.frame.height > 0 &&  self.containerView.layer.shadowPath == nil {
            self.containerView.layoutIfNeeded()
            self.markLabelButton.layer.cornerRadius = 2*kCornerRadius
            UtilityFunctions.addShadowTo(view: self.containerView)
            
        }
    }
}
