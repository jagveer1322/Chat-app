//
//  User.swift
//  chatApp
//
//  Created by Macbook on 02/09/22.
//

import UIKit

class User: NSObject {
    var id: String?
    var username: String?
    var email: String?
    var profileImageUrl: String?
    
    init(dictionary: [String: AnyObject]){
        self.id = dictionary["id"] as? String
        self.username = dictionary["username"] as? String
        self.email = dictionary["email"] as? String
        self.profileImageUrl = dictionary["profileImageUrl"] as? String
        
        
    }
}
