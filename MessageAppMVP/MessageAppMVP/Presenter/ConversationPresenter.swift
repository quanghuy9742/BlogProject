//
//  ConversationPresenter.swift
//  MessageAppMVP
//
//  Created by Huynh Huy on 11/24/18.
//  Copyright © 2018 Huynh Huy. All rights reserved.
//

import UIKit
import Foundation
import CoreData

class ConversationPresenter: NSObject {
    
    fileprivate let conversationService: ConversationService!
    weak private var conversationView: ConversationView!
    
    fileprivate var messagePresenter = MessagePresenter(messageService: MessageService())
    
    init(conversationService: ConversationService) {
        self.conversationService = conversationService
    }
    
    func attachView(conversationView: ConversationView) {
        self.conversationView = conversationView
    }
    
    func detachView() {
        self.conversationView = nil
    }
    
    func getSortConversationByDate() -> [Conversation] {
        // Fetch all
        let arrConverstation = self.conversationService.getAllConversation()
        
        // Sort conversation
        let sortedArrConversation = arrConverstation.sorted { (firstConversation, secondConverstation) -> Bool in
            let sortedFirstMessage = self.messagePresenter.getSortedMessageByDate(from: firstConversation)
            let sortedSecondMessage = self.messagePresenter.getSortedMessageByDate(from: secondConverstation)
            
            if let firstLastDate = sortedFirstMessage.last?.date as Date?, let secondLastDate = sortedSecondMessage.last?.date as Date? {
                return firstLastDate > secondLastDate
            }
            return false
        }
        return sortedArrConversation
    }
    
    func deleteConversation(conversation: Conversation) -> [Conversation] {
        let _ = self.conversationService.deleteConversations(arrConversation: [conversation])
        return self.getSortConversationByDate()
    }
    
    func deleteConversation(arrConversation: [Conversation]) {
        let _ = self.conversationService.deleteConversations(arrConversation: arrConversation)
        let results = self.getSortConversationByDate()
        
        // Reload UI
        self.conversationView.showConversations(arrConversation: results)
    }
    
    func addConversation(json: String) {
        // Return if already have data
        let arrConversation = self.conversationService.getAllConversation()
        if arrConversation.isEmpty {
            guard let jsonURL = Bundle.main.url(forResource: json, withExtension: ".json") else {
                return
            }
            
            do {
                // Parse file to json data
                let jsonData = try Data(contentsOf: jsonURL)
                guard let arrDictionary = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as? [[String: Any]] else {return}
                arrDictionary.forEach { (dictionary) in
                    
                    // Create managed object
                    let conversation = Conversation(context: CoreDataStack.shared.context)
                    conversation.isRead = dictionary["isRead"] as! Bool
                    conversation.name = dictionary["name"] as? String
                    if let name = conversation.name, let image = UIImage(named: name) {
                        conversation.imageData = image.pngData()! as NSData
                    }
                    conversation.phone = dictionary["phone"] as? String
                    
                    // Get message receive
                    let arrMessageReceiveDic = dictionary["messageReceive"] as! [[String: Any]]
                    conversation.addToMessages(NSSet(array: self.messagePresenter.getMessages(from: arrMessageReceiveDic, isReceive: true)))
                    
                    // Get message reply
                    let arrMessageReplyDic = dictionary["messageReply"] as! [[String: Any]]
                    conversation.addToMessages(NSSet(array: self.messagePresenter.getMessages(from: arrMessageReplyDic)))
                }
            } catch let error {
                print("Error = \(error)")
            }
        }
        
        // Reload UI
        let results = self.getSortConversationByDate()
        self.conversationView.showConversations(arrConversation: results)
    }
    
    func readAll() {
        let _ = self.conversationService.updateIsRead(value: true)
        let results = self.getSortConversationByDate()
        
        // Reload UI
        self.conversationView.showConversations(arrConversation: results)
    }
    
    func search(text: String) {
        var results: [Conversation]!
        if text.isEmpty {
            results = self.getSortConversationByDate()
        } else {
            results = self.conversationService.search(text: text)
        }
        
        // Reload UI
        self.conversationView.showConversations(arrConversation: results)
    }
}
