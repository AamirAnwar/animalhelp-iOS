//
//  DropdownView.swift
//  animalhelp
//
//  Created by Aamir  on 29/01/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import UIKit

class DropdownView: UIView {
    static var sharedDropdown:DropdownView?
    let messageLabel = UILabel()
    var panGesture:UIPanGestureRecognizer!
    var totalDrag:Int = 0
    var didBeginPan = false
    var completionBlock:(()->Void)? = nil
    convenience init() {
        self.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: kStatusBarHeight))
        self.addSubview(messageLabel)
        self.backgroundColor = CustomColorMainTheme
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(gesture:)))
        self.addGestureRecognizer(panGesture)
        
        messageLabel.font = CustomFontDemiSmall
        messageLabel.textAlignment = .center
        messageLabel.textColor = UIColor.white
        messageLabel.adjustsFontSizeToFitWidth = true
        messageLabel.minimumScaleFactor = 0.5
        messageLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(kSidePadding)
            make.trailing.equalToSuperview().inset(kSidePadding)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }

    @objc func handlePan(gesture:UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            totalDrag = 0
            didBeginPan = true
        case .changed:
            totalDrag = Int(gesture.translation(in: self.superview).y)
            if totalDrag < 0 {
                if totalDrag < -20 {
                    gesture.isEnabled = false
                }
                else {
                    self.transform = CGAffineTransform(translationX: 0, y: CGFloat(totalDrag))
                }
            }
            
        case .cancelled, .ended:
            DropdownView.hide(dropdown: self)
        default:
            DropdownView.hide(dropdown: self)
        }
    }
    
    static func showWith(message:String, completion:(()->Void)?) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate, DropdownView.sharedDropdown == nil, let window = appDelegate.window else {
            return
        }
        
        let dropdown = DropdownView.init()
        DropdownView.sharedDropdown = dropdown
        dropdown.messageLabel.text = message
        dropdown.completionBlock = completion
        dropdown.transform = CGAffineTransform(translationX: 0, y: -dropdown.frame.height)
        window.addSubview(dropdown)
        
        UIView.animate(withDuration: kDropdownAnimationDuration, animations: {
            dropdown.transform = .identity
        }) { (_) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5, execute: {
                if dropdown.didBeginPan == false {
                    DropdownView.hide(dropdown: dropdown)
                }
            })
        }
    }
    
    static func hide(dropdown:DropdownView) {
        guard DropdownView.sharedDropdown === dropdown else {
            return
        }
        dropdown.panGesture.isEnabled = false
        UIView.animate(withDuration: kDropdownAnimationDuration, animations: {
            dropdown.transform = CGAffineTransform(translationX: 0, y: -dropdown.frame.height)
        }) { (_) in
            DropdownView.sharedDropdown?.completionBlock?()
            DropdownView.sharedDropdown = nil
            dropdown.removeFromSuperview()
        }
    }
    
}
