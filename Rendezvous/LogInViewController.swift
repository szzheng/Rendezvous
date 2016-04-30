//
//  LogInViewController.swift
//  Rendezvous
//
//  Created by Steven Zheng on 4/30/16.
//  Copyright © 2016 szzheng. All rights reserved.
//

import UIKit

class LogInViewController: UIViewController {

    @IBOutlet var email: UITextField!
    @IBOutlet var password: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /* Log the user in and go to main page */
    @IBAction func logIn(sender: AnyObject) {
        
        let email = self.email.text!
        let password = self.password.text!
        
        
        
    }
    
    
    /* Firebase log in */
    func logInFirebase(email: String, password: String) -> Void {
        
    }
    
    
    /* Go back to launch screen */
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
