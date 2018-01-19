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
        
        // Default setting
        self.showsDisclosure(true)
    }
    
    public func setTitle(_ title:String) {
        self.titleLabel.text = title
    }
    
    public func setTitleFont(_ font:UIFont) {
        self.titleLabel.font = font
    }
    
    public func showsDisclosure(_ show:Bool) {
        if show {
            self.accessoryType = .disclosureIndicator
        }
        else {
            self.accessoryType = .none
        }
        
    }
}


