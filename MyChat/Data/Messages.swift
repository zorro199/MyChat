//
//  Message.swift
//  MyChat
//
//  Created by Zaur on 26.08.2022.
//

import Foundation

struct Messages: Codable {
    let fromUserID: String?
    let text: String?
    let timeStamp: Double?
    let toUserID: String?
}
