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
import MessageUI

// Data Structure for account items
struct AccountItem {
    static let kAccountItemTermsAndConditionsID = 1
    static let kAccountItemFeedbackID = 2
    static let kAccountItemHowToHelpID = 3
    static let kAccountItemLogoutID = 4
    var id:Int
    var title:String
    var action:()->Void
}

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
    var standardAccountItems:[AccountItem] {
        get {
            // Terms and conditions
            let tcItem = AccountItem.init(id: AccountItem.kAccountItemTermsAndConditionsID, title: "Terms and Conditions") {
                self.showTCPage()
            }
            // Feedback
            let fbItem = AccountItem.init(id: AccountItem.kAccountItemFeedbackID, title: "Feedback") {
                self.showFeedbackPage()
            }
            // How to help
            let helpItem = AccountItem.init(id: AccountItem.kAccountItemHowToHelpID, title: "How to help") {
                self.showHowToContributePage()
            }
            return [tcItem,fbItem,helpItem]
        }
    }
    
    var accountItems:[AccountItem] {
        get {
            if loginManager.isLoggedIn {
                return  self.standardAccountItems + [AccountItem.init(id: AccountItem.kAccountItemLogoutID, title: "Logout", action: {
                    self.showLogoutAlert()
                })]
            }
            return self.standardAccountItems
        }
    }
    let tableView = UITableView(frame: CGRect.zero, style: .plain)
    let profileImageView = UIImageView()
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
        self.setupTableView()
        NotificationCenter.default.addObserver(self, selector: #selector(userAuthDidChange), name: kNotificationLoggedInSuccessfully.name, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(userAuthDidChange), name: kNotificationLoggedOutSuccessfully.name, object: nil)
        self.refreshUserDetails()
    }
    
    func setupTableView() {
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
    }
    
    func setupProfileImageView() {
        self.view.addSubview(self.profileImageView)
        self.profileImageView.contentMode = .scaleAspectFill
        self.profileImageView.clipsToBounds = true
        self.profileImageView.backgroundColor = CustomColorLightGray
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
    
    @objc func userAuthDidChange() {
        self.profileImageView.isHidden = (self.loginManager.isLoggedIn == false)
        self.tableView.reloadData()
    }
    
    func showTCPage() {
        let vc = TermsAndConditionsViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showHowToContributePage() {
        let vc = ContributeViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showFeedbackPage() {
        guard MFMailComposeViewController.canSendMail() else {return}
        let mailVC = MFMailComposeViewController()
        mailVC.setSubject("Feedback")
        mailVC.mailComposeDelegate = self
        mailVC.setToRecipients([kFeedbackEmailAddress])
        self.present(mailVC, animated: true)
    }
    
    func showLogoutAlert() {
        let alertController = UIAlertController(title: "Logout", message: "Are you sure you want to logout", preferredStyle: .alert)
        let logOutAction = UIAlertAction.init(title: "Logout", style: .destructive) { (action) in
            self.loginManager.logout()
        }
        let cancel = UIAlertAction.init(title: "Cancel", style: .cancel)
        alertController.addAction(logOutAction)
        alertController.addAction(cancel)
        present(alertController, animated:true)
    }
    
    func refreshUserDetails() {
        
        if let url = self.loginManager.currentUser?.profilePictureURL?.absoluteString {
            self.profileImageView.setImage(WithURL: url)
        }
        else if let url = UserDefaults.standard.value(forKey: kUserProfileImageURLKey) as? String {
            self.profileImageView.setImage(WithURL: url)
        }
        else {
            self.profileImageView.image = nil
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
                        return UtilityFunctions.getTransparentCell(tableView: tableView, height:kProfileImageHeight,reuseIdentifier:kEmptyCellReuseIdentifier)
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
                self.accountItems[indexPath.row].action()
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        UtilityFunctions.expandImageWith(scrollView: scrollView, view: self.profileImageView, currentHeight: &self.currentHeight, minRequiredHeight: kProfileImageHeight)
    }
    
    func getStandardSettingsCell(tableView:UITableView, indexPath:IndexPath) -> StandardListTableViewCell {
        let standardCell = tableView.dequeueReusableCell(withIdentifier: kStandardListCellReuseIdentifier) as! StandardListTableViewCell
        standardCell.setTitle(accountItems[indexPath.row].title)
        standardCell.tintColor = CustomColorTextBlack
        // Show a bottom separator for all cells except the last
        if indexPath.row < self.accountItems.count - 1 {
            standardCell.showBottomPaddedSeparator()
        }
        else {
            if loginManager.isLoggedIn {
                standardCell.showsDisclosure(false)
            }
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
        usernameCell.showsDisclosure(false)
        usernameCell.selectionStyle = .none
        
        var name:String? = nil
        // User name
        if let username = self.loginManager.currentUser?.name {
            name = username
        }
        else if let username = UserDefaults.standard.value(forKey: kUserProfileNameKey) as? String {
            name = username
        }
        guard let username = name  else {return usernameCell}
        usernameCell.setTitle(username)
        usernameCell.setTitleFont(CustomFontUsername)
        return usernameCell
    }
}

extension AccountViewController:LoginManagerDelegate {
    func didUpdateUserInfo() {
        self.refreshUserDetails()
        self.tableView.reloadData()
    }
}

extension AccountViewController:MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
           
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
