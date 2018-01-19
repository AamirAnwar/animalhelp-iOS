//
//  ButtonTableViewCell.swift
//  animalhelp
//
//  Created by Aamir  on 20/01/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import Foundation
import UIKit

class ButtonTableViewCell:UITableViewCell {
    let button = UIButton(type: .system)
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init with coder not implemented")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(self.button)
        
        self.button.titleLabel?.textAlignment = .center
        self.button.titleLabel?.font = CustomFontUsername
        button.layer.cornerRadius = kCornerRadius
        self.button.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(kSidePadding)
            make.trailing.equalToSuperview().inset(kSidePadding)
            make.top.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().inset(8)
            make.height.equalTo(kStandardButtonHeight)
        }
    }
    
    public func setButtonTitle(_ title:String) {
        self.button.setTitle(title, for: .normal)
    }
    
    public func setButtonTint(_ tint:UIColor) {
        self.button.setTitleColor(tint, for: .normal)
        self.button.layer.borderColor = tint.cgColor
        self.button.layer.borderWidth = 1
    }
}
