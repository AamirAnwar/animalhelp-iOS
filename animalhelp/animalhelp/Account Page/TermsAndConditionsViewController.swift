//
//  TermsAndConditionsViewController.swift
//  animalhelp
//
//  Created by Aamir  on 20/01/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import UIKit

class TermsAndConditionsViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.customNavBar.setTitle("Terms and Conditions")
        let imageView = UIImageView(image: #imageLiteral(resourceName: "defaultProfileImage"))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        view.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(kSidePadding)
            make.trailing.equalToSuperview().inset(kSidePadding)
            make.top.equalTo(self.customNavBar.snp.bottom).offset(kSidePadding)
        }
        
    }

 
}
