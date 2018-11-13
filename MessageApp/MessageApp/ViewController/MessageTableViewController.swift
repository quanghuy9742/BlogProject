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
    
        do {
            let fetchRequest: NSFetchRequest<Conversation> = NSFetchRequest<Conversation>(entityName: "Conversation")
            self.arrConverstation = try self.coreDataStack.context.fetch(fetchRequest)
            self.tableView.reloadData()
            
        } catch let error {
            print("Error = \(error)")
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageTableViewCell", for: indexPath) as! MessageTableViewCell
        cell.conversation = arrConverstation[indexPath.row]
        return cell
    }
}
