//
//  SettingsViewController.swift
//  animalhelp
//
//  Created by Aamir  on 04/01/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import Foundation
import UIKit
class AccountViewController:BaseViewController {
    let cellIdentifier = "AccountViewControllerCell"
    let tableView = UITableView(frame: CGRect.zero, style: .plain)
    let accountItems = ["Profile", "Pet Lookout" ,"Push Notifications", "Email Alerts", "Terms and Conditions", "Feedback", "How to help", "Logout"]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarItem.title = "Account"
        self.customNavBar.setTitle("Account")
        self.customNavBar.disableLocationButton()
        self.view.addSubview(self.tableView)
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: self.cellIdentifier)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView(frame:CGRect.zero)
        self.tableView.snp.makeConstraints { (make) in
            make.top.equalTo(self.customNavBar.snp.bottom)
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
