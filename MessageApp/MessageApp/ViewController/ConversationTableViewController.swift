//
//  MessageTableViewController.swift
//  MessageApp
//
//  Created by Huynh Huy on 11/12/18.
//  Copyright © 2018 Huynh Huy. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class ConversationTableViewController: UITableViewController {

    // MARK: - Property
    var arrConverstation = [Conversation]()
    let coreDataStack: CoreDataStack = {
        return (UIApplication.shared.delegate as! AppDelegate).coreDataStack
    }()
    
    // MARK: - Action
    
    @IBAction func editAction(_ sender: UIBarButtonItem) {
        
    }
    
    @IBAction func composeAction(_ sender: UIBarButtonItem) {
        
    }
    
    // MARK: - Function
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "ConversationTableViewCell", bundle: nil), forCellReuseIdentifier: "ConversationCell")
        
        do {
            let fetchRequest: NSFetchRequest<Conversation> = NSFetchRequest<Conversation>(entityName: "Conversation")
            self.arrConverstation = try self.coreDataStack.context.fetch(fetchRequest)
        
            // Sort conversation
            let sortedArrConversation = arrConverstation.sorted { (firstConversation, secondConverstation) -> Bool in
                
                let sortedFirstMessage = self.getSortedMessageByDate(from: firstConversation)
                let sortedSecondMessage = self.getSortedMessageByDate(from: secondConverstation)

                if let firstLastDate = sortedFirstMessage.last?.date as Date?, let secondLastDate = sortedSecondMessage.last?.date as Date? {
                    return firstLastDate > secondLastDate
                }
                return false
            }
            self.arrConverstation = sortedArrConversation
            self.coreDataStack.saveContext()
            
        } catch let error {
            print("Error = \(error)")
        }
    }
    
    func getSortedMessageByDate(from conversation: Conversation) -> [Message] {
        let arrMessage = conversation.messages?.allObjects as! [Message]
        return arrMessage.sorted { (firstMessage: Message, secondMessage: Message) -> Bool in
            if let date1 = firstMessage.date as Date?, let date2 = secondMessage.date as Date?, date1 <= date2 {return true}
            return false
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrConverstation.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConversationCell", for: indexPath) as! ConversationTableViewCell
        
        let conversation = arrConverstation[indexPath.row]
        cell.lbName.text = conversation.name ?? ""
        let lastMessage = self.getSortedMessageByDate(from: conversation).last
        cell.lbMessageDate.text = lastMessage != nil ? Helper.getDescription(of: lastMessage!.date!) : ""
        cell.lbMessageContent.text = lastMessage?.content
        if let name = conversation.name {
            cell.imgViewAvatar.image = UIImage(named: name)
            cell.imgViewAvatar.layer.masksToBounds = true
            cell.imgViewAvatar.layer.cornerRadius = 25
        }
        cell.viewDot.backgroundColor = conversation.isRead ? UIColor.blue.withAlphaComponent(0.8) : nil
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let conversation = self.arrConverstation[indexPath.row]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let messageVC = storyboard.instantiateViewController(withIdentifier: "MessageTableViewController") as? MessageTableViewController {
            messageVC.arrMessage = self.getSortedMessageByDate(from: conversation)
            self.navigationController?.pushViewController(messageVC, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete core data
            self.coreDataStack.context.delete(self.arrConverstation[indexPath.row])
            
            // Delete UI
            self.arrConverstation.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            
            // save
            self.coreDataStack.saveContext()
        }
    }
}
