//
//  ChatCollectionViewCell.swift
//  MyChat
//
//  Created by Zaur on 03.09.2022.
//

import UIKit
import SnapKit

class ChatCollectionViewCell: UICollectionViewCell {
    
    static let reuseID = "ChatCollectionViewCell"
    
    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.textColor = .white
        textView.backgroundColor = .clear
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
    
    // MARK: - Settings view
    
    private func setViews() {
        contentView.addSubviews([bubbleView ,textView])
        setLayouts()
    }
    
    var bubbleWidth: NSLayoutConstraint?
    
    private func setLayouts() {
        bubbleView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8).isActive = true
        bubbleView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.bubbleWidth = bubbleView.widthAnchor.constraint(equalToConstant: 200)
        bubbleWidth?.isActive = true
        bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        //
        textView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 8).isActive = true
        textView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        textView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive = true
        textView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
    }
    
}
