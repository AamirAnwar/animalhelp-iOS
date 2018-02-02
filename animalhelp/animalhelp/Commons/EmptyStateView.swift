//
//  EmptyStateView.swift
//  animalhelp
//
//  Created by Aamir  on 21/01/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import UIKit
protocol EmptyStateViewDelegate {
    func didTapEmptyStateButton()
}
class EmptyStateView: UIView {
    let messageLabel = UILabel()
    let button = UIButton(type: .system)
    var delegate:EmptyStateViewDelegate? = nil
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Init with coder not implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.messageLabel)
        self.addSubview(self.button)
        
        self.backgroundColor = UIColor.white
        self.messageLabel.numberOfLines = 0
        self.messageLabel.font = CustomFontTitleBold
        self.messageLabel.textColor = CustomColorTextBlack
        self.messageLabel.textAlignment = .center
        
        self.messageLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(kSidePadding)
            make.trailing.equalToSuperview().inset(kSidePadding)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-CustomNavigationBar.kCustomNavBarHeight).priority(100)
            make.top.greaterThanOrEqualToSuperview()
        }
        
        self.button.backgroundColor = CustomColorMainTheme
        self.button.titleLabel?.font = CustomFontButtonTitle
        self.button.titleLabel?.textAlignment = .center
        self.button.setTitleColor(UIColor.white, for: .normal)
        
        self.button.snp.makeConstraints { (make) in
            make.top.equalTo(self.messageLabel.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(kSidePadding)
            make.trailing.equalToSuperview().inset(kSidePadding)
            make.height.equalTo(kStandardButtonHeight)
        }
        self.button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }

    @objc func buttonTapped() {
        self.delegate?.didTapEmptyStateButton()
    }
    
    func setMessage(_ message:String, buttonTitle:String) {
        self.messageLabel.text = message
        self.button.setTitle(buttonTitle, for: .normal)
    }
}
