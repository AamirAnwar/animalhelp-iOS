//
//  SelectLocationViewController.swift
//  animalhelp
//
//  Created by Aamir  on 21/01/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import UIKit

class SelectLocationViewController: BaseViewController {
    let kCityCellReuseIdentifier = "CityCellReuseIdentifier"
    let kCustomLocationCellReuseIdentifier = "CustomLocationCellReuseIdentifier"
    
    let tableView:UITableView =  {
        let tv = UITableView()
        tv.separatorStyle = .none
        return tv
        
    }()
    
    let searchBar:UISearchBar = {
        let sb = UISearchBar()
        sb.searchBarStyle = .minimal
        sb.placeholder = "Search for places"
        sb.backgroundColor = UIColor.white
        sb.tintColor = CustomColorMainTheme
        return sb
    }()
    
    var customLocations = [CustomLocation]() {
        didSet {
            self.tableView.reloadData()
        }
    }
    var activeCities = ["Delhi","Delhi"] {
        didSet {
            self.tableView.reloadData()
        }
    }
    var isSearching:Bool {
        get {
            return self.searchBar.text?.isEmpty == false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customNavBar.setTitle("Select Location")
        self.view.addSubview(self.tableView)
        self.view.addSubview(self.searchBar)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.snp.makeConstraints { (make) in
            make.top.equalTo(self.searchBar.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        self.tableView.register(StandardListTableViewCell.self, forCellReuseIdentifier: kCityCellReuseIdentifier)
        self.tableView.register(ListItemDetailTableViewCell.self, forCellReuseIdentifier: kCustomLocationCellReuseIdentifier)
        
        self.searchBar.snp.makeConstraints { (make) in
            make.top.equalTo(self.customNavBar.snp.bottom)
            make.leading.equalToSuperview().offset(kSidePadding)
            make.trailing.equalToSuperview().inset(kSidePadding)
        }
        self.searchBar.delegate = self
    }
}

extension SelectLocationViewController:UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: false)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        CustomLocation.performLocationSearchWith(UserQuery: searchBar.text) { (locations) in
            self.customLocations = locations
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: false)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

extension SelectLocationViewController:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isSearching {
            return self.customLocations.count
        }
        else {
            return self.activeCities.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.isSearching {
            return getCustomLocationCell(tableView, indexPath:indexPath)
        }
        else {
            return self.getCityCell(tableView, indexPath:indexPath)
        }
        
    }
    
    func getCityCell(_ tableView:UITableView, indexPath:IndexPath) -> StandardListTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kCityCellReuseIdentifier) as! StandardListTableViewCell
        guard indexPath.row < self.activeCities.count else { return cell}
        cell.setTitle(self.activeCities[indexPath.row])
        cell.showsDisclosure(false)
        cell.showBottomPaddedSeparator()
        return cell
    }
    
    func getCustomLocationCell(_ tableView:UITableView, indexPath:IndexPath) -> ListItemDetailTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kCustomLocationCellReuseIdentifier) as! ListItemDetailTableViewCell
        guard indexPath.row < self.customLocations.count else { return cell}
        let customLocation = self.customLocations[indexPath.row]
        cell.setTitle(customLocation.name, subtitle: customLocation.name)
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
        if y < -120 {
            self.dismiss(animated: true)
        }
    }
}
