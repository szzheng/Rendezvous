//
//  IncomingRequest.swift
//  Rendezvous
//
//  Created by Steven Zheng on 5/18/16.
//  Copyright © 2016 szzheng. All rights reserved.
//

import Foundation
import UIKit

struct Request {
    var type: Int! // 0 - incoming, 1 - outgoing, 2 - locked
    var comment: String!
    var date: String!
    var time: String!
    var from: String!
    var to: String!
    init(comment: String, date: String, time: String, from: String, type: Int, to: String) {
        self.comment = comment
        self.date = date
        self.time = time
        self.from = from
        self.type = type
        self.to = to
    }
}