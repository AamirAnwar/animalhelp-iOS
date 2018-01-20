//
//  MissingPetDetailTableViewCell.swift
//  animalhelp
//
//  Created by Aamir  on 19/01/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import Foundation
import UIKit
class ListItemDetailTableViewCell:UITableViewCell {
    fileprivate let titleLabel:UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = CustomFontHeadingSmall
        label.textColor = CustomColorTextBlack
        return label
    }()

    fileprivate let subtitleLabel:UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = CustomFontSmallBodyMedium
        label.textColor = CustomColorLightGray
        return label
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Init with coder not implemented")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(self.titleLabel)
        self.contentView.addSubview(self.subtitleLabel)
        self.selectionStyle = .none
        self.titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview().offset(kSidePadding)
            make.trailing.equalToSuperview().inset(kSidePadding)
        }
        
        self.subtitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(2)
            make.leading.equalTo(self.titleLabel.snp.leading)
            make.trailing.equalTo(self.titleLabel.snp.trailing)
            make.bottom.equalToSuperview().inset(8)
        }
    }
    
    public func setTitle(_ title:String, subtitle:String) {
        self.titleLabel.text = title
        self.subtitleLabel.text = subtitle
    }
    public func setTitleFont(_ font:UIFont) {
        self.titleLabel.font = font
    }
    
    public func setSubtitleTextColor(_ color:UIColor) {
        self.subtitleLabel.textColor = color
    }
}
