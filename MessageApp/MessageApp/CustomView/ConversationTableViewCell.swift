//
//  MessageTableViewCell.swift
//  MessageApp
//
//  Created by Huynh Huy on 11/12/18.
//  Copyright © 2018 Huynh Huy. All rights reserved.
//

import UIKit

class ConversationTableViewCell: UITableViewCell {

    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbMessageDate: UILabel!
    @IBOutlet weak var lbMessageContent: UILabel!
    @IBOutlet weak var imgViewAvatar: UIImageView!
    @IBOutlet weak var viewDot: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        self.viewDot.layer.cornerRadius = 5.0
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
