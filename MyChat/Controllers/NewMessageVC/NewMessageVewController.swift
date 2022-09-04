//
//  NewMeassageController.swift
//  MyChat
//
//  Created by Zaur on 18.08.2022.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import SDWebImage

class NewMessageVewController: UIViewController {
    
    var users = [Users]()
    
    weak var messagesViewController: MessagesViewController?
        
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UsersTableViewCell.self, forCellReuseIdentifier: UsersTableViewCell.reuseId)
        return tableView
    }()
    
    //MARK: - viewDidLoad
    
        override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        fetchUser()
        setNavigationBar()
        setViews()
    }
    
    private func fetchUser() {
        Database.database().reference().child("users").observe(.childAdded) { snapshot in
            if let dictionary = snapshot.value as? [String: Any] {
                do {
                    let data = try? JSONSerialization.data(withJSONObject: dictionary, options: [])
                    guard let data = data else { return }
                    let user = try? JSONDecoder().decode(Users.self, from: data)
                    guard var user = user else { return }
                    user.id = snapshot.key
                    self.users.append(user)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    private func setNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
    }
    
    @objc private func handleCancel() {
        dismiss(animated: true)
    }
    
    //MARK: - Settings view
    
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
    
    private func showChatLogController(user: User) {
        let chatViewController = ChatLogController()
        navigationController?.pushViewController(chatViewController, animated: true)
    }
}


extension NewMessageVewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UsersTableViewCell.reuseId, for: indexPath) as? UsersTableViewCell else { return UITableViewCell() }
        let user = users[indexPath.row]
        cell.configure(with: user)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dismiss(animated: true) {
            let user = self.users[indexPath.row]
            self.messagesViewController?.ShowChatLogController(user)
        }
    }
    
}
