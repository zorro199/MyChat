//
//  MessagesTableView.swift
//  MyChat
//
//  Created by Zaur on 27.08.2022.
//

import UIKit
import SDWebImage
import FirebaseDatabase
import FirebaseAuth

class MessagesTableViewCell: UITableViewCell {
    
    var messages: Messages?
    
    private lazy var dataFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm:ss"
        return formatter
    }()
    
    static let reuseId = "MessagesTableViewCell"
    
    private lazy var imageAvatar: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "avatar")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 48 / 2
        return imageView
    }()
    
    private lazy var userLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        return label
    }()
    
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .lightGray
        label.text = "hh:mm:ss"
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
    
    func configure(with model: Messages) {
        guard let toUserID = model.fromUserID else {
            print("error ID")
            return }
        let referance = Database.database().reference().child("users").child(toUserID)
        referance.observeSingleEvent(of: .value) { snapshot in
            guard let dictionary = snapshot.value as? [String:Any] else { return }
            guard let profileImage = dictionary["profileImage"] as? String else { return }
            guard let url = URL(string: profileImage) else { return }
            self.imageAvatar.sd_setImage(with: url)
            let userName = dictionary["name"] as? String
            let textMessage = model.text
            self.userLabel.text = userName ?? ""
            self.messageLabel.text = textMessage ?? ""
            // date
            guard let seconds = model.timeStamp else { return }
            let time = Date(timeIntervalSince1970: seconds)
            self.timeLabel.text = self.dataFormatter.string(from: time)
        }
    }
    
    // MARK: - Settings view
    
    private func setViews() {
        contentView.addSubviews([imageAvatar, userLabel, messageLabel, timeLabel])
        setLayouts()
    }
    
    private func setLayouts() {
        imageAvatar.snp.makeConstraints {
            $0.height.width.equalTo(48)
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(8)
        }
        userLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(5)
            $0.width.equalTo(200)
            $0.height.equalTo(30)
            $0.leading.equalTo(imageAvatar.snp.trailing).offset(20)
        }
        messageLabel.snp.makeConstraints {
            $0.top.equalTo(userLabel.snp.bottom).offset(7)
            $0.width.equalTo(150)
            $0.height.equalTo(20)
            $0.leading.equalTo(imageAvatar.snp.trailing).offset(20)
        }
        timeLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.trailing.equalToSuperview().offset(-10)
            $0.height.equalTo(10)
            $0.width.equalTo(100)
        }
    }
    
}
