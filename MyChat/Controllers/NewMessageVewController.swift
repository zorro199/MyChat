//
//  NewMeassageController.swift
//  MyChat
//
//  Created by Zaur on 18.08.2022.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import Firebase
import FirebaseCore
import SDWebImage

class NewMessageVewController: UIViewController {
    
    var users = [Users]()
        
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
                    let user = try? JSONDecoder().decode(Users.self, from: data!)
                    self.users.append(user!)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    //MARK: - Settings view
    
    private func setNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
    }
    
    @objc private func handleCancel() {
        dismiss(animated: true)
    }
    
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

extension NewMessageVewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UsersTableViewCell.reuseId, for: indexPath) as? UsersTableViewCell else { return UITableViewCell() }
        let user = users[indexPath.row]
        // need to set dispatchGroup
        if let imageProfile = user.profileImage {
            cell.imageView?.sd_setImage(with: URL(string: imageProfile))
            cell.imageView?.contentMode = .scaleAspectFill
        }
        cell.textLabel?.text = user.name
        return cell
    }
    
}

