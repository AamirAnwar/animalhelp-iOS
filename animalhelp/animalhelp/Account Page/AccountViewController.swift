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
    let cellIdentifier = "AccountViewControllerCell"
    let tableView = UITableView(frame: CGRect.zero, style: .plain)
    let accountItems = ["Profile", "Pet Lookout" ,"Push Notifications", "Email Alerts", "Terms and Conditions", "Feedback", "How to help", "Logout"]
    let googleSignInButton = GIDSignInButton()
    let fbLoginButton = LoginButton(readPermissions: [.publicProfile])

    override func viewDidLoad() {
        super.viewDidLoad()
        googleSignInButton.style = GIDSignInButtonStyle(rawValue: 1)!
        GIDSignIn.sharedInstance().uiDelegate = self

        self.tabBarItem.title = "Account"
        self.customNavBar.setTitle("Account")
        self.customNavBar.disableLocationButton()
        self.view.addSubview(self.tableView)
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: self.cellIdentifier)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView(frame:CGRect.zero)
        
        self.view.addSubview(self.googleSignInButton)
        self.googleSignInButton.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().inset(10)
            make.top.equalTo(self.customNavBar.snp.bottom)
        }
        
        self.view.addSubview(self.fbLoginButton)
        self.fbLoginButton.snp.makeConstraints { (make) in
            make.leading.equalTo(self.googleSignInButton)
            make.trailing.equalTo(self.googleSignInButton)
            make.height.equalTo(self.googleSignInButton.snp.height)
            make.top.equalTo(self.googleSignInButton.snp.bottom).offset(10)
        }
        self.tableView.snp.makeConstraints { (make) in
            make.top.equalTo(self.fbLoginButton.snp.bottom)
            make.bottom.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
    }
}

extension AccountViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accountItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)!
        cell.textLabel?.text = accountItems[indexPath.row]
        return cell
        
    }
}
