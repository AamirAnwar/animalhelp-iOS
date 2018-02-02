//
//  PetSearchViewController.swift
//  animalhelp
//
//  Created by Aamir  on 04/01/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import Foundation
import UIKit


class PetSearchViewController:BaseViewController, PetSearchViewModelDelegate {
    
    let kMissingPetCellReuseIdentifier = "MissingPetTableViewCell"
    let kPetCountCellReuseIdentifier = "PetCountTableViewCell"
    let kEmptyStateReuseIdentifier = "EmptyStateTableViewCell"
    
    let tableView = UITableView(frame: CGRect.zero, style: UITableViewStyle.plain)
    let searchBar = UISearchBar(frame: CGRect.zero)
    var viewModel:PetSearchViewModel!
    let refreshControl:UIRefreshControl = {
       let control = UIRefreshControl()
        control.tintColor = CustomColorMainTheme
        return control
    }()
    
    var isSearching:Bool {
        get {
            return self.searchBar.text?.isEmpty == false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.startedDetectingLocation), name: kNotificationDidStartUpdatingLocation.name, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.locationDetectionFailed), name: kNotificationLocationDetectionFailed.name, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willShowKeyboard(notification:)), name: kNotificationWillShowKeyboard.name, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willHideKeyboard), name: kNotificationWillHideKeyboard.name, object: nil)
        self.viewModel.delegate = self
        self.customNavBar.enableRightButtonWithIcon(icon: .FAInfoCircle)
        self.createSearchBar()
        // Create separator
        let separator = CustomSeparator.separator
        view.addSubview(separator)
        separator.snp.makeConstraints { (make) in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(self.searchBar.snp.bottom)
        }
        
        self.createTableView()
        self.viewModel.searchForMissingPets()
        self.emptyStateView.setMessage("Something went wrong :(", buttonTitle: "Try Again")
        self.refreshControl.addTarget(self, action: #selector(didPromptRefresh), for: UIControlEvents.valueChanged)
    }
    
    func createSearchBar() {
        self.view.addSubview(self.searchBar)
        self.searchBar.delegate = self
        self.searchBar.placeholder = "Search"
        self.searchBar.backgroundColor = UIColor.white
        self.searchBar.searchBarStyle = .minimal
        self.searchBar.tintColor = CustomColorMainTheme
        self.searchBar.snp.makeConstraints { (make) in
            make.top.equalTo(self.customNavBar.snp.bottom)
            make.leading.equalToSuperview().offset(kSidePadding)
            make.trailing.equalToSuperview().inset(kSidePadding)
        }
    }
    
    func createTableView() {
        self.view.addSubview(self.tableView)
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "tablecell")
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.tableView.separatorStyle = .none
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.refreshControl = self.refreshControl
        self.tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 20, right: 0)
        self.tableView.register(MissingPetTableViewCell.self, forCellReuseIdentifier: self.kMissingPetCellReuseIdentifier)
        self.tableView.register(StandardListTableViewCell.self, forCellReuseIdentifier: self.kPetCountCellReuseIdentifier)
        self.tableView.register(EmptyStateTableViewCell.self, forCellReuseIdentifier: kEmptyStateReuseIdentifier)
        
        self.tableView.snp.makeConstraints { (make) in
            make.top.equalTo(self.searchBar.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    func didUpdateMissingPets() {
        self.refreshControl.endRefreshing()
        self.hideEmptyStateView()
        self.tableView.reloadData()
        
    }
    
    override func didTapLocationButton() {
        // Open location selection flow
        let vc = SelectLocationViewController()
        present(vc,animated:true)
    }
    
    override func didTapRightBarButton() {
        UtilityFunctions.showPopUpWith(title: "Add a missing pet", subtitle: "If you wish to add a pet please tap the button below to be redirected to a form where you can fill details", buttonTitle: "Proceed")
    }
    
    override func didTapEmptyStateButton() {
        self.viewModel.searchForMissingPets()
        self.hideEmptyStateView()
        self.showLoader()
    }
    
    @objc func didPromptRefresh() {
        self.viewModel.searchForMissingPets()
    }
    
    override func locationChanged() {
        self.hideLoader()
        self.viewModel.searchForMissingPets()
        UtilityFunctions.setUserLocationInNavBar(customNavBar: self.customNavBar)
    }
    
    @objc func startedDetectingLocation() {
        self.showLoader()
    }
    
    @objc func locationDetectionFailed() {
        self.hideLoader()
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
    
    func didGetSearchResults(_ results: [MissingPet]) {
        self.tableView.reloadData()
    }
}

extension PetSearchViewController:UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
         self.searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.searchBar.setShowsCancelButton(false, animated: true)
        if self.isSearching == false {
            self.tableView.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let q = searchBar.text else {
            return
        }
        self.viewModel.searchPetsWithQuery(q)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

extension PetSearchViewController:UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 22
        }
        else if indexPath.section == 2 {
            return tableView.height()
        }
        return 400
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if self.viewModel.missingPets.isEmpty == true {
                return 0
            }
            else {
                return 1
            }
        }
        
        if self.isSearching {
            return self.viewModel.searchResults.count
        }
        else {
            // empty state section
            if section == 2 {
                if self.viewModel.missingPets.isEmpty {
                    return 1
                }
            }
            return self.viewModel.missingPets.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            return self.getPetCountCell(tableView)
        }
        else if indexPath.section == 2 {
            return self.getEmptyStateCell(tableView)
        }
        var pet:MissingPet! = nil
        if self.isSearching {
            pet = self.viewModel.searchResults[indexPath.row]
        }
        else {
            pet = self.viewModel.missingPets[indexPath.row]
        }
        
        return self.getMissingPetCell(tableView, pet: pet)
    }
    
    func getMissingPetCell(_ tableView:UITableView, pet:MissingPet) -> MissingPetTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kMissingPetCellReuseIdentifier) as! MissingPetTableViewCell
        cell.setMissingPet(pet)
        return cell
    }
    
    func getPetCountCell(_ tableView:UITableView) -> StandardListTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kPetCountCellReuseIdentifier) as! StandardListTableViewCell
        cell.showsDisclosure(false)
        cell.setTitleColor(CustomColorDarkGray)
        cell.setTitleFont(CustomFontDemiSmall)
        cell.updateVerticalPadding(with: 3)
        let count = self.isSearching ? self.viewModel.searchResults.count:self.viewModel.missingPets.count
        cell.setTitle("Showing \(count) missing pets around \(LocationManager.sharedManager.userLocality ?? "current vicinity")")
        return cell
    }
    
    func getEmptyStateCell(_ tableView:UITableView) -> EmptyStateTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kEmptyStateReuseIdentifier) as! EmptyStateTableViewCell
        cell.emptyStateView.setMessage("Not missing pets here :)", buttonTitle: "Change location")
        cell.delegate = self
        cell.selectionStyle = .none
        cell.emptyStateView.snp.makeConstraints { (make) in
            make.height.equalTo(self.view.height() - (self.searchBar.bottom() + self.tabBarHeight))
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section > 0 && indexPath.row < self.viewModel.missingPets.count else {
            return
        }
        let missingPetDetailVC = MissingPetDetailViewController()
        var pet:MissingPet! = nil
        if self.isSearching {
            pet = self.viewModel.searchResults[indexPath.row]
        }
        else {
            pet = self.viewModel.missingPets[indexPath.row]
        }
        missingPetDetailVC.pet = pet
        self.navigationController?.pushViewController(missingPetDetailVC, animated: true)
    }
}

extension PetSearchViewController:EmptyStateTableViewCellDelegate {
    func didTapActionButton() {
        self.present(SelectLocationViewController(), animated: true)
    }
}
