//
//  Contact.swift
//  Rendezvous
//
//  Created by Steven Zheng on 4/30/16.
//  Copyright © 2016 szzheng. All rights reserved.
//

import Foundation
import UIKit

struct Contact {
    var name: String!
    var profilePicture: String!
    var email: String!
    init(name: String, profilePicture: String, email: String) {
        self.name = name
        self.profilePicture = profilePicture
        self.email = email
    }
}