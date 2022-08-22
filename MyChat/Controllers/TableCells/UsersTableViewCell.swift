//
//  UsersTableViewCell.swift
//  MyChat
//
//  Created by Zaur on 19.08.2022.
//

import UIKit
import SDWebImage

class UsersTableViewCell: UITableViewCell {
    
    static let reuseId = "UsersTableViewCell"
    
    private lazy var imageAvatar: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "avatar")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 48 / 2
        return imageView
    }()
    
    private lazy var infoUserLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Configure cell
    
    func configure(with model: Users) {
        guard let url = model.profileImage, let name = model.name, let email = model.email else { return }
        let profileImage = URL(string: url)
        imageAvatar.sd_setImage(with: profileImage)
        infoUserLabel.text = name + " " + email
    }
    
    // MARK: - Settings view
    
    private func setViews() {
        contentView.addSubviews([imageAvatar, infoUserLabel])
        setLayouts()
    }
    
    private func setLayouts() {
        imageAvatar.snp.makeConstraints {
            $0.height.width.equalTo(48)
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(8)
        }
        infoUserLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.width.equalTo(300)
            $0.height.equalTo(30)
            $0.leading.equalTo(imageAvatar.snp.trailing).offset(10)
        }
    }
    
}
