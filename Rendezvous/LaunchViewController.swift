//
//  HomeViewController.swift
//  Rendezvous
//
//  Created by Steven Zheng on 4/17/16.
//  Copyright © 2016 szzheng. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class LaunchViewController: UIViewController {

    let ref = FIRDatabase.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //ref.unauth()
        
        // Do any additional setup after loading the view.
    }
    
    
    override func viewDidAppear(animated: Bool) {
        //ref.unauth()
        if FIRAuth.auth()?.currentUser != nil {
            // user authenticated
            performSegueWithIdentifier("HomeSegue", sender: self)
        } else {
            // No user is signed in
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logIn(sender: AnyObject) {
        dispatch_async(dispatch_get_main_queue(), {
            self.performSegueWithIdentifier("LogInSegue", sender: self)
        })
        //performSegueWithIdentifier("LogInSegue", sender: self)
    }

    
   
    @IBAction func signUp(sender: AnyObject) {
        performSegueWithIdentifier("SignUpSegue", sender: self)
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if (segue.identifier == "HomeSegue") {
            let destinationVC = segue.destinationViewController as! UITabBarController
            let contactsVC = destinationVC.childViewControllers[1] as! ContactsViewController
            
            contactsVC.email = (FIRAuth.auth()?.currentUser?.email)!
            //print(contactsVC.email)
            contactsVC.myContactsRef = FIRDatabase.database().referenceFromURL("https://rendezvous-app.firebaseio.com/contacts/" + contactsVC.escapeEmailAddress(contactsVC.email))
            
            contactsVC.getContacts()
            
            let requestsVC = destinationVC.childViewControllers[0] as! RequestsViewController
            requestsVC.email = contactsVC.email
            
            //requestsVC.getRequests()
            
            
            
        }
    }
    

}
