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
    
    var messages = [Messages]()
    var messageDictionary = [String: Messages]()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(MessagesTableViewCell.self, forCellReuseIdentifier: MessagesTableViewCell.reuseId)
        tableView.backgroundColor = .gray
        return tableView
    }()
    
    //MARK: - viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        checkUser()
        setNavigationBar()
        observeMessages()
        setViews()
    }

    //MARK: - Settings view
    
    private func setNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose , target: self, action: #selector(handleNewMessage))
    }
    
    private func observeMessages() {
        let referance = Database.database().reference().child("messages")
        referance.observe(.childAdded) { snapshot in
            guard let dictionary = snapshot.value as? [String:Any] else {
                print("error Dictionary")
                return
            }
            let data = try? JSONSerialization.data(withJSONObject: dictionary, options: [])
            guard let data = data else {
            print("data error")
            return }
            let message = try? JSONDecoder().decode(Messages.self, from: data)
            guard let message = message else {
            print("error messages")
            return }
            self.messages.append(message)
            if let toUserId = message.toUserID {
                self.messageDictionary[toUserId] = message
                self.messages = Array(self.messageDictionary.values)
                self.messages.sort (by: { (mes, mes2) -> Bool in
                    return (mes.timeStamp ?? 0)! > (mes2.timeStamp ?? 0)!
                })
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
           }
        } withCancel: { _ in
        }

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
    
    func ShowChatLogController(_ user: Users) { 
        let chatLogController = ChatLogController()
        chatLogController.user = user 
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

extension MessagesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MessagesTableViewCell.reuseId, for: indexPath) as? MessagesTableViewCell else { return UITableViewCell() }
        let message = messages[indexPath.row]
        cell.configure(with: message)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    
}


/*
 let data = try? JSONSerialization.data(withJSONObject: dictionary, options: [])
 guard let data = data else {
 print("data error")
 return }
 print(data)
 let message = try? JSONDecoder().decode(Message.self, from: data)
 guard let message = message else {
 print("error messages")
 return }
 print(message)
 DispatchQueue.main.async {
     self.tableView.reloadData()
}
 
 if let toUserId = message.toUserID {
     self.messageDictionary[toUserId] = message
     self.messages = Array(self.messageDictionary.values)
     self.messages.sort { message1, message2 -> Bool in
         return (Int(message1.timeStamp ?? ""))! > (Int(message2.timeStamp ?? ""))!
     }
 }
 
 */