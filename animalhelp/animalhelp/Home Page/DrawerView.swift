//
//  DrawerView.swift
//  animalhelp
//
//  Created by Aamir  on 04/01/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

protocol DrawerViewDelegate {
    func didTapDetectLocation()
    func didTapManuallySelectLocation()
    func didTapOpenInGoogleMaps(forIndex indexPath:IndexPath)
    func didTapStickyButton(seeMore:Bool)
    func didSwipeToClinicAt(index:Int)
    func didTapFindNearbyClinics()
}

protocol DrawerViewUIDelegate {
    func didTapHideDrawerButton()
    func didPan(drawer:DrawerView, panGesture:UIPanGestureRecognizer)
    func didScrollDownWithDelta(_ delta:CGFloat)
    func didEndDragging(WithTotalDrag drag:CGFloat)
}

class DrawerView:UIView {
    let locationPinImageView = UIImageView(image: #imageLiteral(resourceName: "LocationPin"))
    let infoLabel = UILabel()
    let hideButton:UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = UIFont.init(name: kFontAwesomeFamilyName, size: 14)
        button.setTitle(NSString.fontAwesomeIconString(forEnum: FAIcon.FAChevronDown), for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.addTarget(self, action: #selector(didTapHideDrawer), for: .touchUpInside)
        button.backgroundColor = CustomColorMainTheme
        button.contentEdgeInsets = UIEdgeInsetsMake(0, 3, 0, 3)
        return button
    }()
    let detectLocationButton = UIButton(type: .system)
    let manualLocationButton = UIButton(type: .system)
    let stickyButton = UIButton(type: .system)
    let onboardingContainerView = UIView()
    let tapGesture = UITapGestureRecognizer()
    var delegate:DrawerViewDelegate? = nil
    var uiDelegate:DrawerViewUIDelegate? = nil
    var flowLayout:UICollectionViewFlowLayout = {
       let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        return layout
    }()
    var collectionView:UICollectionView!
    let clinicCellReuseIdentifier = "ClinicCellReuseIdentifier"
    var nearestClinic:Clinic? = nil
    var nearbyClinics:[Clinic]?
    let showNearbyClinicsButton = UIButton.getRoundedRectButon()
    var panGesture:UIPanGestureRecognizer!
    var previousY:CGFloat = 0
    required init?(coder aDecoder: NSCoder) {
        fatalError("init with coder not implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.panGesture = UIPanGestureRecognizer(target: self, action: #selector(didPan))
        self.panGesture.delegate = self
        self.addGestureRecognizer(panGesture)
        self.backgroundColor = UIColor.white
        
        
        
        self.collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: self.flowLayout)
        self.collectionView.delegate = self
//        self.collectionView.delaysContentTouches = false
        self.collectionView.dataSource = self
        self.collectionView.isPagingEnabled = true
        self.collectionView.backgroundColor = UIColor.white
        self.collectionView.register(ClinicCollectionViewCell.self, forCellWithReuseIdentifier: self.clinicCellReuseIdentifier)
        self.addSubview(self.collectionView)
        self.collectionView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            make.height.greaterThanOrEqualTo(kCollectionViewHeight)
        }
        
//        self.addSubview(self.stickyButton)
        self.stickyButton.setTitleColor(CustomColorMainTheme, for: .normal)
        self.stickyButton.titleLabel?.font = CustomFontHeadingSmall
        self.stickyButton.layer.borderWidth = 1
        self.stickyButton.layer.borderColor = CustomColorMainTheme.cgColor
        self.stickyButton.backgroundColor = UIColor.white
        let inset:CGFloat = 8
        self.stickyButton.contentEdgeInsets = UIEdgeInsetsMake(3, inset, 3, inset)
        self.stickyButton.setTitle("See more clinics", for: .normal)
        self.stickyButton.layer.cornerRadius = 2*kCornerRadius
//        self.stickyButton.snp.makeConstraints { (make) in
//            make.bottom.equalToSuperview().inset(10)
//            make.centerX.equalToSuperview()
//        }
        self.stickyButton.addTarget(self, action: #selector(didTapSeeAllClinics), for: .touchUpInside)
        
        self.addSubview(self.hideButton)
        self.hideButton.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().inset(10)
            make.top.equalToSuperview().offset(8)
            make.size.equalTo(20)
        }
        
        self.addSubview(showNearbyClinicsButton)
        self.showNearbyClinicsButton.isHidden = true
        self.showNearbyClinicsButton.isUserInteractionEnabled = false
        self.showNearbyClinicsButton.addTarget(self, action: #selector(didTapFindNearbyClinics), for: .touchUpInside)
        self.showNearbyClinicsButton.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        self.showNearbyClinicsButton.layer.cornerRadius = 0
        self.showNearbyClinicsButton.contentEdgeInsets = UIEdgeInsets.init(top: -2, left: 0, bottom: 0, right: 0 )
        
        
    }
    
    fileprivate func setupUnkownLocationView() {
        guard onboardingContainerView.superview == nil else {
            return
        }
        
        self.addSubview(onboardingContainerView)
        onboardingContainerView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        onboardingContainerView.addSubview(locationPinImageView)
        onboardingContainerView.addSubview(infoLabel)
        onboardingContainerView.addSubview(manualLocationButton)
        onboardingContainerView.addSubview(detectLocationButton)
        
        infoLabel.text = "We need your location to find clinics around you"
        infoLabel.numberOfLines = 0
        infoLabel.font = CustomFontBodyMedium
        infoLabel.textAlignment = .center
        
        detectLocationButton.setTitle("Detect Location", for: .normal)
        detectLocationButton.setTitleColor(UIColor.white, for: .normal)
        detectLocationButton.backgroundColor = CustomColorMainTheme
        detectLocationButton.layer.cornerRadius = kCornerRadius
        detectLocationButton.titleLabel?.font = CustomFontButtonTitle
        detectLocationButton.addTarget(self, action: #selector(detectLocationButtonTapped), for: .touchUpInside)
        
        manualLocationButton.setTitle("Manually Select Location", for: .normal)
        manualLocationButton.setTitleColor(CustomColorDarkGray, for: .normal)
        manualLocationButton.layer.cornerRadius = kCornerRadius
        manualLocationButton.layer.borderWidth = 1
        manualLocationButton.titleLabel?.font = CustomFontButtonTitle
        manualLocationButton.layer.borderColor = CustomColorDarkGray.cgColor
        manualLocationButton.addTarget(self, action: #selector(manuallySelectLocationButtonTapped), for: .touchUpInside)
        
        locationPinImageView.snp.makeConstraints { (make) in
            make.top.greaterThanOrEqualTo(self.snp.top).offset(20)
            make.centerX.equalToSuperview()
        }
        
        infoLabel.snp.makeConstraints { (make) in
            make.top.equalTo(locationPinImageView.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().offset(-8)
        }
        
        detectLocationButton.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
            make.top.equalTo(infoLabel.snp.bottom).offset(16)
            make.height.equalTo(kStandardButtonHeight)
        }
        
        manualLocationButton.snp.makeConstraints { (make) in
            make.leading.equalTo(detectLocationButton.snp.leading)
            make.trailing.equalTo(detectLocationButton.snp.trailing)
            make.top.equalTo(detectLocationButton.snp.bottom).offset(16)
            make.height.equalTo(detectLocationButton.snp.height)
            make.bottom.equalTo(self.snp.bottom).offset(-20)
        }
        
        
    }
    func showClinics(_ clinics:[Clinic]) {
        self.onboardingContainerView.isHidden = true
        self.collectionView.isHidden = false
        self.stickyButton.isHidden = false
        self.nearbyClinics = clinics
        self.collectionView.reloadData()
    }
    func showClinics(_ clinics:[Clinic], selectedIndex:Int) {
        guard selectedIndex < clinics.count else {return}
        self.showClinics(clinics)
        self.collectionView.scrollToItem(at: IndexPath.init(row: selectedIndex, section: 0), at: .centeredHorizontally, animated: true)
    }
    
    public func showUnknownLocationState() {
        self.onboardingContainerView.isHidden = false
        self.collectionView.isHidden = true
        self.stickyButton.isHidden = true
        self.hideButton.isHidden = true
        setupUnkownLocationView()
    }

    
    //MARK: Button Callbacks
    @objc fileprivate func detectLocationButtonTapped() {
        self.delegate?.didTapDetectLocation()
    }
    
    @objc fileprivate func manuallySelectLocationButtonTapped() {
        self.delegate?.didTapManuallySelectLocation()
    }
    
    @objc fileprivate func drawerTapped() {
        UIView.animate(withDuration: 0.2) {
            if self.transform.isIdentity {
                self.transform = CGAffineTransform.init(translationX: 0, y: 50)
            }
            else {
                self.transform = .identity
            }
        }
    }
}

extension DrawerView:UICollectionViewDelegate,UICollectionViewDelegateFlowLayout, UICollectionViewDataSource,ClinicCollectionViewCellDelegate {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.nearbyClinics?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.clinicCellReuseIdentifier, for: indexPath) as! ClinicCollectionViewCell
        cell.setClinic(self.nearbyClinics?[indexPath.row])
        cell.delegate = self
        if self.flowLayout.scrollDirection == .vertical {
            cell.bottomSeparator.isHidden = false
        }
        else {
            cell.bottomSeparator.isHidden = true
        }
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.contentOffset.y <= 0 && scrollView.isTracking else {return}
        
        let y = scrollView.contentOffset.y
        
        if y < 0 {
            let delta = y - previousY
            self.uiDelegate?.didScrollDownWithDelta(delta)
        }
        print(previousY)
        previousY = y
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard scrollView.contentOffset.y <= 0 else {return}
        self.uiDelegate?.didEndDragging(WithTotalDrag: previousY)
        previousY = 0
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if self.flowLayout.scrollDirection == .horizontal, let visibleIndexPath = self.collectionView.indexPathsForVisibleItems.first {
            self.delegate?.didSwipeToClinicAt(index: visibleIndexPath.row)
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // TODO implement self sizing cells
        return CGSize(width: self.collectionView.frame.size.width, height: kCollectionViewHeight - 26)
    }
    
    func didTapGoogleMapsButton(sender: UICollectionViewCell) {
        if let indexPath = self.collectionView.indexPath(for: sender) {
            self.delegate?.didTapOpenInGoogleMaps(forIndex: indexPath)
        }
    }
    
    @objc func didTapSeeAllClinics() {
        var seeMore = false
        if self.flowLayout.scrollDirection == .vertical {
            self.switchToSingleDrawer()
        }
        else {
            seeMore = true
            self.switchToMaximizedDrawer()
        }
        self.collectionView.setCollectionViewLayout(self.flowLayout, animated: false)
        self.delegate?.didTapStickyButton(seeMore: seeMore)
    }
    
    func switchToMinimizedDrawer(title:String) {
        self.showNearbyClinicsButton.isHidden = false
        self.onboardingContainerView.isHidden = true
        self.collectionView.isHidden = true
        self.showNearbyClinicsButton.titleLabel?.font = CustomFontDemiSmall
        self.showNearbyClinicsButton.setTitle(title, for: .normal)
        self.stickyButton.isHidden = true
        self.hideButton.isHidden = true
    }
    
    func switchToMaximizedDrawer() {
        self.showNearbyClinicsButton.isHidden = true
        self.collectionView.isHidden = false
        self.onboardingContainerView.isHidden = true
        self.collectionView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        self.flowLayout.scrollDirection = .vertical
        self.collectionView.isPagingEnabled = false
        UIView.transition(with: self.stickyButton, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self.stickyButton.setTitleColor(UIColor.white, for: .normal)
            self.stickyButton.backgroundColor = CustomColorMainTheme
        }, completion: nil)
        
        self.hideButton.isHidden = true
        self.stickyButton.isHidden = false
    }
    
    func switchToSingleDrawer() {
        self.showNearbyClinicsButton.isHidden = true
        self.onboardingContainerView.isHidden = true
        self.flowLayout.scrollDirection = .horizontal
        self.collectionView.isPagingEnabled = true
        UIView.transition(with: self.stickyButton, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self.stickyButton.setTitleColor(CustomColorMainTheme, for: .normal)
            self.stickyButton.backgroundColor = UIColor.white
        }, completion: nil)
        self.hideButton.isHidden = false
        self.stickyButton.isHidden = false
    }
    
    @objc func didTapHideDrawer() {
        self.uiDelegate?.didTapHideDrawerButton()
    }
    
    @objc func didTapFindNearbyClinics() {
        self.delegate?.didTapFindNearbyClinics()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.hideButton.layer.cornerRadius = max(hideButton.height(), hideButton.width())/2
    }
    
    
    @objc func didPan() {
        self.uiDelegate?.didPan(drawer: self, panGesture: self.panGesture)
    }
}

extension DrawerView:UIGestureRecognizerDelegate {
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == self.panGesture {
            if self.collectionView.contentOffset.y > 0 {
                return false
            }
            
            return gestureRecognizer.view == self
        }
        return true
    }
}
