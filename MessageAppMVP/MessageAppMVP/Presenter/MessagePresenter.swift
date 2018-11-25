//
//  MessagePresenter.swift
//  MessageAppMVP
//
//  Created by Huynh Huy on 11/24/18.
//  Copyright © 2018 Huynh Huy. All rights reserved.
//

import Foundation
import CoreData

class MessagePresenter: NSObject {
    
    private let messageService: MessageService!
    weak private var messageView: MessageView!
    
    init(messageService: MessageService) {
        self.messageService = messageService
    }
    
    func attachView(messageView: MessageView) {
        self.messageView = messageView
    }
    
    func detachView() {
        self.messageView = nil
    }
    
    func getSortedMessageByDate(from conversation: Conversation) -> [Message] {
        let arrMessage = conversation.messages?.allObjects as! [Message]
        return arrMessage.sorted { (firstMessage: Message, secondMessage: Message) -> Bool in
            if let date1 = firstMessage.date as Date?, let date2 = secondMessage.date as Date?, date1 <= date2 {return true}
            return false
        }
    }

    // Get message from array dictionary
    func getMessages(from arrDic: [[String: Any]], isReceive: Bool = false) -> [Message] {
        guard let messageEntity = NSEntityDescription.entity(forEntityName: MESSAGE_ENTITY, in: CoreDataStack.shared.context) else {
            return [Message]()
        }
        
        var arrMessage = [Message]()
        arrDic.forEach { (dic) in
            let message = Message(entity: messageEntity, insertInto: CoreDataStack.shared.context)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'hh:mm:ss Z"
            message.isReceive = isReceive
            message.date = dateFormatter.date(from: dic["date"] as! String) as NSDate?
            message.content = dic["content"] as? String
            arrMessage.append(message)
        }
        return arrMessage
    }
    
}
