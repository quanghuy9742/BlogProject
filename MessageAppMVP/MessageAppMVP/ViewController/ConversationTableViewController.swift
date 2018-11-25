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
import MessageUI

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
            self.arrDeleteConversation.removeAll()
            self.barBtnReadAll.isEnabled = true
            self.barBtnDelete.isEnabled = false
            self.tableView.reloadData()
        }
    }
    var arrDeleteConversation = [Conversation]()
    var arrConversation = [Conversation]()
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var messagePresenter: MessagePresenter!
    var conversationPresenter: ConversationPresenter!
    
    // MARK: - Function
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup MVP
        self.messagePresenter = MessagePresenter(messageService: MessageService())
        self.conversationPresenter = ConversationPresenter(conversationService: ConversationService())
        self.conversationPresenter.attachView(conversationView: self)
        
        // Load UI
        setupUI()
        
        // Load JSON data
        self.conversationPresenter.addConversation(json: "celebrity_message")
    }
    
    func setupUI() {
        // Setup UI
        self.barBtnDelete.isEnabled = false
        self.navigationController?.isToolbarHidden = true
        self.tableView.register(UINib(nibName: "ConversationTableViewCell", bundle: nil), forCellReuseIdentifier: "ConversationCell")
        
        // Search bar
        self.searchController.searchResultsUpdater = self
        self.searchController.obscuresBackgroundDuringPresentation = false
        self.definesPresentationContext = true
        
        // Navigation title
        if #available(iOS 11.0, *) {
            self.navigationItem.searchController = self.searchController
            self.navigationController?.navigationBar.prefersLargeTitles = true
        } else {
            self.tableView.tableHeaderView = self.searchController.searchBar
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrConversation.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConversationCell", for: indexPath) as! ConversationTableViewCell
        
        // Conversation information
        let conversation = arrConversation[indexPath.row]
        let lastMessage = self.messagePresenter.getSortedMessageByDate(from: conversation).last
        
        // Update UI
        cell.lbName.text = conversation.name ?? ""
        cell.lbMessageDate.text = lastMessage != nil ? Helper.getDescription(of: lastMessage!.date!) : ""
        cell.lbMessageContent.text = lastMessage?.content
        cell.isCheck = self.arrDeleteConversation.contains(self.arrConversation[indexPath.row])
        
        if let name = conversation.name {
            cell.imgViewAvatar.image = UIImage(named: name)
            cell.imgViewAvatar.layer.masksToBounds = true
            cell.imgViewAvatar.layer.cornerRadius = 25
        }
        
        if self.isEdit {
            cell.viewDot.isHidden = true
            cell.imgCheck.isHidden = false
            
            // Selected color
            let bgColorView = UIView()
            bgColorView.backgroundColor = UIColor(hexString: "#007AFF").withAlphaComponent(0.1)
            cell.selectedBackgroundView = bgColorView
        } else {
            cell.viewDot.isHidden = conversation.isRead
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
            let conversation = self.arrConversation[indexPath.row]
            if let index = self.arrDeleteConversation.index(of: conversation) {
                self.arrDeleteConversation.remove(at: index)
                if self.arrDeleteConversation.isEmpty {
                    self.barBtnReadAll.isEnabled = true
                    self.barBtnDelete.isEnabled = false
                }
            } else {
                if self.arrDeleteConversation.isEmpty {
                    self.barBtnReadAll.isEnabled = false
                    self.barBtnDelete.isEnabled = true
                }
                self.arrDeleteConversation.append(conversation)
            }
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
            
        } else {
            
            // Go to Message Table VC
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let messageVC = storyboard.instantiateViewController(withIdentifier: "MessageTableViewController") as? MessageTableViewController {
                let conversation = self.arrConversation[indexPath.row]
                messageVC.arrMessage = self.messagePresenter.getSortedMessageByDate(from: conversation)
                self.navigationController?.pushViewController(messageVC, animated: true)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete UI
            self.arrConversation = self.conversationPresenter.deleteConversation(conversation: self.arrConversation[indexPath.row])
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    // MARK: - Action
    
    @IBAction func editAction(_ sender: UIBarButtonItem) {
        self.isEdit = !self.isEdit
    }
    
    @IBAction func composeAction(_ sender: UIBarButtonItem) {
        if MFMessageComposeViewController.canSendText() {
            // Message Compose component
            let messageComposeVC = MFMessageComposeViewController()
            messageComposeVC.messageComposeDelegate = self
            self.present(messageComposeVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func readAllAction(_ sender: UIBarButtonItem) {
        self.conversationPresenter.readAll()
        self.isEdit = false
    }
    
    @IBAction func deleteAction(_ sender: UIBarButtonItem) {
        self.conversationPresenter.deleteConversation(arrConversation: self.arrDeleteConversation)
        self.isEdit = false
    }
}

// MARK: - Search result delegate
extension ConversationTableViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        if let text = searchController.searchBar.text {
            self.search(text: text)
        }
    }
    
    func search(text: String, scope: String = "All") {
        self.conversationPresenter.search(text: text)
    }
    
}

// MARK: - Message Compose ViewController
extension ConversationTableViewController: MFMessageComposeViewControllerDelegate {
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension ConversationTableViewController: ConversationView {
    
    func showConversations(arrConversation: [Conversation]) {
        self.arrConversation = arrConversation
        self.tableView.reloadData()
    }
    
}
