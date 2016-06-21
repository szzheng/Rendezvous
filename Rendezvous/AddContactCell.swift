//
//  AddContactCell.swift
//  Rendezvous
//
//  Created by Steven Zheng on 4/23/16.
//  Copyright © 2016 szzheng. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class AddContactCell: UITableViewCell {

    @IBOutlet var addButton: UIButton!
    
    @IBOutlet var name: UILabel!
    @IBOutlet var profilePicture: ProfilePicture!
    var profilePictureString: String!
    var email: String!
    
    let ref = FIRDatabase.database().reference()
    let usersRef = FIRDatabase.database().referenceFromURL("https://rendezvous-app.firebaseio.com/users")
    let contactsRef = FIRDatabase.database().referenceFromURL("https://rendezvous-app.firebaseio.com/contacts")
    
    
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
        print("Adding Contact")
        
        let adjustedEmail = escapeEmailAddress(email)
        
        let authData = FIRAuth.auth()?.currentUser
        
        // get contact email
        let addedContact = ["email": email, "name": name.text!, "profile picture": profilePictureString]
        
        // Create a child path with a key set to the uid underneath the "users" node
        // This creates a URL path like the following:
        //  - https://<YOUR-FIREBASE-APP>.firebaseio.com/users/<uid>
        
        // get your email
        let yourEmail = authData?.email
        let adjustedYourEmail = escapeEmailAddress(yourEmail!)
        let yourRef = FIRDatabase.database().referenceFromURL("https://rendezvous-app.firebaseio.com/contacts/")
        
        yourRef.child(adjustedYourEmail).child(adjustedEmail).updateChildValues(addedContact)
        
        
        //let addedContactRef = yourRef.childByAutoId()
        //addedContactRef.setValue(addedContact)
        
        
        //yourRef.childByAppendingPath("contacts").updateChildValues(addedContact)
        
        
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
