//
//  SetEmailViewController.swift
//  Rendezvous
//
//  Created by Steven Zheng on 4/18/16.
//  Copyright © 2016 szzheng. All rights reserved.
//


import UIKit
import Firebase

class SetEmailViewController: UIViewController {

    @IBOutlet var errorMessage: UILabel!
    @IBOutlet var emailAddress: UITextField!
    @IBOutlet var continueButton: UIButton!
    
    // Get a reference to registered emails
    let ref = Firebase(url:"https://resplendent-torch-7790.firebaseio.com/user-emails")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        emailAddress.becomeFirstResponder()
        
        disableContinue()
        errorMessage.hidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // Submit Email
    @IBAction func `continue`(sender: AnyObject) {
        
        var error: Bool!
        
        // Email already taken
        ref.queryOrderedByChild("email").queryEqualToValue(emailAddress.text!).observeEventType(.ChildAdded, withBlock: { snapshot in
            if (snapshot.exists()) {
                self.continueButton.alpha = 0.25
                self.continueButton.userInteractionEnabled = false
                
                self.errorMessage.hidden = false
                self.errorMessage.text = "Email already registered"
                self.disableContinue()
                
                error = true
            }
        })
        
        // Email is of invalid format
        if (!isValidEmail(emailAddress.text!)) {
            self.errorMessage.hidden = false
            self.errorMessage.text = "Please enter a valid email"
            disableContinue()
            error = true
        }
        
        if (error != true) {
            performSegueWithIdentifier("SetPasswordSegue", sender: self)
        }
    }
    
    // Checks validity of email format
    func isValidEmail(testStr:String) -> Bool {
        // println("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }
    
    // Disables user from submitting email
    func disableContinue() -> Void {
        self.continueButton.alpha = 0.25
        self.continueButton.userInteractionEnabled = false
    }

    
    // Updates display when user edits email
    @IBAction func editEmail(sender: AnyObject) {
        
        if (emailAddress.text! != "") {
            self.continueButton.alpha = 1
            self.continueButton.userInteractionEnabled = true
        } else {
            disableContinue()
        }
        errorMessage.hidden = true
    }
    
    // Retreat to launch screen
    @IBAction func back(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
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
