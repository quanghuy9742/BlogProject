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
    @IBOutlet weak var imgCheck: UIImageView!
    @IBOutlet weak var widthConstraintViewDot: NSLayoutConstraint!
    
    var isCheck: Bool = false {
        didSet {
            if isCheck {
                self.imgCheck.image = UIImage(named: "check")
            } else {
                self.imgCheck.image = UIImage(named: "uncheck")
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.viewDot.layer.cornerRadius = 5.0
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        let color = viewDot.backgroundColor
        super.setSelected(selected, animated: animated)
        
        if selected {
            self.viewDot.backgroundColor = color
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        let color = viewDot.backgroundColor
        super.setHighlighted(highlighted, animated: animated)
        
        if highlighted {
            self.viewDot.backgroundColor = color
        }
    }
    
}
