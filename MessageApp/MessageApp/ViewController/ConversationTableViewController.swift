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

    // MARK: - Control
    @IBOutlet weak var barBtnEdit: UIBarButtonItem!
    @IBOutlet weak var barBtnReadAll: UIBarButtonItem!
    @IBOutlet weak var barBtnDelete: UIBarButtonItem!
    
    // MARK: - Property
    var isEdit: Bool = false {
        didSet{
            if isEdit {
                self.barBtnEdit.title = "Done"
                self.navigationController?.setToolbarHidden(false, animated: true)
            } else {
                self.barBtnEdit.title = "Edit"
                self.navigationController?.setToolbarHidden(true, animated: true)
            }
            self.tableView.reloadData()
        }
    }
    var arrDeleteConversation = [Conversation]()
    var arrConverstation = [Conversation]()
    let coreDataStack: CoreDataStack = {
        return (UIApplication.shared.delegate as! AppDelegate).coreDataStack
    }()
    
    // MARK: - Action
    
    @IBAction func editAction(_ sender: UIBarButtonItem) {
        self.isEdit = !self.isEdit
    }
    
    @IBAction func composeAction(_ sender: UIBarButtonItem) {
        
    }
    
    @IBAction func readAllAction(_ sender: UIBarButtonItem) {
        self.arrConverstation.forEach { (conversation) in
            conversation.isRead = false
        }
        self.coreDataStack.saveContext()
        self.isEdit = false
    }
    
    @IBAction func deleteAction(_ sender: UIBarButtonItem) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Conversation")
//        fetchRequest.returnsObjectsAsFaults = true
        fetchRequest.predicate = NSPredicate(format: "self IN %@", self.arrDeleteConversation)
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try self.coreDataStack.context.execute(batchDeleteRequest)
            self.coreDataStack.saveContext()
            self.isEdit = false
        } catch let error {
            print("Error = \(error)")
        }
    }
    
    // MARK: - Function
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup UI
        self.barBtnDelete.isEnabled = false
        self.navigationController?.isToolbarHidden = true
        tableView.register(UINib(nibName: "ConversationTableViewCell", bundle: nil), forCellReuseIdentifier: "ConversationCell")
        
        // Fetch request
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
        
        // Conversation information
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
        if self.isEdit {
            cell.viewDot.isHidden = true
            cell.imgCheck.isHidden = false
            cell.imgCheck.image = UIImage(named: "uncheck")
            
            // Selected color
            let bgColorView = UIView()
            bgColorView.backgroundColor = UIColor(hexString: "#007AFF").withAlphaComponent(0.1)
            cell.selectedBackgroundView = bgColorView
            
        } else {
            cell.viewDot.isHidden = false
            cell.viewDot.backgroundColor = conversation.isRead ? UIColor.blue.withAlphaComponent(0.8) : nil
            cell.imgCheck.isHidden = true
            cell.widthConstraintViewDot.constant = 10
            
            // Selected color
            let bgColorView = UIView()
            bgColorView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
            cell.selectedBackgroundView = bgColorView
        }
    
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.isEdit {
            let cell = tableView.cellForRow(at: indexPath) as! ConversationTableViewCell
            cell.isCheck = !cell.isCheck
            let conversation = self.arrConverstation[indexPath.row]
            
            if cell.isCheck {
                if self.arrDeleteConversation.isEmpty {
                    self.barBtnReadAll.isEnabled = false
                    self.barBtnDelete.isEnabled = true
                }
                self.arrDeleteConversation.append(conversation)
                
            } else {
                if let index = self.arrDeleteConversation.index(of: conversation) {
                    self.arrDeleteConversation.remove(at: index)
                    
                    if self.arrDeleteConversation.isEmpty {
                        self.barBtnReadAll.isEnabled = true
                        self.barBtnDelete.isEnabled = false
                    }
                }
            }
            
        } else {
            let conversation = self.arrConverstation[indexPath.row]
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let messageVC = storyboard.instantiateViewController(withIdentifier: "MessageTableViewController") as? MessageTableViewController {
                messageVC.arrMessage = self.getSortedMessageByDate(from: conversation)
                self.navigationController?.pushViewController(messageVC, animated: true)
            }
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
