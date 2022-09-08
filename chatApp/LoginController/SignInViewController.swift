//
//  SignInViewController.swift
//  chatApp
//
//  Created by Macbook on 29/08/22.
//

import UIKit
import FirebaseAuth
import Firebase

class SignInViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func signInButton(_ sender: UIButton) {
        
        if let email = emailTextField.text, let password = passwordTextField.text{
            
            if !email.validateEmail(){
                openAlert(title: "Alert", message: "Please enter valid email.", alertStyle: .alert, actionTitles: ["Okay"], actionStyles: [.default], actions: [{ _ in
                    
                }])
            }else if !password.validatePassword(){
                openAlert(title: "Alert", message: "Please enter valid password", alertStyle: .alert, actionTitles: ["Okay"], actionStyles: [.default], actions: [{ _ in
                    
                }])
                
            }
            
            else {
                Auth.auth().signIn(withEmail: email, password: password) { (result, err) in

                if err != nil {
                    
                    self.openAlert(title: "Alert", message: "Login Detail not match", alertStyle: .alert, actionTitles: ["Okay"], actionStyles: [.default], actions: [{_ in }])
                } else {
                    
                    let scene = UIApplication.shared.connectedScenes.first
                    if let sd : SceneDelegate = (scene?.delegate as? SceneDelegate) {
                        let messagesViewController = MessagesViewController()
                        let nav = UINavigationController.init(rootViewController: messagesViewController)
                        sd.window!.rootViewController = nav
                    }
                }
            }
            }
        }
    }
}
