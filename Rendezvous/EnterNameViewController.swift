//
//  EnterNameViewController.swift
//  Rendezvous
//
//  Created by Steven Zheng on 4/22/16.
//  Copyright © 2016 szzheng. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class EnterNameViewController: UIViewController {

    @IBOutlet var errorMessage: UILabel!
    @IBOutlet var continueButton: UIButton!
    @IBOutlet var firstName: UITextField!
    @IBOutlet var lastName: UITextField!
    
    var firstNameTrimmed: String!
    var lastNameTrimmed: String!
    
    let ref = FIRDatabase.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        errorMessage.hidden = true
        
        let dummyTextField = UITextField()
        dummyTextField.becomeFirstResponder()
        
        disableContinue()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func `continue`(sender: AnyObject) {
        
        // Trim start and end spaces
        trimNames()
        
        
        // Name is not valid
        if (!isValidName(firstNameTrimmed)) {
            self.errorMessage.hidden = false
            self.errorMessage.text = "Invalid Name"
        } else if (!isValidName(lastNameTrimmed)) {
            self.errorMessage.hidden = false
            self.errorMessage.text = "Invalid Name"
            
        // Valid names
        } else {
            
            let authData = FIRAuth.auth()?.currentUser
            let newUser = ["name": firstNameTrimmed + " " + lastNameTrimmed]
            // Create a child path with a key set to the uid underneath the "users" node
            // This creates a URL path like the following:
            //  - https://<YOUR-FIREBASE-APP>.firebaseio.com/users/<uid>
            let email = authData?.email
            let adjustedEmail = escapeEmailAddress(email!)
            performSegueWithIdentifier("SetProfileSegue", sender: self)
            ref.child("users").child(adjustedEmail).updateChildValues(newUser)
            
            
            
            //performSegueWithIdentifier("SetProfileSegue", sender: self)
        }
    }
    
    // Checks validity of email format
    func isValidName(testStr:String) -> Bool {
        
        if testStr.rangeOfString(" ") != nil{
            return false
        }

        return true
    }
    
    @IBAction func editName(sender: AnyObject) {
        
        if (firstName.text! != "" && lastName.text! != "") {
            self.continueButton.alpha = 1
            self.continueButton.userInteractionEnabled = true
        } else {
            disableContinue()
        }
        
    }
    
    func escapeEmailAddress(email: String) -> String {
        
        // Replace '.' (not allowed in a Firebase key) with ',' (not allowed in an email address)
        var adjustedEmail = email.lowercaseString
        adjustedEmail = email.stringByReplacingOccurrencesOfString(".", withString: ",", options: NSStringCompareOptions.LiteralSearch, range: nil)
        return adjustedEmail
    }
    
    // Disables user from submitting email
    func disableContinue() -> Void {
        self.continueButton.alpha = 0.25
        self.continueButton.userInteractionEnabled = false
    }
    
    func trimNames() -> Void {
        // Trim start and end spaces
        firstNameTrimmed = firstName.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        lastNameTrimmed = lastName.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        let setProfileVC = segue.destinationViewController as! SetProfileViewController
        setProfileVC.firstName = firstNameTrimmed
        setProfileVC.lastName = lastNameTrimmed
    }
    

}
