//
//  ChatLogController.swift
//  MyChat
//
//  Created by Zaur on 24.08.2022.
//

import UIKit
import SnapKit
import FirebaseDatabase

class ChatLogController: UIViewController, UITextFieldDelegate {
    
    private lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        let collection = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collection.backgroundColor = .white
        return collection
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private lazy var sendButton: UIButton = {
        let button = UIButton()
        button.setTitle("Send", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(handleSendButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var messageTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter message"
        textField.delegate = self
        return textField
    }()
    
    private lazy var separator = UIView.horizontalSeparator(.gray, height: 3)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setViews()
    }
    
    @objc private func handleSendButton() {
        let referance = Database.database().reference().child("messages")
        let childReferance = referance.childByAutoId()
        guard let message = messageTextField.text else { return }
        let values = ["text": message, "name": "Zorro"] as [String: Any]
        childReferance.updateChildValues(values)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSendButton()
        return true
    }
    
    //MARK: - Settings view
    
    private func setViews() {
        view.addSubviews([collectionView, containerView, separator])
        containerView.addSubviews([sendButton, messageTextField])
        setLayouts()
    }
    
    private func setLayouts() {
        collectionView.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            $0.bottom.equalTo(separator.snp.top)
        }
        separator.snp.makeConstraints {
            $0.top.equalTo(collectionView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(containerView.snp.top)
        }
        containerView.snp.makeConstraints {
            $0.top.equalTo(separator.snp.bottom)
            $0.trailing.leading.bottom.equalToSuperview()
            $0.height.equalTo(80)
        }
        sendButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-30)
            $0.height.equalTo(30)
            $0.width.equalTo(50)
        }
        messageTextField.snp.makeConstraints {
            $0.left.equalToSuperview().offset(8)
            $0.centerY.equalToSuperview()
            $0.trailing.equalTo(sendButton.snp.leading).offset(-8)
        }
    }
    
}
