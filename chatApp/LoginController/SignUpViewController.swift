//
//  SignUpViewController.swift
//  chatApp
//
//  Created by Macbook on 29/08/22.
//

import UIKit
import FirebaseAuth
import Firebase

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var imageProfile: UIImageView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        imageProfile.addGestureRecognizer(tapGesture)
        
    }
    @objc
    func imageTapped(){
        print("image tap")
        openGallery()
    }
    
    @IBAction func signUpButton(_ sender: UIButton) {
        let imgSystem = UIImage(systemName: "face.smiling")
        if imageProfile.image?.pngData() != imgSystem?.pngData(){
            guard let profileImage = imageProfile.image else { return }
            
            if let username = usernameTextField.text, let email = emailTextField.text, let password = passwordTextField.text, let confirmPassword = confirmPasswordTextField.text{
                if username == ""{
                    openAlert(title: "Alert", message: "Please enter username", alertStyle: .alert, actionTitles: ["Okay"], actionStyles: [.default], actions: [{_ in }])
                    
                }else if !email.validateEmail(){
                    openAlert(title: "Alert", message: "Please enter valid email", alertStyle: .alert, actionTitles: ["Okay"], actionStyles: [.default], actions: [{_ in }])
                    
                }else if !password.validatePassword(){
                    openAlert(title: "Alert", message: "Please enter valid password", alertStyle: .alert, actionTitles: ["Okay"], actionStyles: [.default], actions: [{_ in }])
                    
                }else if confirmPassword == ""{
                    openAlert(title: "Alert", message: "Please enter confirm password", alertStyle: .alert, actionTitles: ["Okay"], actionStyles: [.default], actions: [{_ in }])
                }else
                {
                    if password == confirmPassword{
                        ChatService.shared.registerUserInDatabase(username: username, email: email, password: password, image: profileImage) { isSuccess in
                            if !isSuccess {
                                print("error")
                            }
                            else {
                                self.dismiss(animated: true)                            }
                        }
                        navigationController?.popViewController(animated: true)
                    }else{
                        openAlert(title: "Alert", message: "Please enter Same password", alertStyle: .alert, actionTitles: ["Okay"], actionStyles: [.default], actions: [{_ in }])
                    }
                }
            }else{
                openAlert(title: "Alert", message: "Please check your details", alertStyle: .alert, actionTitles: ["Okay"], actionStyles: [.default], actions: [{_ in }])
            }
        }else{
            print("Please select profile picture")
            openAlert(title: "Alert", message: "Please select profile picture", alertStyle: .alert, actionTitles: ["Okay"], actionStyles: [.default], actions: [{_ in }])
        }
    }
}


extension SignUpViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    
    func openGallery(){
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            let picker = UIImagePickerController()
            picker.allowsEditing = true
            picker.delegate = self
            picker.sourceType = .photoLibrary
            present(picker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let imageOrignal = info[.originalImage] as? UIImage{
            imageProfile.image = imageOrignal
        }
        picker.dismiss(animated: true)
    }
}

