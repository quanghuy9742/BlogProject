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
    public lazy var coreDataStack: CoreDataStack = {
        return CoreDataStack(modelName: "MessageModel")
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        if loadMessageData(json: "celebrity_message") {
            print("Success")
        } else {
            print("Failed")
        }
        
        return true
    }
    
    func loadMessageData(json: String) -> Bool {
        // Remove all data if need
        do {
            let fetchRequest: NSFetchRequest<Conversation> = NSFetchRequest<Conversation>(entityName: "Conversation")
            let count = try self.coreDataStack.context.count(for: fetchRequest)
            if count != 0 {
                let arrConversation: [NSManagedObject] = try self.coreDataStack.context.fetch(fetchRequest)
                arrConversation.forEach({self.coreDataStack.context.delete($0)})
                self.coreDataStack.saveContext()
            }
        } catch let error {
            print("Error = \(error)")
        }
        
        if let jsonURL = Bundle.main.url(forResource: json, withExtension: ".json") {
            do {
                // Parse file to json data
                let jsonData = try Data(contentsOf: jsonURL)
                guard let arrDictionary = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as? [[String: Any]] else {return false}
                arrDictionary.forEach { (dictionary) in
                    
                    // Create managed object
                    let conversation = Conversation(context: self.coreDataStack.context)
                    conversation.isRead = dictionary["isRead"] as! Bool
                    conversation.name = dictionary["name"] as? String
                    if let name = conversation.name, let image = UIImage(named: name) {
                        conversation.imageData = image.pngData()
                    }
                    conversation.phone = dictionary["phone"] as! String
                    if let messageEntity = NSEntityDescription.entity(forEntityName: "Message", in: self.coreDataStack.context) {
                        
                        // Get message from array dictionary
                        func getMessage(from arrDic: [[String: Any]]) -> [Message] {
                            var arrMessage = [Message]()
                            arrDic.forEach { (dic) in
                                let message = Message(entity: messageEntity, insertInto: self.coreDataStack.context)
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "yyyy-MM-dd'T'hh:mm:ss Z"
                                message.date = dateFormatter.date(from: dic["date"] as! String)
                                message.content = dic["content"] as! String
                                arrMessage.append(message)
                            }
                            return arrMessage
                        }
                        
                        // Get message receive
                        let arrMessageReceiveDic = dictionary["messageReceive"] as! [[String: Any]]
                        conversation.messageReceive = NSSet(array: getMessage(from: arrMessageReceiveDic))
                        
                        // Get message reply
                        let arrMessageReplyDic = dictionary["messageReply"] as! [[String: Any]]
                        conversation.messageReply = NSSet(array: getMessage(from: arrMessageReplyDic))
                    }
                }
                
            } catch let error {
                print("Error = \(error)")
                return false
            }
        }
        
        // Save
        self.coreDataStack.saveContext()
        return true
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

