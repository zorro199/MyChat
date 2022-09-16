//
//  LoginViewController + Handler.swift
//  MyChat
//
//  Created by Zaur on 19.08.2022.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

extension LoginViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc func handleRegister() {
        guard let email = emailTextField.text, emailTextField.text!.count != 0 else {
            self.errorSignInLabel.isHidden = false
            self.errorSignInLabel.text = "Please enter email"
            return
        }
        if isValidEmail(email) == false {
            self.errorSignInLabel.isHidden = false
            self.errorSignInLabel.text = "Wrong valid email"
        }
        guard let name = nameTextField.text, nameTextField.text!.count >= 4 else {
            self.errorSignInLabel.isHidden = false
            self.errorSignInLabel.text = "Name at least is must be 4 symbols"
            return
        }
        guard let password = passwordTextField.text, passwordTextField.text!.count >= 6 else {
            self.errorSignInLabel.isHidden = false
            self.errorSignInLabel.text = "Password at least is must be 6 symbols"
            return
        }
        Auth.auth().createUser(withEmail: email, password: password) { user, error in
            if error != nil {
                print("------Error Auth", error?.localizedDescription ?? "")
                return
            }
            guard let uid = user?.user.uid else { return }
            //storage
            let imageName = UUID().uuidString
            let storage = Storage.storage().reference().child("profileImages").child("\(imageName).jpeg")
            guard let imageData = self.imageAvatar.image?.jpegData(compressionQuality: 0.4) else { return }
            storage.putData(imageData, metadata: nil) { metaData, error in
                if error != nil {
                    print("---Error metaData")
                    return
                }
                storage.downloadURL { url, error in
                    if error != nil {
                        print("---Error url")
                        return
                    }
                    guard let urlImage = url?.absoluteString else { return }
                    let value = ["name": name, "email": email, "profileImage": urlImage]
                    self.registerWithUserUID(uid: uid, value: value)
                }
            }
        }
        self.dismiss(animated: true )
    }

    private func registerWithUserUID(uid: String, value: [String: Any]) {
        let refernces = Database.database().reference(fromURL: "https://mychat-4ba3e-default-rtdb.firebaseio.com/")
        let userRefernce = refernces.child("users").child(uid)
        userRefernce.updateChildValues(value) { error, refernces in
            if error != nil {
                print("------Error refernces", error?.localizedDescription ?? "")
                return
            }
            self.messagesViewController?.navigationItem.title = value["name"] as? String
            self.dismiss(animated: true)
        }
    }
    
    @objc func handleTapAvatar() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.isEditing = true
        present(picker, animated: true)
    }
    
    //MARK: - Image Picker
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        self.imageAvatar.image = image
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
  }

