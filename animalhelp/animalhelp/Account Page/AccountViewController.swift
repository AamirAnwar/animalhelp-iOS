//
//  SettingsViewController.swift
//  animalhelp
//
//  Created by Aamir  on 04/01/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import Foundation
import UIKit
import GoogleSignIn
import FacebookLogin
import SnapKit

enum AccountSection:Int {
    case TransparentProfile
    case LoginOrSignUp
    case Username
    case Settings
    static var count:Int {return AccountSection.Settings.rawValue + 1}
}

class AccountViewController:BaseViewController,GIDSignInUIDelegate {
    let kEmptyCellReuseIdentifier = "CustomEmptyTableViewCell"
    let kLoginCellReuseIdentifier = "SocialLoginTableViewCell"
    let kStandardListCellReuseIdentifier = "StandardListTableViewCell"
    let kUsernameCellReuseIdentifier = "UserNameCell"
    let kProfileImageBounceFactor:CGFloat = 1.5
    let standardAccountItems = ["Push Notifications", "Terms and Conditions", "Feedback", "How to help"]
    let tableView = UITableView(frame: CGRect.zero, style: .plain)
    let profileImageView = UIImageView()
    var accountItems:[String] {
        get {
            if loginManager.isLoggedIn {
                return  ["Pet Lookout"] + standardAccountItems + ["Logout"]
            }
            return standardAccountItems
        }
    }
    let loginManager = LoginManager.sharedInstance
    var heightConstraint:Constraint? = nil
    var currentHeight = kProfileImageHeight
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loginManager.uiDelegate = self
        self.loginManager.delegate = self
        self.tabBarItem.title = "Account"
        self.customNavBar.setTitle("Account")
        self.customNavBar.disableLocationButton()
        self.setupProfileImageView()
        
        self.view.addSubview(self.tableView)
        // Register Cell Types
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: self.kEmptyCellReuseIdentifier)
        self.tableView.register(SocialLoginTableViewCell.self, forCellReuseIdentifier: self.kLoginCellReuseIdentifier)
        self.tableView.register(StandardListTableViewCell.self, forCellReuseIdentifier: self.kStandardListCellReuseIdentifier)
        self.tableView.register(StandardListTableViewCell.self, forCellReuseIdentifier: self.kUsernameCellReuseIdentifier)
        self.tableView.delaysContentTouches = false
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.backgroundColor = UIColor.clear
        self.tableView.tableFooterView = UIView(frame:CGRect.zero)
        self.tableView.separatorStyle = .none
        self.tableView.snp.makeConstraints { (make) in
            make.top.equalTo(self.customNavBar.snp.bottom)
            make.bottom.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(userAuthDidChange), name: kNotificationLoggedInSuccessfully.name, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(userAuthDidChange), name: kNotificationLoggedOutSuccessfully.name, object: nil)
    }
    
    @objc func userAuthDidChange() {
        self.profileImageView.isHidden = (self.loginManager.isLoggedIn == false)
        self.tableView.reloadData()
    }
    
    func setupProfileImageView() {
        self.view.addSubview(self.profileImageView)
        self.profileImageView.image = #imageLiteral(resourceName: "defaultProfileImage")
        self.profileImageView.contentMode = .scaleAspectFill
        self.profileImageView.clipsToBounds = true
        self.profileImageView.snp.makeConstraints { (make) in
            make.top.equalTo(self.customNavBar.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            self.heightConstraint = make.height.equalTo(kProfileImageHeight).constraint
        }
        if self.loginManager.isLoggedIn == false {
            self.profileImageView.isHidden = true
        }
    }
}

extension AccountViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return AccountSection.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let accountSection = AccountSection(rawValue: section) {
            switch accountSection {
            case .TransparentProfile, .Username:
                if self.loginManager.isLoggedIn {
                    return 1
                }
                
            case .LoginOrSignUp:
                if self.loginManager.isLoggedIn == false {
                    return 1
                }
                
            case .Settings: return self.accountItems.count
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if let accountSection = AccountSection(rawValue: indexPath.section) {
            if self.loginManager.isLoggedIn && accountSection == .TransparentProfile {
                return kProfileImageHeight
            }
        }
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let accountSection = AccountSection(rawValue: indexPath.section) {
                switch accountSection {
                case .TransparentProfile:
                    if self.loginManager.isLoggedIn {
                        return self.getTransparentCell(tableView: tableView)
                    }
                    
                case .Settings: return self.getStandardSettingsCell(tableView: tableView, indexPath: indexPath)
                case .Username:
                    if self.loginManager.isLoggedIn {
                        return self.getUsernameCell(tableView: tableView)
                    }
                case .LoginOrSignUp:
                    if self.loginManager.isLoggedIn == false {
                        return self.getSocialLoginCell(tableView: tableView)
                    }
                }
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let section = AccountSection(rawValue: indexPath.section) {
            if section == .Settings {
                guard indexPath.row < self.accountItems.count else {return}
                if self.accountItems[indexPath.row] == "Logout" {
                    self.loginManager.logout()
                }
            }
        }
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let y = scrollView.contentOffset.y
        if y < 0 {
            if let _ = self.heightConstraint {
                if self.currentHeight < kProfileImageHeight {
                    self.currentHeight = kProfileImageHeight
                }
                else {
                    self.currentHeight = kProfileImageHeight - kProfileImageBounceFactor*y
                }
                self.profileImageView.snp.updateConstraints({ (make) in
                    self.heightConstraint = make.height.equalTo(self.currentHeight).constraint
                })
            }
        }
    }
    
    func getTransparentCell(tableView:UITableView) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kEmptyCellReuseIdentifier)!
        let view = UIView()
        cell.backgroundColor = UIColor.clear
        cell.contentView.addSubview(view)
        cell.selectionStyle = .none
        view.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            make.height.equalTo(kProfileImageHeight)
        }
        return cell
    }
    
    func getStandardSettingsCell(tableView:UITableView, indexPath:IndexPath) -> StandardListTableViewCell {
        let standardCell = tableView.dequeueReusableCell(withIdentifier: kStandardListCellReuseIdentifier) as! StandardListTableViewCell
        standardCell.setTitle(accountItems[indexPath.row])
        standardCell.tintColor = CustomColorTextBlack
        // Show a bottom separator for all cells except the last
        if indexPath.row < self.accountItems.count - 1 {
            standardCell.showBottomPaddedSeparator()
        }
        return standardCell
    }
    
    func getSocialLoginCell(tableView:UITableView) -> SocialLoginTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kLoginCellReuseIdentifier) as! SocialLoginTableViewCell
        cell.showBottomPaddedSeparator()
        cell.selectionStyle = .none
        cell.delegate = self
        return cell
    }
    
    func getUsernameCell(tableView:UITableView) -> StandardListTableViewCell {
        let usernameCell = tableView.dequeueReusableCell(withIdentifier: kUsernameCellReuseIdentifier) as! StandardListTableViewCell
        
        guard let user = self.loginManager.currentUser else {return usernameCell}
        
        usernameCell.setTitle(user.name)
        usernameCell.setTitleFont(CustomFontUsername)
        usernameCell.showsDisclosure(false)
        usernameCell.selectionStyle = .none
        return usernameCell
    }
}

extension AccountViewController:LoginManagerDelegate {
    func didUpdateUserInfo() {
        self.tableView.reloadData()
    }
}

extension AccountViewController:SocialLoginTableViewCellDelegate {
    func didTapFacebookLogin() {
        self.loginManager.loginWithFacebook()
    }
    
    func didTapGoogleLogin() {
        self.loginManager.loginWithGoogle()
    }
}
