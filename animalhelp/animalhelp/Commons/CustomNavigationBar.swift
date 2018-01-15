//
//  CustomNavigationBar.swift
//  animalhelp
//
//  Created by Aamir  on 16/01/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import Foundation
import UIKit

protocol CustomNavigationBarDelegate {
    func didTapLocationButton()
    func didTapRightBarButton()
}

class CustomNavigationBar:UIView {
    static let kCustomNavBarHeight = 64
    var delegate:CustomNavigationBarDelegate? = nil
    let locationButton:UIButton = {
        let button = UIButton(type:.system)
        button.setTitleColor(CustomColorTextBlack, for: .normal)
        button.titleLabel?.font = CustomFontTitleBold
        
        // TODO
        button.setTitle("Delhi", for: .normal)
        return button
    }()
    
    var rightBarButton:UIButton? {
        didSet {
            if let rightBarButton = self.rightBarButton {
            self.addSubview(rightBarButton)
            rightBarButton.snp.makeConstraints { (make) in
                make.centerY.equalTo(self.locationButton.snp.centerY)
                make.trailing.equalToSuperview().inset(8)
                make.leading.greaterThanOrEqualTo(self.locationButton.snp.trailing).offset(8)
            }
            rightBarButton.addTarget(self, action: #selector(rightBarButtonTapped), for: .touchUpInside)
            }
        }
    }
    
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
        self.locationButton.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview().offset(10)
            make.centerX.equalToSuperview()
        }
       
        
        self.locationButton.addTarget(self, action: #selector(locationButtonTapped), for: .touchUpInside)
        
   }
    
    public func setTitle(_ title:String) {
        self.locationButton.setTitle(title, for: .normal)
    }
    
    public func disableLocationButton() {
        self.locationButton.isEnabled = false
    }
    
    public func enableLocationButton() {
        self.locationButton.isEnabled = true
    }
    
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let shadowPath = UIBezierPath(rect: self.bounds)
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.layer.shadowOpacity = 0.3
        self.layer.shadowRadius = 10
        self.layer.shadowPath = shadowPath.cgPath
    }
    
    @objc func locationButtonTapped() {
        self.delegate?.didTapLocationButton()
    }
    
    @objc func rightBarButtonTapped() {
        self.delegate?.didTapRightBarButton()
    }
    
    
}
