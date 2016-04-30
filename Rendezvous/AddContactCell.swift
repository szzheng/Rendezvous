//
//  AddContactCell.swift
//  Rendezvous
//
//  Created by Steven Zheng on 4/23/16.
//  Copyright © 2016 szzheng. All rights reserved.
//

import UIKit
import Firebase

class AddContactCell: UITableViewCell {

    @IBOutlet var addButton: UIButton!
    
    @IBOutlet var name: UILabel!
    @IBOutlet var profilePicture: ProfilePicture!
    var email: String!
    
    let ref = Firebase(url:"https://rendezvous-app.firebaseio.com/")
    let usersRef = Firebase(url:"https://rendezvous-app.firebaseio.com/users")
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        //profilePicture.layer.borderColor = UIColor.whiteColor().CGColor
        
        //addButton.layer.cornerRadius = layer.frame.size.width/2
        //addButton.layer.borderWidth = 0.5
        //addButton.layer.borderColor = UIColor.darkGrayColor().CGColor
    }
    
    func escapeEmailAddress(email: String) -> String {
        
        // Replace '.' (not allowed in a Firebase key) with ',' (not allowed in an email address)
        var adjustedEmail = email.lowercaseString
        adjustedEmail = email.stringByReplacingOccurrencesOfString(".", withString: ",", options: NSStringCompareOptions.LiteralSearch, range: nil)
        return adjustedEmail
    }

    @IBAction func addContact(sender: AnyObject) {
        //print("Adding Contact")
        
        let adjustedEmail = escapeEmailAddress(email)
        
        let authData = ref.authData
        
        // get contact email
        let addedContact = ["emailID": adjustedEmail]
        
        // Create a child path with a key set to the uid underneath the "users" node
        // This creates a URL path like the following:
        //  - https://<YOUR-FIREBASE-APP>.firebaseio.com/users/<uid>
        
        // get your email
        let yourEmail = authData.providerData["email"] as! String
        let adjustedYourEmail = escapeEmailAddress(yourEmail)
        let yourRef = Firebase(url:"https://rendezvous-app.firebaseio.com/users/" + adjustedYourEmail + "/contacts/")
        
        let addedContactRef = yourRef.childByAutoId()
        addedContactRef.setValue(addedContact)
        
        
        //yourRef.childByAppendingPath("contacts").updateChildValues(addedContact)
        
        
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
