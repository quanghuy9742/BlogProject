//
//  MessageTableViewCell.swift
//  MessageApp
//
//  Created by Huynh Huy on 11/17/18.
//  Copyright © 2018 Huynh Huy. All rights reserved.
//

import UIKit

class MessageTableViewCell: UITableViewCell {

    @IBOutlet weak var lbContent: UILabel!
    @IBOutlet weak var viewBackground: UIView!
    @IBOutlet weak var leftConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightConstraint: NSLayoutConstraint!
    @IBOutlet weak var lbDateTime: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.viewBackground.layer.cornerRadius = 20.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
