//
//  CustomNavigationBar.swift
//  animalhelp
//
//  Created by Aamir  on 16/01/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

let kLoaderAnimationKey = "loader_animation"
let kFontSize:CGFloat = 20
let kBackButtonSize:CGFloat = 44

protocol CustomNavigationBarDelegate {
    func didTapLocationButton()
    func didTapRightBarButton()
    func didTapBackButton()
}

class CustomNavigationBar:UIView {
    static let kCustomNavBarHeight = 64
    var delegate:CustomNavigationBarDelegate? = nil
    let locationButton:UIButton = {
        let button = UIButton(type:.system)
        button.setTitleColor(CustomColorTextBlack, for: .normal)
        button.titleLabel?.font = CustomFontTitleBold
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.textAlignment = .center
        return button
    }()
    
    let backButton:UIButton = {
        let button = UIButton(type:.system)
        button.setTitleColor(CustomColorTextBlack, for: .normal)
        button.titleLabel?.font = UIFont.init(name: kFontAwesomeFamilyName, size: kFontSize)
        button.contentEdgeInsets = UIEdgeInsetsMake(0, -(kBackButtonSize/2), 0, 0)
        return button
    }()
    
    fileprivate var locationButtonCenterY:ConstraintMakerEditable?
    
    var rightBarButton:UIButton? {
        didSet {
            if let rightBarButton = self.rightBarButton {
                self.addSubview(rightBarButton)
                rightBarButton.snp.makeConstraints { (make) in
                    make.centerY.equalTo(self.locationButton.snp.centerY)
                    make.trailing.equalToSuperview().inset(kSidePadding)
                    make.leading.greaterThanOrEqualTo(self.locationButton.snp.trailing).offset(8)
                }
                rightBarButton.addTarget(self, action: #selector(rightBarButtonTapped), for: .touchUpInside)
            }
        }
    }
    
    let gradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        
        // Configure the gradient here
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        let colors = [
            CustomColorMainTheme.withAlphaComponent(0.0).cgColor,
            CustomColorMainTheme.cgColor,
            CustomColorMainTheme.withAlphaComponent(0.0).cgColor
        ]
        gradientLayer.colors = colors
        let locations: [NSNumber] = [
            0.25,
            0.5,
            0.75
        ]
        gradientLayer.locations = locations
        
        return gradientLayer
    }()
    var loaderIsActive = false
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init with coder not implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        self.snp.makeConstraints { (make) in
            make.height.equalTo(CustomNavigationBar.kCustomNavBarHeight)
        }
        self.addSubview(self.locationButton)
        self.addSubview(self.backButton)
        
        self.locationButton.snp.makeConstraints { (make) in
            self.locationButtonCenterY = make.centerY.equalToSuperview().offset(10)
            make.centerX.equalToSuperview()
        }
        self.locationButton.addTarget(self, action: #selector(locationButtonTapped), for: .touchUpInside)
        
        self.backButton.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(kSidePadding)
            make.centerY.equalTo(self.locationButton.snp.centerY)
            make.width.equalTo(kBackButtonSize)
            make.height.equalTo(kBackButtonSize)
            make.trailing.lessThanOrEqualTo(self.locationButton)
        }
        self.backButton.setTitle(NSString.fontAwesomeIconString(forEnum: FAIcon.FAChevronLeft), for: .normal)
        self.backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        
   }
    
    public func setTitle(_ title:String) {
        self.locationButton.setTitle(title, for: .normal)
    }
    
    public func setAttributedTitle(_ title:NSAttributedString) {
        self.locationButton.setTitle(nil, for: .normal)
        self.locationButtonCenterY?.offset(5)
        self.locationButton.setAttributedTitle(title, for: .normal)
    }
    
    public func enableRightButtonWithTitle(_ title:String) {
        guard self.rightBarButton == nil else {return}
        let button = UIButton(type:.system)
        button.setTitleColor(CustomColorMainTheme, for: .normal)
        button.titleLabel?.font = CustomFontBodyMedium
        button.setTitle(title, for: .normal)
        self.rightBarButton = button
    }
    
    public func enableRightButtonWithIcon(icon:FAIcon) {
        guard self.rightBarButton == nil else {return}
        let button = UIButton(type:.system)
        button.setTitleColor(CustomColorMainTheme, for: .normal)
        button.titleLabel?.font = UIFont(name: kFontAwesomeFamilyName, size: kFontSize)
        button.setTitle(NSString.fontAwesomeIconString(forEnum: icon), for: .normal)
        self.rightBarButton = button
    }
    
    public func setRightButtonIcon(icon:FAIcon) {
        self.rightBarButton?.setTitle(NSString.fontAwesomeIconString(forEnum: icon), for: .normal)
    }
    
    public func disableLocationButton() {
        self.locationButton.isEnabled = false
    }
    
    public func enableLocationButton() {
        self.locationButton.isEnabled = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        gradientLayer.frame = CGRect(
            x: -bounds.size.width,
            y: bounds.size.height - 5,
            width: 3 * bounds.size.width,
            height: 5)
    }
    
    
    @objc func locationButtonTapped() {
        self.delegate?.didTapLocationButton()
    }
    
    @objc func rightBarButtonTapped() {
        self.delegate?.didTapRightBarButton()
    }
    
    func showLoader() {
        self.loaderIsActive = true
        layer.addSublayer(gradientLayer)
        let gradientAnimation = CABasicAnimation(keyPath: "locations")
        gradientAnimation.fromValue = [0.0, 0.0, 0.25]
        gradientAnimation.toValue = [0.75, 1.0, 1.0]
        gradientAnimation.duration = 1
        gradientAnimation.repeatCount = Float.infinity
        gradientLayer.add(gradientAnimation, forKey: kLoaderAnimationKey)
    }
    
    func hideLoader() {
        gradientLayer.removeAnimation(forKey: kLoaderAnimationKey)
        gradientLayer.removeFromSuperlayer()
        self.loaderIsActive = false
    }
    
    func shouldShowBackButton(_ shouldShow:Bool) {
        self.backButton.isHidden = !shouldShow
    }
    
    override func didMoveToWindow() {
        if let _ = self.window, self.loaderIsActive {
            self.showLoader()
        }
    }
    
    @objc func backButtonTapped() {
        self.delegate?.didTapBackButton()
    }
    
}
