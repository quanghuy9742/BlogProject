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

class MessageTableViewController: UITableViewController {
    
    // MARK: - Control
    
    
    // MARK: - Property
    var arrConverstation = [Conversation]()
    let coreDataStack: CoreDataStack = {
        return (UIApplication.shared.delegate as! AppDelegate).coreDataStack
    }()
    
    // MARK: - Function
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "MessageTableViewCell", bundle: nil), forCellReuseIdentifier: "messageTableViewCell")
        
        do {
            let fetchRequest: NSFetchRequest<Conversation> = NSFetchRequest<Conversation>(entityName: "Conversation")
            let sortDescriptor = NSSortDescriptor(key: #keyPath(Conversation.name), ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptor]
            
            self.arrConverstation = try self.coreDataStack.context.fetch(fetchRequest)
//            self.tableView.reloadData()
            
            let messages: [Message] = self.arrConverstation[0].messages?.allObjects as! [Message]
            print("Message: \(messages.map {$0.content})")
            
        } catch let error {
            print("Error = \(error)")
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrConverstation.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "messageTableViewCell", for: indexPath) as! MessageTableViewCell
        
        let conversation = arrConverstation[indexPath.row]
        cell.lbName.text = conversation.name ?? ""
        cell.lbMessageDate.text = "date"
        cell.lbMessageContent.text = "content"
        if let name = conversation.name {
            cell.imgViewAvatar.image = UIImage(named: name)
            cell.imgViewAvatar.layer.masksToBounds = true
            cell.imgViewAvatar.layer.cornerRadius = 25
        }
        cell.imgViewDot.image = conversation.isRead ? UIImage(named: "dot") : nil
    
        return cell
    }
}
