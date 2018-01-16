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
    
    let tableView = UITableView(frame: CGRect.zero, style: UITableViewStyle.plain)
    let searchBar = UISearchBar(frame: CGRect.zero)
    var viewModel:PetSearchViewModel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewModel.delegate = self
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let title = NSMutableAttributedString(string: "Pet Search\n", attributes: [NSAttributedStringKey.foregroundColor:CustomColorTextBlack,NSAttributedStringKey.font:CustomFontTitleBold,NSAttributedStringKey.paragraphStyle:paragraphStyle])
        title.append(NSAttributedString(string: "Delhi", attributes:[NSAttributedStringKey.foregroundColor:CustomColorMainTheme,NSAttributedStringKey.font:CustomFontHeadingSmall,NSAttributedStringKey.paragraphStyle:paragraphStyle]))
        customNavBar.setAttributedTitle(title)
        self.customNavBar.enableRightButtonWithTitle("Info")
        self.createSearchBar()
        createTableView()
        self.viewModel.searchForMissingPets()
    }
    
    func createSearchBar() {
        self.view.addSubview(self.searchBar)
        self.searchBar.showsCancelButton = true
        self.searchBar.delegate = self
        self.searchBar.backgroundColor = UIColor.white
        self.searchBar.barTintColor = CustomColorMainTheme
        self.searchBar.tintColor = CustomColorMainTheme
        self.searchBar.backgroundImage = UIImage()
        self.searchBar.snp.makeConstraints { (make) in
            make.top.equalTo(self.customNavBar.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
    }
    
    func createTableView() {
        self.view.addSubview(self.tableView)
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "tablecell")
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
        self.tableView.snp.makeConstraints { (make) in
            make.top.equalTo(self.searchBar.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    func didUpdateMissingPets() {
        self.tableView.reloadData()
    }
    
}

extension PetSearchViewController:UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

extension PetSearchViewController:UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.missingPets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tablecell")!
        let pet = self.viewModel.missingPets[indexPath.row]
        cell.textLabel?.text = pet.type
        cell.detailTextLabel?.text = pet.breed
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row < self.viewModel.missingPets.count else {
            return
        }
        let missingPetDetailVC = MissingPetViewController()
        missingPetDetailVC.pet = self.viewModel.missingPets[indexPath.row]
        self.navigationController?.pushViewController(missingPetDetailVC, animated: true)
        
    }
}
