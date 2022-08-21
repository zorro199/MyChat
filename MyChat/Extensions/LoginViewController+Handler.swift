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
        guard let name = nameTextField.text , let email = emailTextField.text, let password = passwordTextField.text else {
            print("-----error Text")
            return }
        
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
        let refernces = Database.database().reference(fromURL: "https://mychat-d7b2e-default-rtdb.firebaseio.com/")
        let userRefernce = refernces.child("users").child(uid)
       userRefernce.updateChildValues(value) { error, refernces in
           if error != nil {
               print("------Error refernces", error?.localizedDescription ?? "")
               return
           }
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

