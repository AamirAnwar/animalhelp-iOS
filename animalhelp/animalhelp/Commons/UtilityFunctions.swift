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
        view.layer.shadowColor = UIColor.black.cgColor
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
}
