//
//  Message.swift
//  MessageApp
//
//  Created by ivc on 28/11/18.
//  Copyright © 2018 Huynh Huy. All rights reserved.
//

import UIKit

class Message: NSObject {
    
    let content: String!
    let date: Date!
    let isReceive: Bool!
    
    init(content: String, date: Date, isReceive: Bool) {
        self.content = content
        self.date = date
        self.isReceive = isReceive
    }
}
