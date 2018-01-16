//
//  BaseViewController.swift
//  animalhelp
//
//  Created by Aamir  on 04/01/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import Foundation
import UIKit
class BaseViewController:UIViewController, CustomNavigationBarDelegate,UIGestureRecognizerDelegate {

    let customNavBar = CustomNavigationBar()
    
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
        self.view.backgroundColor = UIColor.white
        self.view.addSubview(customNavBar)
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        customNavBar.delegate = self
        customNavBar.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }        
    }
    
    func didTapRightBarButton() {
        
    }
    
    func didTapLocationButton() {
        
    }
}
