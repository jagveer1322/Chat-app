//
//  HomeViewController.swift
//  chatApp
//
//  Created by Macbook on 01/09/22.
//

import UIKit
import FirebaseAuth
import Firebase

class MessagesViewController: UITableViewController {
    
    let cellId = "cellId"
    
    var messages = [Message]()
    var messagesDictionary = [String: Message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.backgroundColor = .cyan
        view.backgroundColor = .white
        navigationConfigure()
        fetchUserAndSetupNavBarTitle()
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        
    }
    
    func observeUserMessages() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let ref = Database.database().reference().child("user-messages").child(uid)
        ref.observe(.childAdded, with: { (snapshot) in
            
            let messageId = snapshot.key
            let messagesReference = Database.database().reference().child("messages").child(messageId)
            messagesReference.getData { error, snapshot in
                if let _ = error{
                    print("error while fetching")
                    return
                }
                
                if let dictionary = snapshot?.value as? [String: AnyObject] {
                    let message = Message(dictionary: dictionary)
                    
                    if let chatPartnerId = message.chatPartnerId() {
                        self.messagesDictionary[chatPartnerId] = message
                        
                        self.messages = Array(self.messagesDictionary.values)
                        self.messages.sort(by: { (message1, message2) -> Bool in
                            if let timestamp1 = message1.timestamp, let timestamp2 = message2.timestamp {
                                return timestamp1.intValue > timestamp2.intValue
                            }
                            return false
                        })
                    }
                    
                    //this will crash because of background thread
                    DispatchQueue.main.async(execute: {
                        self.tableView.reloadData()
                    })
                }
            }
            
        }, withCancel: nil)
    }
    
//    func observeMessages() {
//
//        let ref = Database.database().reference().child("messages")
//
//        ref.observe(.childAdded, with: { (snapshot) in
//
//            if let dictionary = snapshot.value as? [String: AnyObject] {
//                let message = Message(dictionary: dictionary)
//                self.messages.append(message)
//                if let toId = message.toId {
//                    self.messagesDictionary[toId] = message
//                    self.messages = Array(self.messagesDictionary.values)
//                    self.messages.sort(by: { (message1, message2) -> Bool in
//                        if let timestamp1 = message1.timestamp, let timestamp2 = message2.timestamp {
//                            return timestamp1.intValue > timestamp2.intValue
//                        }
//                        return false
//                    })
//                }
//                print("message")
//
//                //this will crash because of background thread
//                DispatchQueue.main.async(execute: {
//                    self.tableView.reloadData()
//                })
//            }
//
//        }, withCancel: nil)
//    }
    
    func navigationConfigure(){
        //   observeMessages()
       observeUserMessages()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(tappedLogout))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "chat"), style: .plain, target: self, action: #selector(tappedChat))
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
        newMessageController.messagesViewController = self
        let navController  = UINavigationController(rootViewController: newMessageController)
        present(navController, animated: true, completion: nil)
    }
    
    func fetchUserAndSetupNavBarTitle() {
        
        guard let uid = Auth.auth().currentUser?.uid else { return}
        
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value) { snapshot in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let user = User(dictionary: dictionary)
                self.setupNavBarWithUser(user)
            }
        }
    }
    
    func setupNavBarWithUser(_ user: User) {
//        messages.removeAll()
//        messagesDictionary.removeAll()
//        observeUserMessages()
        
        let button = UIButton(type: .system)
        button.setTitle(user.username, for: .normal)
        button.addTarget(self, action: #selector(showChatControllerForUser), for: .touchUpInside)
        
        self.navigationItem.titleView = button
        self.navigationItem.titleView?.tintColor = .black
    }
    
    
    @objc func showChatControllerForUser(user: User) {
        let chatLogViewController = ChatLogViewController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogViewController.user = user
        self.navigationController?.pushViewController(chatLogViewController, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        let message = messages[indexPath.row]
        cell.message = message
        
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
          
        guard let chatPartnerId = message.chatPartnerId() else {
            return
        }
        let ref = Database.database().reference().child("users").child(chatPartnerId)
        ref.observeSingleEvent(of: .value) { (snapshot) in
            guard let  dictionary = snapshot.value as? [String: AnyObject]
            else{
                return
            }
            let user = User(dictionary: dictionary)
            user.id = chatPartnerId
            self.showChatControllerForUser(user: user)        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
}
