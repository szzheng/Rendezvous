//
//  IncomingCell.swift
//  Rendezvous
//
//  Created by Steven Zheng on 5/18/16.
//  Copyright © 2016 szzheng. All rights reserved.
//

import UIKit

class RequestCell: UITableViewCell {

    @IBOutlet var profilePicture: ProfilePicture!
    @IBOutlet var header: UILabel!
    @IBOutlet var date: UILabel!
    
    var type: Int!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}



