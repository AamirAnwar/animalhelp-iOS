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
    var activeCities:[AppLocation] = [] {
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
        self.emptyStateView.setMessage("Whoops something went wrong!", buttonTitle: "Try again")
        NotificationCenter.default.addObserver(self, selector: #selector(willShowKeyboard(notification:)), name: kNotificationWillShowKeyboard.name, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willHideKeyboard), name: kNotificationWillHideKeyboard.name, object: nil)
        self.customNavBar.setTitle("Select Location")
        self.customNavBar.shouldShowCrossButton(true)
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.refreshActiveCities()
    }
    
    func refreshActiveCities() {
        self.showLoader()
        AppLocation.getActiveCities { (cities,error) in
            guard error == nil else {
                self.hideLoader()
                UtilityFunctions.showErrorDropdown(withController: self)
                self.showEmptyStateView()
                return
            }
            self.hideLoader()
            self.activeCities = cities
            self.tableView.reloadData()
        }
    }
    
    override func didTapEmptyStateButton() {
        self.refreshActiveCities()
        self.hideEmptyStateView()
    }
    
    @objc func willShowKeyboard(notification:NSNotification) {
        guard self.view.window != nil else {return}
        
        if let keyboardFrame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardFrame.cgRectValue.height
            
            UIView.animate(withDuration: 1, animations: {
                self.tableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: keyboardHeight, right: 0)
            })
            
        }
    }
    
    @objc func willHideKeyboard() {
        guard self.view.window != nil else {return}
        self.tableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
    }
    
}

extension SelectLocationViewController:UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: false)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            self.tableView.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.showLoader()
        CustomLocation.performLocationSearchWith(UserQuery: searchBar.text) { (locations) in
            self.hideLoader()
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
        cell.setTitle(self.activeCities[indexPath.row].name)
        cell.showsDisclosure(false)
        cell.showBottomPaddedSeparator()
        return cell
    }
    
    func getCustomLocationCell(_ tableView:UITableView, indexPath:IndexPath) -> ListItemDetailTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kCustomLocationCellReuseIdentifier) as! ListItemDetailTableViewCell
        guard indexPath.row < self.customLocations.count else { return cell}
        let customLocation = self.customLocations[indexPath.row]
        cell.setTitle(customLocation.name, subtitle: customLocation.formattedAddress)
        cell.showBottomPaddedSeparator()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // Set app-wide location
        if isSearching {
            // Set from search results
            guard indexPath.row < self.customLocations.count else {return}
            LocationManager.sharedManager.userLocation = AppLocation.init(from: self.customLocations[indexPath.row])
        }
        else {
            guard indexPath.row < self.activeCities.count else {return}
            // Get app location objects from API
            LocationManager.sharedManager.userLocation = self.activeCities[indexPath.row]
        }
        
        self.dismiss(animated:true)
    }
}
