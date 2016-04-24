//
//  ProfilePicture.swift
//  Rendezvous
//
//  Created by Steven Zheng on 4/23/16.
//  Copyright © 2016 szzheng. All rights reserved.
//

import UIKit

class ProfilePicture: UIImageView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    
    var initials: UILabel!
    
    
    override func layoutSubviews() {
        // Make profile picture circular
        layer.cornerRadius = layer.frame.size.width/2
        layer.borderColor = UIColor.darkGrayColor().CGColor
        layer.borderWidth = 0.25
        clipsToBounds = true
        
        // Create label incase there is no picture
        initials = UILabel(frame: self.frame)
        initials.textAlignment = NSTextAlignment.Center
        initials.font = UIFont(name: "SF UI Display Light", size: 65)
        initials.hidden = true
    }

}
