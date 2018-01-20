//
//  FeedbackViewController.swift
//  animalhelp
//
//  Created by Aamir  on 20/01/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import Foundation
import UIKit

class FeedbackViewController:BaseViewController {
    let placeholderText = "Tell us how we could do better"
    let textView:UITextView = UITextView()
    let submitButton:UIButton = {
       let button = UIButton(type: .system)
        button.setTitle("Submit", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = CustomColorMainTheme
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = CustomFontButtonTitle
        button.layer.cornerRadius = kCornerRadius
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.customNavBar.setTitle("Feedback")
        self.customNavBar.enableRightButtonWithTitle("Submit")
        
        self.view.addSubview(self.textView)
//        self.view.addSubview(self.submitButton)
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(didTapView))
        self.view.addGestureRecognizer(tapGes)
        self.textView.text = self.placeholderText
        self.textView.font = CustomFontBodyMedium
        self.textView.layer.borderColor = CustomColorLightGray.withAlphaComponent(0.4).cgColor
        self.textView.layer.borderWidth = 1
        self.textView.delegate = self
        self.textView.snp.makeConstraints { (make) in
            make.top.equalTo(self.customNavBar.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(kSidePadding)
            make.trailing.equalToSuperview().inset(kSidePadding)
            make.height.equalTo(250)
            
        }
        
        
//        self.submitButton.snp.makeConstraints { (make) in
//            make.bottom.equalToSuperview().inset(50 + self.tabBarHeight)
//            make.leading.equalToSuperview().offset(kSidePadding)
//            make.trailing.equalToSuperview().inset(kSidePadding)
//            make.height.equalTo(kStandardButtonHeight)
//        }
//        self.submitButton.addTarget(self, action: #selector(didTapSubmit), for: .touchUpInside)
//
        
    }
    
    @objc func didTapSubmit() {
        // Send feedback to the backend
    }
    
    @objc func didTapView() {
        self.textView.resignFirstResponder()
    }
}
extension FeedbackViewController:UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == self.placeholderText {
            textView.text = ""
        }
    }
}
