//
//  ViewController.swift
//  MyChat
//
//  Created by Zaur on 13.08.2022.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import SnapKit

class MessagesViewController: UIViewController {
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .gray
        return tableView
    }()
    
    //MARK: - viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        checkUser()
        setNavigationBar()
        setViews()
    }

    //MARK: - Settings view
    
    private func setNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose , target: self, action: #selector(handleNewMessage))
    }
    
    @objc private func handleNewMessage() {
        let newMessageVC = NewMessageVewController()
        newMessageVC.messagesViewController = self
        let navigationVC = UINavigationController(rootViewController: newMessageVC)
        navigationVC.modalPresentationStyle = .fullScreen
        present(navigationVC, animated: true)
    }
    
    private func checkUser() {
        if Auth.auth().currentUser == nil {
            perform(#selector(handleLogout))
        } else {
            setupNameUserTitle()
        }
    }
    
    func setupNameUserTitle() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value) { snapshot in
            if let dictionary = snapshot.value as? [String: Any] {
                let name = dictionary["name"] as? String
                let label = UILabel()
                label.text = name
                label.textAlignment = .center
                label.frame = CGRect(x: 0, y: 0, width: 150, height: 40)
                self.navigationItem.titleView = label
//                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleShowChatController))
//                label.isUserInteractionEnabled = true
//                label.addGestureRecognizer(tapGesture)
            }
        }
    }
    
    //MARK: - Handles @objc
    
    @objc private func handleLogout() {
        do {
            try Auth.auth().signOut()
        } catch let ErrorSignout {
            print(ErrorSignout)
        }
        
        let loginViewController = LoginViewController()
        loginViewController.messagesViewController = self // 🤔
        loginViewController.modalPresentationStyle = .fullScreen
        present(loginViewController, animated: false)
    }
    
     func ShowChatLogController() { // resume 
        let chatLogController = ChatLogController()
        navigationController?.pushViewController(chatLogController, animated: true) 
    }
    
    //MARK: - Set Views
    
    private func setViews() {
        view.addSubviews([tableView])
        setLayouts()
    }

    private func setLayouts() {
        tableView.snp.makeConstraints {
            $0.top.equalTo(view.snp.topMargin)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
}

