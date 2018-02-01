//
//  BaseViewController.swift
//  animalhelp
//
//  Created by Aamir  on 04/01/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import Foundation
import UIKit
let kStatusBarAnimationDuration = 0.4

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
    
    public var showStatusBar = true
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .default
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        get {
            return !showStatusBar
        }
    }
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        get {
            return .slide
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(locationChanged), name: kNotificationUserLocationChanged.name, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didShowStatusBar), name: kNotificationDidShowStatusBar.name, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didHideStatusBar), name: kNotificationDidHideStatusBar.name, object: nil)
        self.view.backgroundColor = UIColor.white
        self.view.addSubview(customNavBar)
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.createEmptyStateView()
        UtilityFunctions.setUserLocationInNavBar(customNavBar: self.customNavBar)
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.customNavBar.loaderIsActive {
           self.customNavBar.showLoader()
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
        self.emptyStateView.messageLabel.text = "Sorry!\n Something went wrong :("
        self.emptyStateView.button.setTitle("Try Again", for: .normal)
        self.emptyStateView.isHidden = true
        self.emptyStateView.delegate = self
    }
    
    func showEmptyStateView() {
        self.view.bringSubview(toFront: self.emptyStateView)
        self.emptyStateView.isHidden = false
    }
    
    func showEmptyStateView(withMessage message:String, buttonTitle:String) {
        self.emptyStateView.setMessage(message, buttonTitle: buttonTitle)
        self.showEmptyStateView()
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
        
    }
    
    //MARK: Status bar visibility
    public func setStatusBarVisibility(shouldShow isVisible:Bool,withCompletion completion:(()->Void)?) {
        UIView.animate(withDuration: kStatusBarAnimationDuration, animations: {
            self.showStatusBar = isVisible
            self.setNeedsStatusBarAppearanceUpdate()
        }, completion: { (_) in
            if isVisible {
                NotificationCenter.default.post(kNotificationDidShowStatusBar)
            }
            else {
                NotificationCenter.default.post(kNotificationDidHideStatusBar)
            }
            completion?()
        })
    }
    
    @objc func didHideStatusBar() {
        guard self.showStatusBar == true else {return}
        UIView.animate(withDuration: kStatusBarAnimationDuration, animations: {
            self.showStatusBar = false
            self.setNeedsStatusBarAppearanceUpdate()
        })
    }
    
    @objc func didShowStatusBar() {
        guard self.showStatusBar == false else {return}
        UIView.animate(withDuration: kStatusBarAnimationDuration, animations: {
            self.showStatusBar = true
            self.setNeedsStatusBarAppearanceUpdate()
        })
    }
}
