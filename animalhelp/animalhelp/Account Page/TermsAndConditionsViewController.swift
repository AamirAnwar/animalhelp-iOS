//
//  TermsAndConditionsViewController.swift
//  animalhelp
//
//  Created by Aamir  on 20/01/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import UIKit
import WebKit

class TermsAndConditionsViewController: BaseViewController {
    let webView = WKWebView()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customNavBar.setTitle("Terms and Conditions")
        self.view.addSubview(self.webView)
        self.webView.snp.makeConstraints { (make) in
            make.top.equalTo(self.customNavBar.snp.bottom)
            make.leading.equalToSuperview().offset(kSidePadding)
            make.trailing.equalToSuperview().inset(kSidePadding)
            make.bottom.equalToSuperview()
        }
        self.webView.scrollView.maximumZoomScale = 1
        if let htmlFile = Bundle.main.path(forResource: "terms", ofType: "html") {
            if let htmlString = try? String.init(contentsOfFile: htmlFile, encoding: String.Encoding.utf8){
                webView.loadHTMLString(htmlString, baseURL: nil)
            }
        }
        
   }

 
}
