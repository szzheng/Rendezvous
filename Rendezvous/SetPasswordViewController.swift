//
//  SetPasswordViewController.swift
//  Rendezvous
//
//  Created by Steven Zheng on 4/18/16.
//  Copyright © 2016 szzheng. All rights reserved.
//

import UIKit
import Firebase

class SetPasswordViewController: UIViewController {

    var email: String!
    
    @IBOutlet var passwordCaption: UILabel!
    @IBOutlet var errorMessage: UILabel!
    @IBOutlet var password: UITextField!
    @IBOutlet var continueButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        passwordCaption.text = "Your password should be at least 6 characters and contain a mix of letters and numbers"
        
        password.becomeFirstResponder()
        
        disableContinue()
        errorMessage.hidden = true
        
        // reserve email
        /*
        let ref = Firebase(url:"https://resplendent-torch-7790.firebaseio.com/user-emails")
        let newChildRef = ref.childByAutoId()
        newChildRef.setValue(["email": email])*/

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Checks validity of password format
    func isValidPassword(testStr:String) -> Bool {
        let decimalCharacters = NSCharacterSet.decimalDigitCharacterSet()
        let decimalRange = testStr.rangeOfCharacterFromSet(decimalCharacters, options: NSStringCompareOptions(), range: nil)
        
        if (decimalRange == nil) {
            disableContinue()
            return false
        }
        
        let letterCharacters = NSCharacterSet.letterCharacterSet()
        let letterRange = testStr.rangeOfCharacterFromSet(letterCharacters, options: NSStringCompareOptions(), range: nil)
        
        if (letterRange == nil) {
            disableContinue()
            return false
        }
        
        return true
    }

    @IBAction func editPassword(sender: AnyObject) {
        if (password.text!.characters.count >= 6) {
            self.continueButton.alpha = 1
            self.continueButton.userInteractionEnabled = true
        } else {
            disableContinue()
        }
        errorMessage.hidden = true
    }
    
    @IBAction func `continue`(sender: AnyObject) {
        
        // Password missing a letter or a number
        if (!isValidPassword(password.text!)) {
            self.errorMessage.hidden = false
            self.errorMessage.text = "Missing letter and/or number"
        } else {
            createUser()
        }
    }
    
    // Disables user from submitting email
    func disableContinue() -> Void {
        self.continueButton.alpha = 0.25
        self.continueButton.userInteractionEnabled = false
    }
    
    // retreat to set email screen
    @IBAction func back(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    func createUser() -> Void {
        let ref = Firebase(url: "https://resplendent-torch-7790.firebaseio.com/")
        ref.createUser(email, password: password.text!,
            withValueCompletionBlock: { error, result in
                if error != nil {
                    // There was an error creating the account
                    if let errorCode = FAuthenticationError(rawValue: error.code) {
                        switch (errorCode) {
                            // Developer / Config Errors
                        case .ProviderDisabled:
                            print(1)
                        case .InvalidConfiguration:
                            print(2)
                        case .InvalidOrigin:
                            print(3)
                        case .InvalidProvider:
                            print(4)
                            
                            // User Errors (Email / Password)
                        case .InvalidEmail:
                            print(5)
                        case .InvalidPassword:
                            print(6)
                        case .InvalidToken:
                            print(7)
                        case .UserDoesNotExist:
                            print(8)
                        case .EmailTaken:
                            print(9)
                            
                            // User Errors (Facebook / Twitter / Github / Google)
                        case .DeniedByUser:
                            print(10)
                        case .InvalidCredentials:
                            print(11)
                        case .InvalidArguments:
                            print(12)
                        case .ProviderError:
                            print(13)
                        case .LimitsExceeded:
                            print(14)
                            
                            // Client side errors
                        case .NetworkError:
                            print(15)
                        case .Preempted:
                            print(16)
                        case .Unknown:
                            print(17)

                        default:
                            print("Handle default situation")
                        }
                    }
                } else {
                    let uid = result["uid"] as? String
                    print("Successfully created user account with uid: \(uid)")
                    
                    let userEmailRef = Firebase(url: "https://resplendent-torch-7790.firebaseio.com/user-emails")
                    let newChildRef = userEmailRef.childByAutoId()
                    let newVal = ["email": self.email]
                    newChildRef.setValue(newVal)
                }
        })
        
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
