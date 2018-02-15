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
    func didTapCallClinic(forIndex indexPath:IndexPath)
    func didSwipeToClinicAt(index:Int)
    func didTapMiniMessageButton()
}

protocol DrawerViewUIDelegate {
    func didPan(drawer:DrawerView, panGesture:UIPanGestureRecognizer)
    func didScrollDownWithDelta(_ delta:CGFloat)
    func didEndDragging(WithTotalDrag drag:CGFloat)
    func isBeingDragged()->Bool
}

class DrawerView:UIView {
    var delegate:DrawerViewDelegate?
    var uiDelegate:DrawerViewUIDelegate?
    var flowLayout:UICollectionViewFlowLayout = {
       let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets.zero
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
        self.createCollectionView()
        self.createMiniMessageButton()
    }

    fileprivate func createCollectionView() {
        self.collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: self.flowLayout)
        self.collectionView.delegate = self
        self.collectionView.delaysContentTouches = false
        self.collectionView.dataSource = self
        self.collectionView.isPagingEnabled = true
        self.collectionView.backgroundColor = UIColor.white
        self.panGesture = UIPanGestureRecognizer(target: self, action: #selector(didPan))
        self.panGesture.delegate = self
        self.collectionView.addGestureRecognizer(panGesture)
//        self.panGesture.require(toFail: self.collectionView.panGestureRecognizer)
        self.collectionView.panGestureRecognizer.require(toFail: self.panGesture)
//        self.collectionView.layer.borderColor = CustomColorMainTheme.cgColor
//        self.collectionView.layer.borderWidth = 2
        self.collectionView.delaysContentTouches = false
        self.collectionView.register(ClinicCollectionViewCell.self, forCellWithReuseIdentifier: self.clinicCellReuseIdentifier)
        self.addSubview(self.collectionView)
        self.collectionView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        
    }
    
     fileprivate func createMiniMessageButton() {
        self.addSubview(miniMessageButton)
        self.miniMessageButton.isHidden = true
        self.miniMessageButton.titleLabel?.font = CustomFontDemiSmall
        self.miniMessageButton.addTarget(self, action: #selector(didTapMiniMessageButton), for: .touchUpInside)
        self.miniMessageButton.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        self.miniMessageButton.layer.cornerRadius = 0
        self.miniMessageButton.contentEdgeInsets = UIEdgeInsets.init(top: -2, left: 0, bottom: 0, right: 0 )
    }
    
    
    //MARK: Public API
    
    public func refreshWith(clinics:[Clinic]) {
        self.nearbyClinics = clinics
        self.collectionView.reloadData()
    }
    
    // Show a list of clinics in the collection view
    public func showClinics(_ clinics:[Clinic]) {
        self.collectionView.isHidden = false
        self.refreshWith(clinics: clinics)
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
        self.miniMessageButton.setTitle(title, for: .normal)
    }
    
    public func switchToMaximizedDrawer() {
        self.miniMessageButton.isHidden = true
        self.collectionView.isHidden = false
        self.setScrollDirection(.vertical)
    }
    
    public func switchToSingleDrawer() {
        self.miniMessageButton.isHidden = true
        self.setScrollDirection(.horizontal)
    }
    
    public func setScrollDirection(_ direction:UICollectionViewScrollDirection) {
        self.collectionView.performBatchUpdates({
            self.flowLayout.scrollDirection = direction
        }, completion: nil)
        self.collectionView.isPagingEnabled = (direction == .horizontal)
    }
    
    //MARK: Tap Events
    func didTapGoogleMapsButton(sender: UICollectionViewCell) {
        if let indexPath = self.collectionView.indexPath(for: sender) {
            self.delegate?.didTapOpenInGoogleMaps(forIndex: indexPath)
        }
    }
    
    func didTapCallClinicButton(sender: UICollectionViewCell) {
        if let indexPath = self.collectionView.indexPath(for: sender) {
            self.delegate?.didTapCallClinic(forIndex: indexPath)
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
    
    @objc func didTapMiniMessageButton() {
        self.delegate?.didTapMiniMessageButton()
    }
    
    @objc func didPan() {
        guard self.collectionView.isHidden == false else {
            return
        }
        self.uiDelegate?.didPan(drawer: self, panGesture: self.panGesture)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
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
        if self.flowLayout.scrollDirection == .vertical && indexPath.row < self.nearbyClinics.count - 1 {
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
        scrollView.bounces = (scrollView.contentOffset.y > 100);
        guard scrollView.isTracking else {return}
        let y = scrollView.contentOffset.y
        let delta = y - previousY
//        print(" Content offset \(y) Delta \(delta)")
        if y < 0 {
            self.uiDelegate?.didScrollDownWithDelta(delta)
        }
//        else if y > 0 {
//            if let delegate = self.uiDelegate, delegate.isBeingDragged() {
////                self.uiDelegate?.didScrollDownWithDelta(1.1*delta)
//            }
//        }
        previousY = y
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        guard let delegate = self.uiDelegate, delegate.isBeingDragged() else {return}
//        self.uiDelegate?.didEndDragging(WithTotalDrag: previousY)
//        previousY = 0
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
            if self.flowLayout.scrollDirection == .vertical {
                // Maximized state÷
                
                if self.collectionView.contentOffset.y <= 0 {
                    if self.panGesture.translation(in: self.collectionView).y > 0 {
                        return true
                    }
                }
                
                if let delegate = self.uiDelegate, delegate.isBeingDragged() {
                    return true
                }
                
                if self.collectionView.contentOffset.y < 0 {
                    return true
                }
                return false
            }
            else {
                let shouldTrack = self.collectionView.contentOffset.y <= 0 && self.panGesture.translation(in: self.collectionView).y < 0
                print(self.panGesture.translation(in: self.collectionView).y)
                print("is tracking \(shouldTrack)")
                return shouldTrack
            }
        }
        return true
    }
}

