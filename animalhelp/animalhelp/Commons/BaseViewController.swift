//
//  BaseViewController.swift
//  animalhelp
//
//  Created by Aamir  on 04/01/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import Foundation
import UIKit
class BaseViewController:UIViewController, CustomNavigationBarDelegate,UIGestureRecognizerDelegate,EmptyStateViewDelegate {

    let customNavBar = CustomNavigationBar()
    let emptyStateView = EmptyStateView()
    var navBarHeight:CGFloat {
        get {
            if let navBarHeight = self.navigationController?.navigationBar.frame.size.height {
                return navBarHeight
            }
            else {
                return 0.0
            }
        }
    }
    
    var tabBarHeight:CGFloat {
        get {
            if let tabBar = self.tabBarController?.tabBar {
                return tabBar.frame.size.height
            }
            else {
                return 0.0
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(locationChanged), name: kNotificationUserLocationChanged.name, object: nil)
        self.view.backgroundColor = UIColor.white
        self.view.addSubview(customNavBar)
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.createEmptyStateView()
        self.setUserLocationInNavBar()
        customNavBar.delegate = self
        customNavBar.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        
        self.customNavBar.shouldShowBackButton(false)
        if let nav = self.navigationController {
            if nav.viewControllers.count > 1 && nav.viewControllers.first! != self {
                self.customNavBar.shouldShowBackButton(true)
            }
        }
        
    }
    
    
    fileprivate func createEmptyStateView() {
        view.addSubview(self.emptyStateView)
        self.emptyStateView.snp.makeConstraints { (make) in
            make.top.equalTo(self.customNavBar.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        self.emptyStateView.messageLabel.text = "Sorry!\n No clinics around you :("
        self.emptyStateView.button.setTitle("Try a different location", for: .normal)
        self.emptyStateView.isHidden = true
        self.emptyStateView.delegate = self
    }
    
    func showEmptyStateView() {
        self.view.bringSubview(toFront: self.emptyStateView)
        self.emptyStateView.isHidden = false
    }
    
    func hideEmptyStateView() {
        self.emptyStateView.isHidden = true
    }
    

    
    func didTapRightBarButton() {
        
    }
    
    func didTapLocationButton() {
        
    }
    open func didTapEmptyStateButton() {
        
    }
    
    func showLoader() {
        self.customNavBar.showLoader()
    }
    
    func hideLoader() {
        self.customNavBar.hideLoader()
    }
    
    open func didTapBackButton() {
        self.navigationController?.popViewController(animated: true)
    }
    
    open func didTapCrossButton() {
        self.dismiss(animated: true)
    }
    
    @objc func locationChanged() {
        self.setUserLocationInNavBar()
    }
    
    fileprivate func setUserLocationInNavBar() {
        guard let locality = LocationManager.sharedManager.userLocality else {return}
        self.customNavBar.locationButton.setTitle(nil, for: .normal)
        let mutableAttrString = NSMutableAttributedString.init(string: "\(locality) ", attributes: [NSAttributedStringKey.font:CustomFontTitleBold, NSAttributedStringKey.foregroundColor:CustomColorTextBlack])
        let chevronString = NSAttributedString.init(string: NSString.fontAwesomeIconString(forEnum: FAIcon.FAChevronDown), attributes: [
            NSAttributedStringKey.foregroundColor:CustomColorMainTheme,
            NSAttributedStringKey.font: UIFont.init(name: kFontAwesomeFamilyName, size: 16)!,
            NSAttributedStringKey.baselineOffset: 2
            ])
        mutableAttrString.append(chevronString)
        self.customNavBar.setAttributedTitle(mutableAttrString)
    }
    
    
}

