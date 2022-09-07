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
            //observeMessages()
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
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        view.translatesAutoresizingMaskIntoConstraints = false // add color 
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
        setupKeyboardObserves()
    }
    
    // keyboard setup
    func setupKeyboardObserves() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    @objc private func handleKeyboardWillShow(notification: Notification) {
        let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
        containerViewBottomAnchor?.constant = -keyboardFrame.height
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
    
    var containerViewBottomAnchor: NSLayoutConstraint?
    var separatorViewBottomAnchor: NSLayoutConstraint?
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
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
        view.addSubviews([collectionView, containerView])
        containerView.addSubviews([sendButton, messageTextField])
        setLayouts()
    }
    
    private func setLayouts() {
        collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        collectionView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        //
        containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        containerView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        containerViewBottomAnchor = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        containerViewBottomAnchor?.isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        //
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
