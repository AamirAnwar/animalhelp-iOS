//
//  UtilityFunctions.swift
//  animalhelp
//
//  Created by Aamir  on 19/01/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import Foundation

enum UtilityFunctions {
    static func addShadowTo(view:UIView) {
        let shadowPath = UIBezierPath(rect: view.bounds)
        view.layer.masksToBounds = false
        view.layer.shadowColor = UIColor.black.withAlphaComponent(0.6).cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 1)
        view.layer.shadowOpacity = 0.5
        view.layer.shadowRadius = 4
        view.layer.shadowPath = shadowPath.cgPath
    }
    
    static func assignDotTo(_ view:UIView) {
        let dot = UIView()
        view.superview?.addSubview(dot)
        dot.backgroundColor = CustomColorMainTheme
        dot.layer.cornerRadius = 5
        dot.snp.makeConstraints { (make) in
            make.top.equalTo(view.snp.top).offset(5)
            make.leading.equalTo(view.snp.leading).offset(-14)
            make.size.equalTo(10)
        }
    }
    
    static func addBottomSeparator(toView view:UIView) {
        let separator = CustomSeparator.separator
        view.addSubview(separator)
        separator.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
    }
    
    static func assignFontLabelTo(_ view:UIView, icon:FAIcon) {
        guard let superview = view.superview else {return}
        let label = UILabel()
        superview.addSubview(label)
        label.font = UIFont.init(name: kFontAwesomeFamilyName, size: 20)
        label.text = NSString.fontAwesomeIconString(forEnum: icon)
        label.textColor = CustomColorMainTheme
        label.snp.makeConstraints { (make) in
            make.top.equalTo(view.snp.top).offset(0)
            make.leading.equalTo(view.snp.leading).offset(-16)
        }
        
    }
    
    static func getTransparentCell(tableView:UITableView, height:CGFloat,reuseIdentifier:String) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier)!
        let view = UIView()
        cell.backgroundColor = UIColor.clear
        cell.contentView.addSubview(view)
        cell.selectionStyle = .none
        view.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            make.height.equalTo(height)
        }
        return cell
    }
    
    static func expandImageWith(scrollView:UIScrollView,
                                view:UIView,
                                currentHeight:inout CGFloat,
                                minRequiredHeight:CGFloat,
                                bounceFactor:CGFloat = 1.0) {
        
        let y = scrollView.contentOffset.y
        if y < 0 {
            if currentHeight < minRequiredHeight {
                currentHeight = minRequiredHeight
            }
            else {
                currentHeight = minRequiredHeight - bounceFactor*y
            }
            view.snp.updateConstraints({ (make) in
                make.height.equalTo(currentHeight)
            })
            
        }
    }
    
    static func getBlurredImageFrom(view:UIView) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, true, 1)
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        let screenshot = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        if let blurredImage = screenshot.applyBlur(withRadius: 7, tintColor: UIColor.white.withAlphaComponent(0.3), saturationDeltaFactor: 1.8, maskImage: nil) {
            return blurredImage
        }
        else {
            return UIImage()
        }
        
        
    }
    
    static func showPopUpWith(title:String, subtitle:String, buttonTitle:String) {
        if let appDelegate = UIApplication.shared.delegate,let currentWindow = appDelegate.window {
            let popUpView = InfoPopView()
            popUpView.setTitle(title: title, subtitle: subtitle, buttonTitle:buttonTitle)
            if let window = currentWindow {
                popUpView.backgroundImageView.image = UtilityFunctions.getBlurredImageFrom(view: window)
                window.addSubview(popUpView)
                popUpView.snp.makeConstraints({ (make) in
                    make.edges.equalToSuperview()
                })
            }
        }
    }
    
    public static func setUserLocationInNavBar(customNavBar:CustomNavigationBar) {
        guard var locality = LocationManager.sharedManager.userLocality else {
            customNavBar.setTitle(kStringDetecingLocation)
            return
            
        }
        customNavBar.locationButton.setTitle(nil, for: .normal)
        
        if locality.count > 18 {
            // Too long
            locality = String(locality[locality.startIndex..<locality.index(locality.startIndex, offsetBy: 15)])
            locality.append("...")
        }
        
        let mutableAttrString = NSMutableAttributedString.init(string: "\(locality) ", attributes: [NSAttributedStringKey.font:CustomFontTitleBold, NSAttributedStringKey.foregroundColor:CustomColorTextBlack])
        let chevronString = NSAttributedString.init(string: NSString.fontAwesomeIconString(forEnum: FAIcon.FAChevronDown), attributes: [
            NSAttributedStringKey.foregroundColor:CustomColorMainTheme,
            NSAttributedStringKey.font: UIFont.init(name: kFontAwesomeFamilyName, size: 16)!,
            NSAttributedStringKey.baselineOffset: 2
            ])
        mutableAttrString.append(chevronString)
        customNavBar.setAttributedTitle(mutableAttrString)
    }
    
    public static func openAddressInGoogleMaps(_ address:String) {
        let urlString = "comgooglemaps://?daddr=\(address)&directionsmode=driving".addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        if let urlString = urlString ,let url = URL(string:urlString) ,(UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
            
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            
        } else {
            print("Unable to open in google maps \(address)");
        }
    }
    
    public static func showErrorDropdown(withController controller:BaseViewController) {
        controller.setStatusBarVisibility(shouldShow: false) {
            DropdownView.showWith(message: "Something went wrong :(", completion: {
                controller.setStatusBarVisibility(shouldShow: true, withCompletion:nil)
            })
        }
    }
    
}
