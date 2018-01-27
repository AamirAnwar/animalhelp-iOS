//
//  StandardListTableViewCell.swift
//  animalhelp
//
//  Created by Aamir  on 19/01/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import Foundation
import UIKit

class StandardListTableViewCell:UITableViewCell {
    
    fileprivate let titleLabel:UILabel = {
        let label = UILabel()
        label.font = CustomFontBodyMedium
        label.textColor = CustomColorTextBlack
        label.numberOfLines = 0
        return label
        
    }()
    
    fileprivate let disclosureChevronLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.init(name: kFontAwesomeFamilyName, size: 14)
        label.textColor = CustomColorMainTheme
        label.text = NSString.fontAwesomeIconString(forEnum: FAIcon.FAChevronRight)
        return label
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Init with coder not implemented")
    }
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(kSidePadding)
            make.trailing.equalToSuperview().inset(kSidePadding)
            make.top.equalToSuperview().offset(13)
            make.bottom.equalToSuperview().inset(13)
        }
        
        self.contentView.addSubview(self.disclosureChevronLabel)
        self.disclosureChevronLabel.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().inset(kSidePadding)
            make.centerY.equalToSuperview()
        }
        
        // Default setting
        self.showsDisclosure(true)
    }
    
    public func setTitle(_ title:String) {
        self.titleLabel.text = title
    }
    
    public func setTitleFont(_ font:UIFont) {
        self.titleLabel.font = font
    }
    
    public func setTitleColor(_ color:UIColor) {
        self.titleLabel.textColor = color
    }
    
    public func showsDisclosure(_ show:Bool) {
        self.disclosureChevronLabel.isHidden = !show
    }
    
    public func updateVerticalPadding(with padding:CGFloat) {
        self.titleLabel.snp.updateConstraints { (make) in
            make.top.equalToSuperview().offset(padding)
            make.bottom.equalToSuperview().inset(padding)
        }
    }
}


