//
//  MessageTableViewCell.swift
//  MessageApp
//
//  Created by Huynh Huy on 11/12/18.
//  Copyright © 2018 Huynh Huy. All rights reserved.
//

import UIKit

class MessageTableViewCell: UITableViewCell {

    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbMessageDate: UILabel!
    @IBOutlet weak var lbMessageContent: UILabel!
    @IBOutlet weak var imgViewAvatar: UIImageView!
    @IBOutlet weak var imgViewDot: UIImageView!
    
    var conversation: Conversation!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.lbName.text = self.conversation.name ?? ""
        self.lbMessageDate.text = "date"
        self.lbMessageContent.text = "content"
        if let name = self.conversation.name {
            self.imgViewAvatar.image =  UIImage(named: name)
        }
        self.imgViewDot.image = self.conversation.isRead ? UIImage(named: "dot") : nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
