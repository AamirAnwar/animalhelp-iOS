//
//  InfoPopView.swift
//  animalhelp
//
//  Created by Aamir  on 21/01/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import UIKit

class InfoPopView: UIView {
    let titleLabel:UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = CustomFontTitleBold
        label.textColor = CustomColorTextBlack
        label.numberOfLines = 0
        return label
        
    }()
    
    let subtitleLabel:UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = CustomFontSmallBodyMedium
        label.textColor = CustomColorDarkGray
        label.numberOfLines = 0
        return label
    }()
    
    let containerView = UIView()
    let backgroundImageView = UIImageView()
    let button = UIButton.getRoundedRectButon()
    required init?(coder aDecoder: NSCoder) {
        fatalError("init with coder not implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius = kCornerRadius
        self.backgroundColor = UIColor.clear
        
        self.addSubview(self.backgroundImageView)
        self.addSubview(self.containerView)
        self.containerView.addSubview(self.button)
        self.containerView.addSubview(self.titleLabel)
        self.containerView.addSubview(self.subtitleLabel)
        
        self.backgroundImageView.contentMode = .scaleAspectFill
        self.backgroundImageView.clipsToBounds = true
        
        self.backgroundImageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        self.containerView.backgroundColor = UIColor.white
        self.containerView.layer.cornerRadius = kCornerRadius
        self.containerView.snp.makeConstraints({ (make) in
            make.center.equalToSuperview().offset(UIScreen.main.bounds.size.height)
            make.leading.equalToSuperview().offset(kSidePadding)
            make.trailing.equalToSuperview().inset(kSidePadding)
            make.height.greaterThanOrEqualTo(kMinPopUpHeight)
        })
        
        self.titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(13)
            make.leading.equalToSuperview().offset(kSidePadding)
            make.trailing.equalToSuperview().inset(kSidePadding)
        }
        
        self.subtitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(8)
            make.leading.equalTo(self.titleLabel.snp.leading)
            make.trailing.equalTo(self.titleLabel.snp.trailing)
            make.bottom.lessThanOrEqualTo(self.button.snp.top).inset(13)
        }
        
        self.button.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().inset(20)
            make.leading.equalTo(self.subtitleLabel)
            make.trailing.equalTo(self.subtitleLabel)
        }
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.didTapPopUp))
        self.backgroundImageView.isUserInteractionEnabled = true
        self.backgroundImageView.addGestureRecognizer(tap)
        self.backgroundImageView.alpha = 0
        
    }
    
    @objc func didTapPopUp() {
        UIView.animate(withDuration: 0.3, animations: {
            self.backgroundImageView.alpha = 0
            self.containerView.transform = self.containerView.transform.translatedBy(x: 0, y: UIScreen.main.bounds.size.height)
        }) { (_) in
            self.removeFromSuperview()
        }
    }

    func setTitle(title:String, subtitle:String, buttonTitle:String) {
        self.titleLabel.text = title
        self.subtitleLabel.text = subtitle
        self.button.setTitle(buttonTitle, for: .normal)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        UtilityFunctions.addShadowTo(view: self.containerView)
        self.layoutIfNeeded()
        self.containerView.snp.updateConstraints({ (make) in
            make.center.equalToSuperview()
        })
        UIView.animate(withDuration: 0.3, delay: 0.1, options: [], animations: {
            self.backgroundImageView.alpha = 1
            self.layoutIfNeeded()
        }, completion: nil)
        
    }
}
