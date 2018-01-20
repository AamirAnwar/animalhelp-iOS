//
//  MissingPetDetailViewController.swift
//  animalhelp
//
//  Created by Aamir  on 16/01/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import Foundation
import UIKit

class MissingPetDetailViewController:BaseViewController {
    var pet:MissingPet!
    let APIService = animalhelp.APIService.sharedService
    let kPetDetailCellReuseIdentifier = "MissingPetDetailTableViewCell"
    let kCallOwnerCellReuseIdentifier = "CallOwnerCellReuseIdentifier"
    let kEmptyCellReuseIdentifier = "EmptyCellReuseIdentifier"
    var currentHeight = kMissingPetImageHeight
    let tableView:UITableView = {
      let tableView = UITableView(frame:CGRect.zero, style: .plain)
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        return tableView
        
    }()
    var petImageView:UIImageView = UIImageView()
    var petDetailSections:[(title:String,subtitle:String)] {
        get {
            var sectionData = [(title:String,subtitle:String)]()
            if let desc = self.pet.petDescription {
                sectionData += [("Description", desc)]
            }
            
            if let reward = self.pet.reward {
                sectionData += [("Reward", reward)]
            }
            
            sectionData += [("Age", self.pet.age)]
            if let mark = self.pet.distFeatures {
                sectionData += [("Distinguishing Feature", mark)]
            }
            
            if let location = self.pet.lastKnownLocation {
                sectionData += [("Last Known Location", location)]
            }
            
            sectionData += [("Missing Since", self.pet.missingSince)]
            
            sectionData += [("Owner Contact", self.pet.ownerContact)]
            
            return sectionData
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customNavBar.setTitle("\(pet.breed ?? pet.type!)")
        
        self.view.addSubview(self.petImageView)
        self.petImageView.contentMode = .scaleAspectFill
        self.petImageView.clipsToBounds = true
        self.petImageView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalTo(self.customNavBar.snp.bottom)
            make.height.equalTo(self.currentHeight)
        }
        self.setPetImage()
        
        
        self.view.addSubview(self.tableView)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 20, 0)
        self.tableView.backgroundColor = UIColor.clear
        self.tableView.delaysContentTouches = false
        self.tableView.snp.makeConstraints { (make) in
            make.top.equalTo(self.petImageView.snp.top)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        tableView.register(ListItemDetailTableViewCell.self, forCellReuseIdentifier: self.kPetDetailCellReuseIdentifier)
        tableView.register(ButtonTableViewCell.self, forCellReuseIdentifier: self.kCallOwnerCellReuseIdentifier)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: self.kEmptyCellReuseIdentifier)
    }
    
    func setPetImage() {
        if let urlString = self.pet.imageURL {
            self.petImageView.setImage(WithURL: urlString)
        }
    }
}

extension MissingPetDetailViewController:UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 2 {
            return self.petDetailSections.count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            return UtilityFunctions.getTransparentCell(tableView: tableView, height: kMissingPetImageHeight, reuseIdentifier: self.kEmptyCellReuseIdentifier)
            
        }
        else if indexPath.section == 1 {
            return self.getCallOwnerCell(tableView)
        }
        return self.getMissingPetDetailCell(tableView, indexPath: indexPath)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        UtilityFunctions.expandImageWith(scrollView: scrollView, view: self.petImageView, currentHeight: &self.currentHeight, minRequiredHeight: kMissingPetImageHeight)
    }
    
    func getCallOwnerCell(_ tableView:UITableView) -> ButtonTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.kCallOwnerCellReuseIdentifier) as! ButtonTableViewCell
        cell.setButtonTint(CustomColorGreen)
        cell.setButtonTitle("Call owner")
        return cell
    }
    
    func getMissingPetDetailCell(_ tableView:UITableView, indexPath:IndexPath) -> ListItemDetailTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.kPetDetailCellReuseIdentifier) as! ListItemDetailTableViewCell
        guard indexPath.row < self.petDetailSections.count else {return cell}
        let (title, subtitle) = self.petDetailSections[indexPath.row]
        cell.setTitle(title, subtitle: subtitle)
        return cell
    }
}
