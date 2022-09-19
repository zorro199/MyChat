//
//  ChatCollectionViewCell.swift
//  MyChat
//
//  Created by Zaur on 03.09.2022.
//

import UIKit
import SnapKit
import SDWebImage
import AVFoundation

protocol ImageZoomable {
    func performZoomImage(_ imageView: UIImageView)
}

class ChatCollectionViewCell: UICollectionViewCell {
    
    static let reuseID = "ChatCollectionViewCell"
    
    var delegate: ImageZoomable?
    
    var message: Messages?
    
    var activityIndicator: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(style: .large)
        aiv.hidesWhenStopped = true
        return aiv
    }()
    
    lazy var playButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "play"), for: .normal)
        button.addTarget(self, action: #selector(handlePlayVideo), for: .touchUpInside)
        return button
    }()
    
    lazy var pauseButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(handlePauseVideo), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    var playerLayer: AVPlayerLayer?
    var player: AVPlayer?
    
    @objc private func handlePlayVideo() {
        guard let videoUrl = message?.videoUrl, let url = URL(string: videoUrl) else { return }
        player = AVPlayer(url: url)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.frame = self.bubbleView.bounds
        bubbleView.layer.addSublayer(playerLayer!)
        player?.play()
        activityIndicator.startAnimating()
        self.playButton.isHidden = true
        self.pauseButton.isHidden = false
    }
    
    @objc private func handlePauseVideo() {
        player?.pause()
        activityIndicator.stopAnimating()
        self.playButton.isHidden = false
        self.pauseButton.isHidden = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        playerLayer?.removeAllAnimations()
        player?.pause()
        activityIndicator.stopAnimating()
    }
    
    lazy var textView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.textColor = .white
        textView.backgroundColor = .clear
        textView.isEditable = false
        textView.font = UIFont.systemFont(ofSize: 16)
        return textView
    }()
    
    static let colorBuubleView = UIColor.black
    
    let bubbleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = colorBuubleView
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()
    
    lazy var messageImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTapImage))
        imageView.addGestureRecognizer(tap)
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    //MARK: - init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // configure
    
    func configure(with model: Messages) {
        guard let text = model.text else { return }
        textView.text = text
    }
    
    @objc func handleTapImage(_ gesture: UITapGestureRecognizer) {
        if message?.videoUrl != nil {
            return
        }
        guard let imageView = gesture.view as? UIImageView else { return }
        delegate?.performZoomImage(imageView)
    }
    
    // MARK: - Settings view
    
    private func setViews() {
        contentView.addSubviews([bubbleView, textView])
        bubbleView.addSubviews([messageImage, playButton, activityIndicator, pauseButton])
        setLayouts()
    }
    
    var bubbleWidthAnchor: NSLayoutConstraint?
    var bubbleRightAnchor: NSLayoutConstraint?
    var bubbleLeftAnchor: NSLayoutConstraint?
    
    private func setLayouts() {
        bubbleRightAnchor = bubbleView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8)
        bubbleRightAnchor?.isActive = true
        bubbleLeftAnchor = bubbleView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8)
        bubbleLeftAnchor?.isActive = false 
        bubbleView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        bubbleWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 200)
        bubbleWidthAnchor?.isActive = true
        bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        //
        textView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 8).isActive = true
        textView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        textView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive = true
        textView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        //
        messageImage.snp.makeConstraints {
            $0.left.equalTo(bubbleView.snp.left)
            $0.right.equalTo(bubbleView.snp.right)
            $0.top.equalTo(bubbleView.snp.top)
            $0.bottom.equalTo(bubbleView.snp.bottom)
        }
        playButton.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
            $0.height.width.equalTo(50)
        }
        pauseButton.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
            $0.height.width.equalTo(50)
        }
        activityIndicator.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
            $0.height.width.equalTo(50)
        }
        
    }
    
}
