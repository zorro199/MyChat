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
import FirebaseStorage

class ChatLogController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
        collection.keyboardDismissMode = .interactive
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray4
        view.translatesAutoresizingMaskIntoConstraints = false
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
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 8
        textField.clipsToBounds = true
        textField.delegate = self
        return textField
    }()
    
    private lazy var imageButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "imageIcon"), for: .normal)
        button.layer.cornerRadius = 5
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(handleSendImage), for: .touchUpInside)
        return button
    }()
    
    private lazy var separator = UIView.horizontalSeparator(.gray, height: 3)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setViews()
        observeMessages()
        setupKeyboardObserves()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    // keyboard setup
    func setupKeyboardObserves() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func handleKeyboardWillShow(notification: Notification) {
        let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
        let keyboardDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        containerViewBottomAnchor?.constant = -keyboardFrame.height
        UIView.animate(withDuration: keyboardDuration) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func handleKeyboardWillHide(notification: Notification) {
        let keyboardDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        containerViewBottomAnchor?.constant = 0
        UIView.animate(withDuration: keyboardDuration) {
            self.view.layoutIfNeeded()
        }
    }
    
    // send message
    @objc private func handleSendButton() {
        guard let toUserID = user?.id else { return }
        let referanceD = Database.database().reference().child("messages")
        let childReferance = referanceD.childByAutoId()
        guard let message = messageTextField.text else { return }
        guard let fromUserID = Auth.auth().currentUser?.uid else { return }
        let timeStamp = NSDate().timeIntervalSince1970
        if self.messageTextField.text?.isEmpty == false {
            let values = ["text": message, "toUserID": toUserID,
                          "fromUserID": fromUserID, "timeStamp": timeStamp] as [String: Any]
            childReferance.updateChildValues(values)
            messageTextField.text = nil
        }
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
        textField.resignFirstResponder()
        return true
    }
    
//    override var inputAccessoryView: UIView? {
//        get {
//            return containerView
//        }
//    }
    
    override var canBecomeFirstResponder: Bool {
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
                    print("---", userMessages.text ?? "nil")
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
        containerView.addSubviews([sendButton, messageTextField, imageButton])
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
            $0.top.equalToSuperview().offset(10)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(30)
            $0.width.equalTo(50)
        }
        messageTextField.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.height.equalTo(30)
            $0.leading.equalTo(imageButton.snp.trailing).offset(10)
            $0.trailing.equalTo(sendButton.snp.leading).offset(-8)
        }
        imageButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.leading.equalToSuperview().offset(7)
            $0.width.height.equalTo(30)
        }
    }
 
    // MARK: - send image

    @objc private func handleSendImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.isEditing = true
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        self.uploadFirebaseStorageImage(image)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    
   private func uploadFirebaseStorageImage(_ image: UIImage) {
        let imageName = UUID().uuidString
        let referance = Storage.storage().reference().child("message_images").child(imageName)
        guard let uploadData = image.jpegData(compressionQuality: 0.4) else { return }
        referance.putData(uploadData, metadata: nil) { metaData, error in
            if error != nil {
                print("---Error send image")
                return
            }
            referance.downloadURL { url, error in
                if error != nil {
                    print("---Error url")
                    return
                }
                guard let url = url?.absoluteString else { return }
                self.sendImageWithUrl(url, image: image)
            }
        }
    }
    
    private func sendImageWithUrl(_ imageURL: String, image: UIImage) {
        let ref = Database.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let toUserID = user?.id ?? "nil user id"
        let fromUserID = Auth.auth().currentUser?.uid ?? "nil uid"
        let timeStamp = Date().timeIntervalSince1970
        let values = ["toUserID": toUserID,
                      "fromUserID": fromUserID,
                      "timeStamp": timeStamp,
                      "imageURL": imageURL,
                      "imageWidth": image.size.width,
                      "imageHeight": image.size.height] as [String : Any]
        childRef.updateChildValues(values)
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
        if messages.imageURL != nil {
            cell.bubbleWidthAnchor?.constant = 200
        }
        cell.configure(with: messages)
        self.setupCell(cell, messages: messages)
        let indexpath = IndexPath(item: self.messages.count - 1, section: 0)
        self.collectionView.scrollToItem(at: indexpath, at: .bottom, animated: true)
        return cell
    }
    
    private func setupCell(_ cell: ChatCollectionViewCell, messages: Messages) {
        guard let imageURL = messages.imageURL else { return }
        if let url = URL(string: imageURL) {
            cell.messageImage.sd_setImage(with: url)
            cell.messageImage.isHidden = false
        } else {
            cell.messageImage.isHidden = true
        }
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
        
        let message = messages[indexPath.row]
        if let messages = message.text {
            height = estemateText(messages).height + 15
        } else if let imageWidth = message.imageWidth, let imageHeight = message.imageHeight {
            height = CGFloat(imageHeight / imageWidth * 200)
        }
        return CGSize(width: view.frame.width , height: height)
    }
    
}
