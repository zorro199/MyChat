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

class NewMessageVewController: UIViewController {
    
    let users = [User]()
        
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
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
        DispatchQueue.main.async {
            Database.database().reference().child("users").observe(.childAdded) { snapshot in
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    let user = User(dictionary: dictionary)
                    user.setValuesForKeys(dictionary)
                    print(user.name)
                }
                
            } withCancel: { error in
                print(error)
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
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.textLabel?.text = "Test"
        return cell
    }
    
}
