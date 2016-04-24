//
//  AddContactCell.swift
//  Rendezvous
//
//  Created by Steven Zheng on 4/23/16.
//  Copyright © 2016 szzheng. All rights reserved.
//

import UIKit

class AddContactCell: UITableViewCell {

    @IBOutlet var addButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        addButton.layer.borderWidth = 0.5
        addButton.layer.borderColor = UIColor(red: 236, green: 44, blue: 53, alpha: 1).CGColor
    }

    @IBAction func addContact(sender: AnyObject) {
        print("Adding Contact")
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
