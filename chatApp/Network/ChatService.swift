//
//  UserService.swift
//  chatApp
//
//  Created by Macbook on 03/09/22.
//

import Foundation
import UIKit
import Firebase

struct ChatService{
    
    static let shared = ChatService()
    
    func registerUserInDatabase(username: String, email: String, password: String, image: UIImage,completion: @escaping (Bool) -> Void) {
        
        uploadImage(image: image) { profileImageUrl in
            
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if error != nil{
                    print("something went wrong")
                    return}
                
                guard let uid = authResult?.user.uid else {
                    return
                }
                let ref = Database.database().reference()
                
                //                    (fromURL: "https://chatapp-d4a0f-default-rtdb.firebaseio.com")
               
                let userReference = ref.child("users").child(uid)
                let values = ["username": username, "email": email, "profileImageUrl": profileImageUrl]
                userReference.updateChildValues(values) { (error, ref) in
                    if error != nil{
                        print("something went wrong")
                        return
                    }
                    completion(true)
                }
                
            }
        }
    }

    
    func uploadImage(image: UIImage, Compeltion: @escaping (String) -> Void) {
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return}
        print("image uploading")
        
        let storageRef = Storage.storage().reference(withPath: "profileImage/\(UUID().uuidString)")
        
        storageRef.putData(imageData, metadata: nil) { metaData, error in
            
            if error != nil {
                print("Fail to uplode file \(String(describing: error?.localizedDescription))")
            }
            
            storageRef.downloadURL { url, error in
                guard let imageUrl = url?.absoluteString else { return}
                Compeltion(imageUrl)
            }
        }
    }
}
