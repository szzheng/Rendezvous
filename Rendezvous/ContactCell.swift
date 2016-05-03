//
//  ContactCell.swift
//  Rendezvous
//
//  Created by Steven Zheng on 4/30/16.
//  Copyright © 2016 szzheng. All rights reserved.
//

import UIKit

class ContactCell: UITableViewCell {

    @IBOutlet var profilePicture: ProfilePicture!
    @IBOutlet var name: UILabel!
    
    var email: String!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
