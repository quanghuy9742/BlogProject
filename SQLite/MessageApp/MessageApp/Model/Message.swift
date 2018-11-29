//
//  Message.swift
//  MessageApp
//
//  Created by ivc on 28/11/18.
//  Copyright © 2018 Huynh Huy. All rights reserved.
//

import UIKit

class Message: NSObject {
    
    var conversationId: Int!
    let content: String!
    let date: Date!
    let isReceive: Bool!
    
    init(conversationId: Int, content: String, date: Date, isReceive: Bool) {
        self.conversationId = conversationId
        self.content = content
        self.date = date
        self.isReceive = isReceive
    }
}
