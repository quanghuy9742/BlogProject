//
//  AppDelegate.swift
//  MessageApp
//
//  Created by Huynh Huy on 11/12/18.
//  Copyright © 2018 Huynh Huy. All rights reserved.
//

import UIKit
import Foundation
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        if loadMessageData(json: "celebrity_message") {
            print("Success")
        } else {
            print("Failed")
        }
        
        return true
    }
    
    func loadMessageData(json: String) -> Bool {
        // Check exist
        if !SQLiteStack.shared.isExist(table: "Conversation") {
            
            // Create table
            let _ = SQLiteStack.shared.createTable(query: SQLiteQuery.create_table_conversation)
            let _ = SQLiteStack.shared.createTable(query: SQLiteQuery.create_table_message)
        }
        
        // Remove all data if need
        if let count = SQLiteStack.shared.readConversations()?.count, count > 0 {return false}
        
        if let jsonURL = Bundle.main.url(forResource: json, withExtension: ".json") {
            do {
                // Parse file to json data
                let jsonData = try Data(contentsOf: jsonURL)
                guard let arrDictionary = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as? [[String: Any]] else {return false}
                arrDictionary.forEach { (dictionary) in

                    // Create model conversation
                    let isRead = dictionary["isRead"] as! Bool
                    let name = dictionary["name"] as! String
                    let imagePath = dictionary["name"] as! String
                    let phone = dictionary["phone"] as! String
                    
                    let conversation = Conversation(id: 0, name: name, phone: phone, isRead: isRead == true ? 1 : 0, imagePath: imagePath)
                    
                    // Get message receive
                    let arrMessageReceiveDic = dictionary["messageReceive"] as! [[String: Any]]
                    conversation.arrMessage.append(contentsOf: self.getMessage(from: arrMessageReceiveDic, isReceive: true))
                    
                    // Get message reply
                    let arrMessageReplyDic = dictionary["messageReply"] as! [[String: Any]]
                    conversation.arrMessage.append(contentsOf: self.getMessage(from: arrMessageReplyDic))
                    
                    // Insert CONVERSATION ROW
                    guard let lastConversationId = SQLiteStack.shared.insertConversation(conversation: conversation) else {return}
        
                    conversation.arrMessage.forEach({ (message) in
                        message.conversationId = lastConversationId
                        print("Content: \(message.content)")
                        if let lastId = SQLiteStack.shared.insertMessage(message: message) {
                            print("Content last id: \(lastId)")
                        }
                    })
                }
                
            } catch let error {
                print("Error = \(error)")
                return false
            }
        }
        return true
    }
    
    // Get message from array dictionary
    func getMessage(from arrDic: [[String: Any]], isReceive: Bool = false) -> [Message] {
        var arrMessage = [Message]()
        arrDic.forEach { (dic) in
            // Date
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'hh:mm:ss Z"
            let date = dateFormatter.date(from: dic["date"] as! String) as Date?
            
            // Content
            let content = dic["content"] as! String
            
            // Message
            let message = Message(conversationId: 0, content: content, date: date!, isReceive: isReceive)
            arrMessage.append(message)
        }
        return arrMessage
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

