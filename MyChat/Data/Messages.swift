//
//  Message.swift
//  MyChat
//
//  Created by Zaur on 26.08.2022.
//

import Foundation
import FirebaseAuth

struct Messages: Codable {
    let fromUserID: String?
    let text: String?
    let timeStamp: Double?
    let toUserID: String?
    let imageURL: String?
    let imageWidth: Float?
    let imageHeight: Float?
    
    func chatPartner() -> String? {
        return fromUserID == Auth.auth().currentUser?.uid ? toUserID : fromUserID
    }
}
