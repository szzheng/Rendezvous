//
//  ContactViewController.swift
//  Rendezvous
//
//  Created by Steven Zheng on 5/2/16.
//  Copyright © 2016 szzheng. All rights reserved.
//

import UIKit
import Firebase

class ContactViewController: UIViewController {
    
    // Get a reference to requests
    let ref = Firebase(url:"https://rendezvous-app.firebaseio.com/")
    let outgoingRef = Firebase(url:"https://rendezvous-app.firebaseio.com/outgoing/")
    let incomingRef = Firebase(url:"https://rendezvous-app.firebaseio.com/incoming/")

    
    
    @IBOutlet var contactName: UILabel!
    @IBOutlet var message: UITextField!
    
    var name: String!
    var email: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contactName.text = name!
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func back(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func send(sender: AnyObject) {
        
        let yourEmail = ref.authData.providerData["email"] as! String
        let yourAdjustedEmail = escapeEmailAddress(yourEmail)
        
        let contactAdjustedEmail = escapeEmailAddress(email)
        
        
        // outgoing request
        var request = ["message": message.text!, "to": contactAdjustedEmail]
        outgoingRef.childByAppendingPath(yourAdjustedEmail).childByAutoId().setValue(request)
        
        
        // incoming request
        request = ["message": message.text!, "from": yourAdjustedEmail]
        incomingRef.childByAppendingPath(contactAdjustedEmail).childByAutoId().setValue(request)
        
        //let newVal = ["message": message.text!, "from": yourAdjustedEmail, "to": contactName.text!]
        //newChildRef.setValue(newVal)
        
        /*
        let yourEmail = ref.authData.providerData["email"] as! String
        let yourAdjustedEmail = escapeEmailAddress(yourEmail)*/
        
        
        /*contactsRef.childByAppendingPath(yourAdjustedEmail).childByAppendingPath(adjustedEmail).updateChildValues(addedContact)*/

        
    }
    
    func escapeEmailAddress(email: String) -> String {
        
        // Replace '.' (not allowed in a Firebase key) with ',' (not allowed in an email address)
        var adjustedEmail = email.lowercaseString
        adjustedEmail = email.stringByReplacingOccurrencesOfString(".", withString: ",", options: NSStringCompareOptions.LiteralSearch, range: nil)
        return adjustedEmail
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
