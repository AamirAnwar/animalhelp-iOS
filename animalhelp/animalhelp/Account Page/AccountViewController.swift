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

class AccountViewController:BaseViewController,GIDSignInUIDelegate {
    let kLoginCellReuseIdentifier = "SocialLoginTableViewCell"
    let kStandardListCellReuseIdentifier = "StandardListTableViewCell"
    let standardAccountItems = ["Push Notifications", "Terms and Conditions", "Feedback", "How to help"]
    let tableView = UITableView(frame: CGRect.zero, style: .plain)
    var accountItems:[String] {
        get {
            if loginManager.isLoggedIn {
                return  ["Pet Lookout", "Logout"] + standardAccountItems
            }
            return standardAccountItems
        }
    }
    let loginManager = LoginManager.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarItem.title = "Account"
        self.customNavBar.setTitle("Account")
        self.customNavBar.disableLocationButton()
        self.view.addSubview(self.tableView)
        // Register Cell Types
        self.tableView.register(SocialLoginTableViewCell.self, forCellReuseIdentifier: self.kLoginCellReuseIdentifier)
        self.tableView.register(StandardListTableViewCell.self, forCellReuseIdentifier: self.kStandardListCellReuseIdentifier)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView(frame:CGRect.zero)
        self.tableView.separatorStyle = .none
   
        self.tableView.snp.makeConstraints { (make) in
            make.top.equalTo(self.customNavBar.snp.bottom)
            make.bottom.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
    }
}

extension AccountViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        else {
            return accountItems.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:UITableViewCell!
        if indexPath.section == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: kLoginCellReuseIdentifier) as! SocialLoginTableViewCell
            cell.showBottomPaddedSeparator()
        }
        else {
            let standardCell = tableView.dequeueReusableCell(withIdentifier: kStandardListCellReuseIdentifier) as! StandardListTableViewCell
            standardCell.setTitle(accountItems[indexPath.row])
            standardCell.tintColor = CustomColorTextBlack
            if indexPath.row < self.accountItems.count - 1 {
                standardCell.showBottomPaddedSeparator()
            }
            cell = standardCell
            
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
