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
    var delegate:DrawerViewDelegate?
    var uiDelegate:DrawerViewUIDelegate?
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
    var flowLayout:UICollectionViewFlowLayout = {
       let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        return layout
    }()
    var collectionView:UICollectionView!
    let clinicCellReuseIdentifier = "ClinicCellReuseIdentifier"
    var nearbyClinics:[Clinic] = []
    let miniMessageButton = UIButton.getRoundedRectButon()
    var panGesture:UIPanGestureRecognizer!
    var previousY:CGFloat = 0
    required init?(coder aDecoder: NSCoder) {
        fatalError("init with coder not implemented")
    }
    
    //MARK: Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        self.panGesture = UIPanGestureRecognizer(target: self, action: #selector(didPan))
        self.panGesture.delegate = self
        self.addGestureRecognizer(panGesture)
        self.createCollectionView()
        self.createHideButton()
        self.createMiniMessageButton()
    }
    
    fileprivate func createHideButton() {
        self.addSubview(self.hideButton)
        self.hideButton.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().inset(10)
            make.top.equalToSuperview().offset(8)
            make.size.equalTo(20)
        }
    }
    
    fileprivate func createCollectionView() {
        self.collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: self.flowLayout)
        self.collectionView.delegate = self
        self.collectionView.delaysContentTouches = false
        self.collectionView.dataSource = self
        self.collectionView.isPagingEnabled = true
        self.collectionView.backgroundColor = UIColor.white
        self.collectionView.register(ClinicCollectionViewCell.self, forCellWithReuseIdentifier: self.clinicCellReuseIdentifier)
        self.addSubview(self.collectionView)
        self.collectionView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            make.height.greaterThanOrEqualTo(kCollectionViewHeight)
        }
    }
    
     fileprivate func createMiniMessageButton() {
        self.addSubview(miniMessageButton)
        self.miniMessageButton.isHidden = true
        self.miniMessageButton.titleLabel?.font = CustomFontDemiSmall
        self.miniMessageButton.isUserInteractionEnabled = false
        self.miniMessageButton.addTarget(self, action: #selector(didTapFindNearbyClinics), for: .touchUpInside)
        self.miniMessageButton.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        self.miniMessageButton.layer.cornerRadius = 0
        self.miniMessageButton.contentEdgeInsets = UIEdgeInsets.init(top: -2, left: 0, bottom: 0, right: 0 )
    }
    
    
    //MARK: Open API
    // Show a list of clinics in the collection view
    public func showClinics(_ clinics:[Clinic]) {
        self.collectionView.isHidden = false
        self.nearbyClinics = clinics
        self.collectionView.reloadData()
    }
    
    // Show clinics and scroll to a clinic at a particular index
    public func showClinics(_ clinics:[Clinic], scrollToIndex index:Int) {
        guard index < clinics.count else {return}
        self.showClinics(clinics)
        self.collectionView.scrollToItem(at: IndexPath.init(row: index, section: 0), at: .centeredHorizontally, animated: true)
    }
    
    public func switchToMinimizedDrawer(title:String) {
        self.miniMessageButton.isHidden = false
        self.collectionView.isHidden = true
        self.hideButton.isHidden = true
        self.miniMessageButton.setTitle(title, for: .normal)
    }
    
    public func switchToMaximizedDrawer() {
        self.miniMessageButton.isHidden = true
        self.collectionView.isHidden = false
        self.hideButton.isHidden = true
        self.collectionView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        self.flowLayout.scrollDirection = .vertical
        self.collectionView.isPagingEnabled = false
    }
    
    public func switchToSingleDrawer() {
        self.miniMessageButton.isHidden = true
        self.flowLayout.scrollDirection = .horizontal
        self.collectionView.isPagingEnabled = true
        self.hideButton.isHidden = false
    }
    
    //MARK: Tap Events
    func didTapGoogleMapsButton(sender: UICollectionViewCell) {
        if let indexPath = self.collectionView.indexPath(for: sender) {
            self.delegate?.didTapOpenInGoogleMaps(forIndex: indexPath)
        }
    }
    
    @objc func didTapSeeAllClinics() {
        if self.flowLayout.scrollDirection == .vertical {
            self.switchToSingleDrawer()
        }
        else {
            self.switchToMaximizedDrawer()
        }
        self.collectionView.setCollectionViewLayout(self.flowLayout, animated: false)
    }
    
    @objc func didTapHideDrawer() {
        self.uiDelegate?.didTapHideDrawerButton()
    }
    
    @objc func didTapFindNearbyClinics() {
        self.delegate?.didTapFindNearbyClinics()
    }
    
    @objc func didPan() {
        guard self.collectionView.isHidden == false else {
            return
        }
        self.uiDelegate?.didPan(drawer: self, panGesture: self.panGesture)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.hideButton.layer.cornerRadius = max(hideButton.height(), hideButton.width())/2
    }
}

extension DrawerView:UICollectionViewDelegate,UICollectionViewDelegateFlowLayout, UICollectionViewDataSource,ClinicCollectionViewCellDelegate {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.nearbyClinics.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.clinicCellReuseIdentifier, for: indexPath) as! ClinicCollectionViewCell
        cell.setClinic(self.nearbyClinics[indexPath.row])
        cell.delegate = self
        if self.flowLayout.scrollDirection == .vertical {
            cell.bottomSeparator.isHidden = false
        }
        else {
            cell.bottomSeparator.isHidden = true
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // TODO implement self sizing cells
        return CGSize(width: self.collectionView.frame.size.width, height: kCollectionViewHeight - 26)
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

}

extension DrawerView:UIGestureRecognizerDelegate {
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == self.panGesture {
            return (self.collectionView.contentOffset.y <= 0)
        }
        return true
    }
}
