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
import MobileCoreServices
import AVFoundation

class ChatLogController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ImageZoomable {
        
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
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: UIResponder.keyboardDidShowNotification, object:  nil)
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
    
    @objc private func handleKeyboardDidShow() {
        if messages.count > 0 {
            let indexpath = IndexPath(item: self.messages.count - 1, section: 0)
            self.collectionView.scrollToItem(at: indexpath, at: .bottom, animated: true)
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
        picker.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
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
    
    //MARK: - setting zoom image
    var startingFrame: CGRect?
    var blackBackgroundView: UIView?
    var startingImageView: UIImageView?
    
    func performZoomImage(_ imageView: UIImageView) {
        startingImageView = imageView
        startingImageView?.isHidden = true
        startingFrame = imageView.superview?.convert(imageView.frame, to: nil)
        //
        let zoomingImageView = UIImageView(frame: startingFrame!)
        zoomingImageView.image = imageView.image
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleBackZoom))
        zoomingImageView.addGestureRecognizer(tap)
        zoomingImageView.isUserInteractionEnabled = true
        //
        if let keyWindow = UIApplication.shared.keyWindow {
            blackBackgroundView = UIView(frame: keyWindow.frame)
            blackBackgroundView?.backgroundColor = .black
            blackBackgroundView?.alpha = 0
            keyWindow.addSubview(blackBackgroundView!)
            keyWindow.addSubview(zoomingImageView)
            //
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.blackBackgroundView?.alpha = 1
                self.containerView.alpha = 0
                let height = self.startingFrame!.height / self.startingFrame!.width * keyWindow.frame.width
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                zoomingImageView.center = keyWindow.center
            }, completion: nil)
        }
    }
    
    @objc private func handleBackZoom(_ tap: UITapGestureRecognizer) {
        guard let zoomOutImageView = tap.view as? UIImageView else { return }
        zoomOutImageView.layer.cornerRadius = 16
        zoomOutImageView.clipsToBounds = true
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut) {
            zoomOutImageView.frame = self.startingFrame!
            self.blackBackgroundView?.alpha = 0
            self.containerView.alpha = 1
        } completion: { _ in
            zoomOutImageView.removeFromSuperview()
            self.startingImageView?.isHidden = false
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
        cell.delegate = self
        let messages = messages[indexPath.row]
        if let text = messages.text {
            cell.bubbleWidthAnchor?.constant = estemateText(text).width + 30
            cell.textView.isHidden = false
        } else if messages.imageURL != nil {
            cell.bubbleWidthAnchor?.constant = 200
            cell.textView.isHidden = true
        }
        self.setupCell(cell, messages: messages)
        cell.configure(with: messages)
        let indexpath = IndexPath(item: self.messages.count - 1, section: 0)
        self.collectionView.scrollToItem(at: indexpath, at: .bottom, animated: true)
        return cell
    }
    
    private func setupCell(_ cell: ChatCollectionViewCell, messages: Messages) {
        if messages.fromUserID == Auth.auth().currentUser?.uid {
            cell.bubbleView.backgroundColor = ChatCollectionViewCell.colorBuubleView
            cell.bubbleRightAnchor?.isActive = true
            cell.bubbleLeftAnchor?.isActive = false
        } else {
            cell.bubbleView.backgroundColor = .gray
            cell.bubbleRightAnchor?.isActive = false
            cell.bubbleLeftAnchor?.isActive = true
        }
        guard let imageURL = messages.imageURL else { return }
        if let url = URL(string: imageURL) {
            cell.messageImage.sd_setImage(with: url)
            cell.messageImage.isHidden = false
        } else {
            cell.messageImage.isHidden = true
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


// bag in background textView
