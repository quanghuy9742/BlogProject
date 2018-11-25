//
//  MessageView.swift
//  MessageAppMVP
//
//  Created by Huynh Huy on 11/24/18.
//  Copyright © 2018 Huynh Huy. All rights reserved.
//

import Foundation

protocol MessageView: NSObjectProtocol {
    
    func showMessages(of conversation: Conversation)
    
}
