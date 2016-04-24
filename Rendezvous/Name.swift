//
//  Name.swift
//  Rendezvous
//
//  Created by Steven Zheng on 4/23/16.
//  Copyright © 2016 szzheng. All rights reserved.
//

import UIKit

class Name: UILabel {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    override func layoutSubviews() {
        
        self.font = UIFont(name: "SF UI Text Regular", size: 17)
        
    }

}
