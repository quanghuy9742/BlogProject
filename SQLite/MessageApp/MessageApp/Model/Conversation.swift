//
//  Conversation.swift
//  MessageApp
//
//  Created by ivc on 28/11/18.
//  Copyright © 2018 Huynh Huy. All rights reserved.
//

import UIKit

class Conversation: NSObject {

    let id: Int32?
    let imagePath: String?
    let isRead: Int32!
    let name: String!
    let phone: String!
    var arrMessage: [Message]!
    
    init(id: Int32, name: String, phone: String, isRead: Int32, imagePath: String? = nil, arrMessage: [Message] = [Message]()) {
        self.id = id
        self.name = name
        self.phone = phone
        self.isRead = isRead
        self.imagePath = imagePath
        self.arrMessage = arrMessage
    }
}
