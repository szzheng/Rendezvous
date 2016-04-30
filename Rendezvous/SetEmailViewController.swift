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
    var activityIndicator = UIActivityIndicatorView()
    var firstTime: Bool!
    
    @IBOutlet var errorMessage: UILabel!
    @IBOutlet var emailAddress: UITextField!
    @IBOutlet var continueButton: UIButton!
    
    // Get a reference to registered emails
    let ref = Firebase(url:"https://rendezvous-app.firebaseio.com/user-emails")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        emailAddress.becomeFirstResponder()
        
        disableContinue()
        errorMessage.hidden = true
        firstTime = true
    }
    
    override func viewDidAppear(animated: Bool) {
        if (firstTime != true) {
            errorMessage.hidden = true
            emailAddress.becomeFirstResponder()
            continueButton.userInteractionEnabled = true
            continueButton.alpha = 1
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
    // Submit Email
    @IBAction func `continue`(sender: AnyObject) {
        
        displayActivityIndicator()
        
        // Email already taken
        ref.queryOrderedByChild("email").queryEqualToValue(emailAddress.text!).observeEventType(.Value, withBlock: { snapshot in
            
            self.activityIndicator.stopAnimating()
            UIApplication.sharedApplication().endIgnoringInteractionEvents()
            
            if !(snapshot.value is NSNull) {
                self.continueButton.alpha = 0.25
                self.continueButton.userInteractionEnabled = false
                
                self.errorMessage.hidden = false
                self.errorMessage.text = "Email already registered"
                self.disableContinue()
                
            } else if (!self.isValidEmail(self.emailAddress.text!)) {
                self.errorMessage.hidden = false
                self.errorMessage.text = "Please enter a valid email"
                self.disableContinue()
            } else {
                
                self.errorMessage.hidden = true
                self.performSegueWithIdentifier("SetPasswordSegue", sender: self)
            }

        })
    }
    
    // Checks validity of email format
    func isValidEmail(testStr:String) -> Bool {
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
    
    func displayActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        let setPasswordVC = segue.destinationViewController as! SetPasswordViewController
        setPasswordVC.email = emailAddress.text!
    }
    

}
