//
//  ChatLogController.swift
//  MyChat
//
//  Created by Zaur on 24.08.2022.
//

import UIKit
import SnapKit
import FirebaseDatabase
import FirebaseAuth

class ChatLogController: UIViewController, UITextFieldDelegate {
    
    var user: Users? {
        didSet {
            navigationItem.title = user?.name
            observeMessages()
        }
    }
    
    var messages = [Messages]()
    
    private lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        let collection = UICollectionView(frame: .null, collectionViewLayout: flowLayout)
        collection.contentInset = UIEdgeInsets(top: 8 , left: 0, bottom: 0, right: 0)
        collection.alwaysBounceVertical = true
         collection.register(ChatCollectionViewCell.self, forCellWithReuseIdentifier: ChatCollectionViewCell.reuseID)
        collection.delegate = self
        collection.dataSource = self
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
        observeMessages()
    }
    
    @objc private func handleSendButton() {
        guard let toUserID = user?.id else { return }
        let referanceD = Database.database().reference().child("messages")
        let childReferance = referanceD.childByAutoId()
        guard let message = messageTextField.text else { return }
        guard let fromUserID = Auth.auth().currentUser?.uid else { return }
        let timeStamp = NSDate().timeIntervalSince1970
        let values = ["text": message, "toUserID": toUserID,
                      "fromUserID": fromUserID, "timeStamp": timeStamp] as [String: Any]
        childReferance.updateChildValues(values)
        messageTextField.text = nil
    }
    
    private func estemateText(_ text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let attributes: [NSAttributedString.Key : Any] = [.font : UIFont.systemFont(ofSize: 16)]
        return NSString(string: text).boundingRect(with: size, options: options, attributes: attributes, context: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSendButton()
        return true
    }
    
    private func observeMessages() {
        let userMessageRef = Database.database().reference().child("messages")
        userMessageRef.observe(.childAdded) { snapshot in
            guard let dictionary = snapshot.value as? [String:Any] else {
                print("-error-Dict")
                return
            }
            let data = try? JSONSerialization.data(withJSONObject: dictionary, options: [])
            guard let data = data else { return }
            let userMessages = try? JSONDecoder().decode(Messages.self, from: data)
            guard let userMessages = userMessages else { return }
            if self.user?.id == userMessages.chatPartner() {
                print("---", userMessages.text!)
                self.messages.append(userMessages)
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        } withCancel: { _ in
        }
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


extension ChatLogController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChatCollectionViewCell.reuseID, for: indexPath) as? ChatCollectionViewCell else {
            return UICollectionViewCell()
        }
        let messages = messages[indexPath.row]
        cell.bubbleWidthAnchor?.constant = estemateText(messages.text ?? "").width + 30
        cell.configure(with: messages)
        self.setupCellColor(cell, messages: messages)
        return cell
    }
    
    private func setupCellColor(_ cell: ChatCollectionViewCell, messages: Messages) {
        if messages.fromUserID == Auth.auth().currentUser?.uid {
            cell.bubbleView.backgroundColor = ChatCollectionViewCell.colorBuubleView
            cell.bubbleRightAnchor?.isActive = true
            cell.bubbleLeftAnchor?.isActive = false
        } else {
            cell.bubbleView.backgroundColor = .gray
            cell.bubbleRightAnchor?.isActive = false
            cell.bubbleLeftAnchor?.isActive = true
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 80
        if let messages = messages[indexPath.row].text {
            height = estemateText(messages).height + 15
        }
        return CGSize(width: view.frame.width , height: height)
    }
    
}
