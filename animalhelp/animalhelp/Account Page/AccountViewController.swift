//
//  SettingsViewController.swift
//  animalhelp
//
//  Created by Aamir  on 04/01/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import Foundation
import UIKit
class AccountViewController:BaseViewController {
    init() {
        super.init(nibName: nil, bundle: nil)
        self.tabBarItem.title = "Account"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Init with coder not implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
