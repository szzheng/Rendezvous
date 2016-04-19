//
//  EnterBirthdayViewController.swift
//  Rendezvous
//
//  Created by Steven Zheng on 4/19/16.
//  Copyright © 2016 szzheng. All rights reserved.
//

import UIKit
import Firebase

class EnterBirthdayViewController: UIViewController {
    
    var email: String!
    var password: String!
    @IBOutlet var errorMessage: UILabel!
    @IBOutlet var datePicker: UIDatePicker!
    
    @IBOutlet var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        errorMessage.hidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func back(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func signUp(sender: AnyObject) {
        
        let birthDay = datePicker.date
        
        let calendar = NSCalendar.currentCalendar()
        let birthDaycomponents = calendar.components([.Day , .Month , .Year], fromDate: birthDay)
        
        
        let currentDay = NSDate()
        let currentDaycomponents = calendar.components([.Day , .Month , .Year], fromDate: currentDay)
        
        var error = false
        
        // less than 13 year dates
        if ((currentDaycomponents.year - birthDaycomponents.year) < 13) {
            error = true
            
        // 13 year dates apart
        } else if (currentDaycomponents.year - birthDaycomponents.year) == 13 {
            
            // less than 13 full years
            if ((currentDaycomponents.month - birthDaycomponents.month) < 0) {
                error = true
            } else if ((currentDaycomponents.month - birthDaycomponents.month) == 0) {
                if ((currentDaycomponents.day - birthDaycomponents.day) < 0) {
                    error = true
                }
            }
        }
        
        if (error == true) {
            signUpButton.userInteractionEnabled = false
            signUpButton.alpha = 0.25
            errorMessage.hidden = false
        } else {
            createUser()
        }
    }
    
    @IBAction func setDate(sender: AnyObject) {
        signUpButton.userInteractionEnabled = true
        signUpButton.alpha = 1
        errorMessage.hidden = true
    }
    
    func createUser() -> Void {
        let ref = Firebase(url: "https://resplendent-torch-7790.firebaseio.com/")
        ref.createUser(email, password: password  ,
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
