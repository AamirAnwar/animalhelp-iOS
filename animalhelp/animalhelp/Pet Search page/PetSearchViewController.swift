//
//  PetSearchViewController.swift
//  animalhelp
//
//  Created by Aamir  on 04/01/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import Foundation
import UIKit
class PetSearchViewController:BaseViewController {
    
    let tableView = UITableView(frame: CGRect.zero, style: UITableViewStyle.plain)
    let pets = ["Doggo","Doggo","Doggo","Doggo","Doggo"]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.tabBarItem.title = "Pet Search"
        createTableView()
    }
    
    func createTableView() {
        self.view.addSubview(self.tableView)
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "tablecell")
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.snp.makeConstraints { (make) in
            make.top.equalTo(self.customNavBar.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }

    }
}

extension PetSearchViewController:UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.pets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tablecell")!
        cell.textLabel?.text = self.pets[indexPath.row]
        return cell
    }
}
