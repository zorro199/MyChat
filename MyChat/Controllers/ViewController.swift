//
//  ViewController.swift
//  MyChat
//
//  Created by Zaur on 13.08.2022.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .gray
        return tableView
    }()
    
    //MARK: - viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setNavigationBar()
        setViews()
    }

    //MARK: - Settings view
    
    private func setNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Выйти", style: .plain, target: self, action: #selector(handleLogin))
    }
    
    @objc private func handleLogin() {
        let loginViewController = LoginViewController()
        loginViewController.modalPresentationStyle = .fullScreen
        present(loginViewController, animated: false)
        
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

