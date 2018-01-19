//
//  SocialLoginTableViewCell.swift
//  animalhelp
//
//  Created by Aamir  on 19/01/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import Foundation
import UIKit

class SocialLoginTableViewCell:UITableViewCell {
    
    let headingLabel:UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = CustomColorTextBlack
        label.font = CustomFontButtonTitle
        label.text = "Login or Sign up"
        return label
    }()
    
    let subheadingLabel:UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = CustomColorLightGray
        label.font = CustomFontSmallBodyMedium
        label.text = "We'll never post unless you give the order"
        return label
    }()
    
    let facebookButton:UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login with Facebook", for: .normal)
        button.titleLabel?.font = CustomFontButtonTitle
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.textAlignment = .center
        button.backgroundColor = CustomColorFacebookBlue
        button.layer.cornerRadius = kCornerRadius
        return button
    }()
    
    let googleButton:UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login with Google", for: .normal)
        button.titleLabel?.font = CustomFontButtonTitle
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.textAlignment = .center
        button.backgroundColor = CustomColorGoogleOrange
        button.layer.cornerRadius = kCornerRadius
        return button
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Init with coder not implemented")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(self.headingLabel)
        self.contentView.addSubview(self.subheadingLabel)
        self.contentView.addSubview(self.facebookButton)
        self.contentView.addSubview(self.googleButton)
        
        self.headingLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview().offset(kSidePadding)
            make.trailing.equalToSuperview().inset(kSidePadding)
        }
        
        self.subheadingLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.headingLabel.snp.bottom).offset(3)
            make.leading.equalTo(self.headingLabel.snp.leading)
            make.trailing.equalTo(self.headingLabel.snp.trailing)
        }
        
        self.facebookButton.snp.makeConstraints { (make) in
            make.top.equalTo(self.subheadingLabel.snp.bottom).offset(19)
            make.leading.equalTo(self.subheadingLabel.snp.leading)
            make.trailing.equalTo(self.subheadingLabel.snp.trailing)
            make.height.equalTo(kSocialLoginButtonHeight)
        }
        
        self.googleButton.snp.makeConstraints { (make) in
            make.top.equalTo(self.facebookButton.snp.bottom).offset(14)
            make.leading.equalTo(self.subheadingLabel.snp.leading)
            make.trailing.equalTo(self.subheadingLabel.snp.trailing)
            make.bottom.equalToSuperview().inset(18)
            make.height.equalTo(self.facebookButton.snp.height)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        UtilityFunctions.addShadowTo(view: self.facebookButton)
        UtilityFunctions.addShadowTo(view: self.googleButton)
    }
}
