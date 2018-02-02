//
//  EmptyStateTableViewCell.swift
//  animalhelp
//
//  Created by Aamir  on 02/02/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import UIKit
protocol EmptyStateTableViewCellDelegate {
    func didTapActionButton()
}
class EmptyStateTableViewCell: UITableViewCell,EmptyStateViewDelegate {
    let emptyStateView = EmptyStateView()
    var delegate:EmptyStateTableViewCellDelegate?
    required init?(coder aDecoder: NSCoder) {
        fatalError("init with coder not implemented")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(emptyStateView)
        emptyStateView.delegate = self
        emptyStateView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    func didTapEmptyStateButton() {
        self.delegate?.didTapActionButton()
    }

}
