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
                        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                            if error != nil{
                                print("something went wrong")
                                return}
                            
                            guard let uid = authResult?.user.uid else {
                                return
                            }
                            let ref = Database.database().reference(fromURL: "https://chatapp-d4a0f-default-rtdb.firebaseio.com")
                            let values = ["name": username, "email": email]
                            let userReference = ref.child("users").child(uid)
                            userReference.updateChildValues(values) { (error, ref) in
                                if error != nil{
                                    print("something went wrong")
                                    return
                                }
                            }
                            self.navigationController?.popViewController(animated: true)
                        }
                        
                        
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
            picker.delegate = self
            picker.sourceType = .savedPhotosAlbum
            present(picker, animated: true)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let img = info[.originalImage] as? UIImage{
            imageProfile.image = img
        }
        dismiss(animated: true)
    }
}

