//
//  ContributeViewController.swift
//  animalhelp
//
//  Created by Aamir  on 20/01/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import Foundation

class ContributeViewController:BaseViewController {
    
    let tableView = UITableView(frame: CGRect.zero, style: .plain)
    let kCellReuseID = "ContributeCellReuseIdentifier"
    
    var tableData:[(title:String, detailText:String)] {
        get {
            var data = [(title:String, detailText:String)]()
            data += [("Spreading the word", "Enabling notifications allows us to notify you on any updates and developments when searching for a missing pet")]
            
            data += [("Helping catalog and verifying help centers", "Enabling notifications allows us to notify you on any updates and developments when searching for a missing pet")]
            
            data += [("Sending stories and feedback","Enabling notifications allows us to notify you on any updates and developments when searching for a missing pet")]
            return data
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customNavBar.setTitle("How to help")
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { (make) in
            make.top.equalTo(self.customNavBar.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
        self.tableView.tableFooterView = UIView(frame:CGRect.zero)
        self.tableView.register(ListItemDetailTableViewCell.self, forCellReuseIdentifier: self.kCellReuseID)
        
    }
}
extension ContributeViewController:UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.kCellReuseID) as! ListItemDetailTableViewCell
        cell.setTitleFont(CustomFontBodyMedium)
        let (title,subtitle) = tableData[indexPath.row]
        cell.setTitle(title, subtitle: subtitle)
        if indexPath.row < self.tableData.count - 1 {
            cell.showBottomPaddedSeparator()
        }
        return cell
    }
}
