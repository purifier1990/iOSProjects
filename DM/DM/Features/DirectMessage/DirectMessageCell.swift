//
//  DirectMessageCell.swift
//  DM
//
//  Created by wenyu zhao on 2020/2/2.
//  Copyright © 2020 Ryan zhao. All rights reserved.
//

import UIKit

class DirectMessageCell: UITableViewCell {
    // MARK: - Outlet
    @IBOutlet var bubbleBackgroundImage: UIImageView!
    @IBOutlet var message: UILabel!
    
    @IBOutlet var outComingTrailingConstrianst: NSLayoutConstraint!
    @IBOutlet var outComingLeadingConstraint: NSLayoutConstraint!
    @IBOutlet var incomingLeadingConstraint: NSLayoutConstraint!
    @IBOutlet var incomingTrailingConstraint: NSLayoutConstraint!
    
    // MARK: - Member function
    func configure(_ message: Message) {
        if message.isIncoming {
            bubbleBackgroundImage.image = #imageLiteral(resourceName: "left_bubble")
        } else {
            bubbleBackgroundImage.image = #imageLiteral(resourceName: "right_bubble")
        }
        self.message.text = message.text
        adaptConstraint(message.isIncoming)
    }
    
    // MARK: - Private fucntion
    fileprivate func adaptConstraint(_ isIncoming: Bool) {
        if isIncoming {
            NSLayoutConstraint.deactivate([outComingTrailingConstrianst,
                                           outComingLeadingConstraint])
            NSLayoutConstraint.activate([incomingLeadingConstraint,
                                         incomingTrailingConstraint])
        } else {
            NSLayoutConstraint.deactivate([incomingLeadingConstraint,
                                           incomingTrailingConstraint])
            NSLayoutConstraint.activate([outComingTrailingConstrianst,
                                         outComingLeadingConstraint])
        }
        updateConstraintsIfNeeded()
    }
}
