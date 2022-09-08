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
        guard let uid = Auth.auth().currentUser?.uid else {return}
        print("observe user messages")
        
        let ref = Database.database().reference().child("user-messages").child(uid)
        ref.observe(.childAdded, with: { (snapshot) in
            
            let userId = snapshot.key
            print(userId)
            Database.database().reference().child("user-messages").child(uid).child(userId).observe(.childAdded, with: { (snapshot) in
                
                let messageId = snapshot.key
                self.fetchMessageWithMessageId(messageId)
                
            }, withCancel: nil)
        }, withCancel: nil)
    }

    func fetchMessageWithMessageId(_ messageId: String) {
        let messagesReference = Database.database().reference().child("messages").child(messageId)

        messagesReference.observeSingleEvent(of: .value, with: { (snapshot) in

            if let dictionary = snapshot.value as? [String: AnyObject] {
                let message = Message(dictionary: dictionary)

                if let chatPartnerId = message.chatPartnerId() {
                    self.messagesDictionary[chatPartnerId] = message
                }

                self.attemptReloadOfTable()
            }

            }, withCancel: nil)
    }

    fileprivate func attemptReloadOfTable() {
        self.timer?.invalidate()

        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }

    var timer: Timer?

    @objc func handleReloadTable() {
        self.messages = Array(self.messagesDictionary.values)
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }
    
  
    func navigationConfigure(){
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
        print("0")
        print(messages)
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        print("1")
        
        let message = messages[indexPath.row]
        cell.message = message
        print(message)
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("2")
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
