//
//  MeViewController.swift
//  Rendezvous
//
//  Created by Steven Zheng on 5/2/16.
//  Copyright © 2016 szzheng. All rights reserved.
//

import UIKit
import Firebase

class MeViewController: UIViewController {

    let ref = Firebase(url: "https://rendezvous-app.firebaseio.com/")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func logOut(sender: AnyObject) {
        ref.unauth()
        self.navigationController?.popToRootViewControllerAnimated(false)
        
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
