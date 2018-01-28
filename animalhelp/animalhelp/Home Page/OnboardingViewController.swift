//
//  OnboardingViewController.swift
//  animalhelp
//
//  Created by Aamir  on 28/01/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import UIKit

class OnboardingViewController: BaseViewController {
    let onboardingView = DetectLocationView()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customNavBar.setTitle("Set Location")
        view.addSubview(onboardingView)
        onboardingView.delegate = self
        onboardingView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    override func locationChanged() {
        guard LocationManager.sharedManager.userLocation != nil else {
            // TODO Show error here
            return
        }
        self.presentingViewController?.dismiss(animated: true)
    }
    
    override func didTapLocationButton() {
        self.present(SelectLocationViewController(), animated:true)
    }
    
}

extension OnboardingViewController:DetectLocationViewDelegate {
    func didTapDetectLocation() {
        LocationManager.sharedManager.startDetectingLocation()
    }
    
    func didTapManuallySelectLocation() {
        self.present(SelectLocationViewController(), animated: true)
    }
}
