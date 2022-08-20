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
                
                let storage = Storage.storage().reference().child("image.png")
                guard let imageData = self.imageAvatar.image?.pngData() else { return }
                storage.putData(imageData, metadata: nil) { (metaData: StorageMetadata?, error: Error?) in
                    if error != nil {
                        print("---Error metaData")
                        return
                    }
                        
                }
                
//                let refernces = Database.database().reference(fromURL: "https://mychat-d7b2e-default-rtdb.firebaseio.com/")
//                 let userRefernce = refernces.child("users").child(uid)
//                let values = ["name": name, "email": email]
//                userRefernce.updateChildValues(values) { error, refernces in
//                    if error != nil {
//                        print("------Error refernces", error?.localizedDescription ?? "")
//                        return
//                    }
//                }
             }
        self.dismiss(animated: true )
    }
 
    @objc func handleTapAvatar() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.isEditing = true
        present(picker, animated: true)
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
    
    //MARK: - Image Picker
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var selectedImage: UIImage?
        
        if let editedImage = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerImage")] as? UIImage {
            selectedImage = editedImage
        } else if let originalImages = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerOriginalImage")] as? UIImage {
            selectedImage = originalImages
        }
        
        if let selectedImages = selectedImage {
            self.imageAvatar.image = selectedImages
        }
        dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    
}

}
