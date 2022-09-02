//
//  HomeViewController.swift
//  chatApp
//
//  Created by Macbook on 01/09/22.
//

import UIKit
import FirebaseAuth

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationConfigure()
    }
    
    func navigationConfigure(){
        navigationItem.title = "CHATS"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(tappedLogout))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "New", style: .plain, target: self, action: #selector(tappedChat))
    }
    
    @objc func tappedLogout(){
        let firebaseAuth = Auth.auth()
               do {
                   try firebaseAuth.signOut()
                   let scene = UIApplication.shared.connectedScenes.first
                   if let sd : SceneDelegate = (scene?.delegate as? SceneDelegate) {
                       let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
                       if let homeVC = storyboard.instantiateViewController(withIdentifier: "ViewController") as? ViewController{
                           print("hello")
                          openAlert(title: "Alert", message: "Successfully Sign Out ", alertStyle: .alert, actionTitles: ["Okay"], actionStyles: [.default], actions: [{_ in }])
                           sd.window!.rootViewController = UINavigationController(rootViewController: homeVC)
                       }
                   }
               }
               catch let signOutError as NSError {
                   print("Error signing out: %@", signOutError)
               }
           }
    
    @objc func tappedChat(){
        let newMessageController  = NewMessageViewController()
        let navController  = UINavigationController(rootViewController: newMessageController)
        present(navController, animated: true, completion: nil)
    }
}
