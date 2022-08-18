//
//  Users.swift
//  MyChat
//
//  Created by Zaur on 18.08.2022.
//

import Foundation

 class User: NSObject {
     let email: String?
     let name: String?

     init(dictionary: [String: AnyObject]) {
         self.name = dictionary["name"] as? String
         self.email = dictionary["email"] as? String
     }
 }


// error
