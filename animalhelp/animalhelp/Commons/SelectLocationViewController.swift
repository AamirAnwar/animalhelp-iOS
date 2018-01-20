//
//  SelectLocationViewController.swift
//  animalhelp
//
//  Created by Aamir  on 21/01/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import UIKit

class SelectLocationViewController: BaseViewController {
    let kLocationCellReuseIdentifier = "LocationCellReuseIdentifier"
    let tableView:UITableView =  {
        let tv = UITableView()
        tv.separatorStyle = .none
        return tv
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        self.customNavBar.setTitle("Select Location")
        self.view.addSubview(self.tableView)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.snp.makeConstraints { (make) in
            make.top.equalTo(self.customNavBar.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        self.tableView.register(StandardListTableViewCell.self, forCellReuseIdentifier: kLocationCellReuseIdentifier)
    }
}

extension SelectLocationViewController:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kLocationCellReuseIdentifier) as! StandardListTableViewCell
        cell.setTitle("Delhi")
        cell.showsDisclosure(false)
        cell.showBottomPaddedSeparator()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // Set app-wide location
        self.dismiss(animated:true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let y = scrollView.contentOffset.y
        if y < -80 {
            self.dismiss(animated: true)
        }
    }
}
