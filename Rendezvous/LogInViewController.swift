//
//  LogInViewController.swift
//  Rendezvous
//
//  Created by Steven Zheng on 4/30/16.
//  Copyright © 2016 szzheng. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class LogInViewController: UIViewController {

    @IBOutlet var email: UITextField!
    @IBOutlet var password: UITextField!
    
    var activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
    
    // Get a reference to database
    let ref = FIRDatabase.database().reference()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /* Log the user in and go to home page */
    @IBAction func logIn(sender: AnyObject) {
        
        let email = self.email.text!
        let password = self.password.text!
        
        logInFirebase(email, password: password)
    }
    
    
    /* Firebase log in */
    func logInFirebase(email: String, password: String) -> Void {
        
        displayActivityIndicator(activityIndicator)
        

        FIRAuth.auth()!.signInWithEmail(email, password: password) { (user, error) in
            self.activityIndicator.stopAnimating()
            UIApplication.sharedApplication().endIgnoringInteractionEvents()
            if error != nil {
                // an error occured while attempting login
                print(error!.description)
                print("Error login")
            } else {
                // user is logged in, check authData for data
                self.navigationController?.popViewControllerAnimated(false)
            }

        }
    }
    
    
    /* Go back to launch screen */
    @IBAction func back(sender: AnyObject) {
        
        self.navigationController?.popViewControllerAnimated(false)
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
