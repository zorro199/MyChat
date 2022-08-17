//
//  LoginViewController.swift
//  MyChat
//
//  Created by Zaur on 13.08.2022.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class LoginViewController: UIViewController {
    
    //MARK: - VIEW
    
    private lazy var imageAvatar: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "chat-icon")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var inputsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 28, g: 36, b: 31)
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter your login"
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 5
        textField.isHidden = true
        return textField
    }()
    
    private lazy var loginLabel: UILabel = {
        let label = UILabel()
        label.text = "Login"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 30, weight: .heavy)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter your email"
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 5
        return textField
    }()
    
    private lazy var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter your password"
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 5
        textField.isSecureTextEntry = true
        return textField
    }()
    
    private lazy var loginRegisterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = UIColor(r: 28, g: 36, b: 31)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(handleLoginRegister), for: .touchUpInside)
        return button
    }()
    
    private lazy var titleEmpty: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .red
        label.text = "Fields is empty"
        label.isHidden = true
        return label
    }()
    
    private lazy var loginSegmentController: UISegmentedControl = {
        let segment = UISegmentedControl(items: ["Login", "Register"])
        segment.selectedSegmentIndex = 0
        segment.addTarget(self, action: #selector(segmentHandler), for: .valueChanged)
        segment.tintColor = .white
        
        return segment
    }()
    
    private lazy var myChatLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(r: 28, g: 36, b: 31)
        label.font = UIFont.systemFont(ofSize: 60, weight: .heavy)
        label.text = "My Chat"
        label.textAlignment = .center
        return label
    }()
    
    //MARK: - Handles @objc
    
    @objc private func segmentHandler() {
        switch loginSegmentController.selectedSegmentIndex {
        case 0: loginLabel.isHidden = false
                nameTextField.isHidden = true
                loginRegisterButton.setTitle("Login", for: .normal)
        case 1: loginLabel.isHidden = true
                nameTextField.isHidden = false
                loginRegisterButton.setTitle("Register", for: .normal)
        default: break
        }
    }
    
    @objc private func handleLoginRegister() {
        switch loginSegmentController.selectedSegmentIndex {
        case 0: handleLogin()
        case 1: handleRegister()
        default: break
        }
    }
    
    @objc private func handleLogin() {
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            print("----Error valid fields")
            return
        }
        Auth.auth().signIn(withEmail: email, password: password) { user, error in
            if error != nil {
                print("----Error SignIn")
                return
            }
            self.dismiss(animated: true )
        }
    }
    
    @objc private func handleRegister() {
        guard let name = nameTextField.text , let email = emailTextField.text, let password = passwordTextField.text else {
            print("-----error Text")
            return }
        
            Auth.auth().createUser(withEmail: email, password: password) { user, error in
                if error != nil {
                    print("------Error Auth", error?.localizedDescription ?? "")
                    return
                }
                
                guard let uid = user?.user.uid else { return }
                
                let refernces = Database.database().reference(fromURL: "https://mychat-d7b2e-default-rtdb.firebaseio.com/")
                 let userRefernce = refernces.child("users").child(uid)
                
                let values = ["name": name, "email": email]
                
                userRefernce.updateChildValues(values) { error, refernces in
                    if error != nil {
                        print("------Error refernces", error?.localizedDescription ?? "")
                        return
                    }
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
        view.addSubviews([loginSegmentController ,imageAvatar
                          ,inputsContainerView, loginRegisterButton,
                          titleEmpty, myChatLabel])
        inputsContainerView.addSubviews([nameTextField, loginLabel ,emailTextField, passwordTextField])
        setLayouts()
    }
    
    private func setLayouts() {
        loginSegmentController.snp.makeConstraints {
            $0.top.equalToSuperview().offset(60)
            $0.width.equalTo(200)
            $0.height.equalTo(30)
            $0.centerX.equalToSuperview()
        }
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
        loginLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(100)
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
        myChatLabel.snp.makeConstraints {
            $0.top.equalTo(loginRegisterButton.snp.bottom).offset(100)
            $0.leading.equalToSuperview().offset(50)
            $0.trailing.equalToSuperview().offset(-50)
            $0.height.equalTo(70)
        }
    }

}
