//
//  MessageTableViewController.swift
//  MessageApp
//
//  Created by Huynh Huy on 11/16/18.
//  Copyright © 2018 Huynh Huy. All rights reserved.
//

import UIKit
import CoreData

class MessageTableViewController: UITableViewController {

    var arrMessage: [Message]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.register(UINib(nibName: "MessageTableViewCell", bundle: nil), forCellReuseIdentifier: "MessageCell")
        self.tableView.separatorStyle = .none
        self.tableView.allowsSelection = false
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrMessage.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = arrMessage[indexPath.row]
        let widthScreen = UIScreen.main.bounds.width
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! MessageTableViewCell
        cell.lbDateTime.text = Helper.getDescription(of: message.date!)
        cell.lbContent.text = message.content
        if message.isReceive {
            cell.viewBackground.backgroundColor = UIColor(hexString: "#E3E3E3")
            cell.lbContent.textColor = UIColor.darkText
            cell.rightConstraint.constant = widthScreen * 1/4
            cell.leftConstraint.constant = 16
        } else {
            cell.viewBackground.backgroundColor = UIColor.blue.withAlphaComponent(0.8)
            cell.lbContent.textColor = UIColor.white
            cell.leftConstraint.constant = widthScreen * 1/4
            cell.rightConstraint.constant = 16
        }
        return cell
    }

}
