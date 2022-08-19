//
//  UsersTableViewCell.swift
//  MyChat
//
//  Created by Zaur on 19.08.2022.
//

import UIKit

class UsersTableViewCell: UITableViewCell {
    
    static let reuseId = "UsersTableViewCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .green
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
