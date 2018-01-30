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
            data += [("Spreading the word", "Letting people know that they can use this platform in a time of need can help speed up the process of finding missing pets. The more people aware, the more chances of the pet being found.")]
            
            data += [("Helping catalog and verifying help centers", "Writing to us about how good a clinic is can really help in not just finding the nearest clinic to you but also helps us factor in the quality of service.")]
            
            data += [("Sending stories and feedback","The more feedback we get the more we can do better, if you see something amiss or any improvements it would mean the world to us if you could let us know.")]
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
