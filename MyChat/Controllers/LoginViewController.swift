//
//  LoginViewController.swift
//  MyChat
//
//  Created by Zaur on 13.08.2022.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseDatabase

class LoginViewController: UIViewController {
    
    private lazy var imageAvatar: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "chat-icon")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var inputsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 100, g: 200, b: 150)
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите логин"
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 5
        return textField
    }()
    
    private lazy var emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите email"
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 5
        return textField
    }()
    
    private lazy var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите пароль"
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 5
        textField.isSecureTextEntry = true
        return textField
    }()
    
    private lazy var loginRegisterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Регистрация", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = UIColor(r: 100, g: 200, b: 150)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        return button
    }()
    
    private lazy var titleEmpty: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .red
        label.text = "Поля должны быть заполнены"
        label.isHidden = true
        return label
    }()
    
    @objc private func handleLogin() {
        guard let name = nameTextField.text , let email = emailTextField.text, let password = passwordTextField.text else { return }
        if nameTextField.state.isEmpty, emailTextField.state.isEmpty, passwordTextField.state.isEmpty{
            titleEmpty.isHidden = false
        } else {
            Auth.auth().createUser(withEmail: email, password: password) { userData, error in
                guard error != nil else {
                    print("Error Auth")
                    return }
                let refernces = Database.database().reference(fromURL: "https://console.firebase.google.com/project/mychat-d7b2e/firestore/data/~2F")
                //
            }
        }
    }
    
    //MARK: - viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setViews()
    }
    
    //MARK: - Settings view
    
    private func setViews() {
        view.addSubviews([imageAvatar ,inputsContainerView, loginRegisterButton, titleEmpty])
        inputsContainerView.addSubviews([nameTextField, emailTextField, passwordTextField])
        setLayouts()
    }
    
    private func setLayouts() {
        imageAvatar.snp.makeConstraints {
            $0.top.equalToSuperview().offset(100)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(200)
            $0.height.equalTo(200)
        }
        titleEmpty.snp.makeConstraints {
            $0.bottom.equalTo(inputsContainerView.snp.top).offset(-30)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(10)
            $0.width.equalTo(200)
        }
        inputsContainerView.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
            $0.height.equalTo(180)
        }
        nameTextField.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-30)
            $0.height.equalTo(40)
        }
        emailTextField.snp.makeConstraints {
            $0.top.equalTo(nameTextField.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-30)
            $0.height.equalTo(40)
        }
        passwordTextField.snp.makeConstraints {
            $0.top.equalTo(emailTextField.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-30)
            $0.height.equalTo(40)
        }
        loginRegisterButton.snp.makeConstraints {
            $0.top.equalTo(inputsContainerView.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(100)
            $0.trailing.equalToSuperview().offset(-100)
            $0.height.equalTo(50)
        }
    }

}
