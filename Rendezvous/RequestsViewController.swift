//
//  UpcomingViewController.swift
//  Rendezvous
//
//  Created by Steven Zheng on 5/16/16.
//  Copyright © 2016 szzheng. All rights reserved.
//

import UIKit
import Firebase

class RequestsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let ref = FIRDatabase.database().reference()
    let incomingRef = FIRDatabase.database().referenceFromURL("https://rendezvous-app.firebaseio.com/incoming")
    let outgoingRef = FIRDatabase.database().referenceFromURL("https://rendezvous-app.firebaseio.com/outgoing")
    
    var email: String!  // not key, needs conversion
    
    
    var activityIndicator = UIActivityIndicatorView()
    
    @IBOutlet var requestsTable: UITableView!
    
    var requests = [Request]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        requestsTable.backgroundColor = UIColor.whiteColor()
        //requestsTable.layoutMargins = UIEdgeInsetsZero;
        // Do any additional setup after loading the view.
        getRequests()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func displayActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        //UIApplication.sharedApplication().beginIgnoringInteractionEvents()
    }
    
    func escapeEmailAddress(email: String) -> String {
        
        // Replace '.' (not allowed in a Firebase key) with ',' (not allowed in an email address)
        var adjustedEmail = email.lowercaseString
        adjustedEmail = email.stringByReplacingOccurrencesOfString(".", withString: ",", options: NSStringCompareOptions.LiteralSearch, range: nil)
        return adjustedEmail
    }
    
    func getRequests() -> Void {
        print("get requests")
        
        
        let myEmailKey = escapeEmailAddress(email)
        let myRequestsKey = FIRDatabase.database().referenceFromURL("https://rendezvous-app.firebaseio.com/requests/" + myEmailKey + "/")
        let incomingQuery = myRequestsKey.queryOrderedByChild("date")
        
        displayActivityIndicator()
        
        incomingQuery.observeEventType(.Value, withBlock: { snapshot in
            
            //self.activityIndicator.stopAnimating()
            //self.activityIndicator.hidden = true
            /*
             if let email = snapshot.value["email"] as String! {
             print("HI")
             }*/
            //print(snapshot.value["time"])
            self.activityIndicator.stopAnimating()
            if (snapshot.childrenCount == 0) {
                print("NO REQUESTS")
            } else {
                self.requests = []
                for child in snapshot.children {
                    let incomingRequest = Request(comment: child.value["comment"] as! String!,
                        date: child.value["date"] as! String!,
                        time: child.value["time"] as! String!,
                        from: child.value["from"] as! String!,
                        type: child.value["type"] as! Int!,
                        to: child.value["to"] as! String)
                    
                    print("augmenting")
                    self.requests += [incomingRequest]
                }
                self.requestsTable.reloadData()
            }
        })
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requests.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let request = requests[indexPath.row]
        
        
        switch request.type {
            case 0:
                let cell = tableView.dequeueReusableCellWithIdentifier("Request", forIndexPath: indexPath) as! RequestCell
                cell.profilePicture.image = UIImage(named: "Siberian Husky.jpg")
                cell.header.text = request.from + " " + request.date + " from"
                cell.preservesSuperviewLayoutMargins = false
                cell.separatorInset = UIEdgeInsetsZero
                cell.layoutMargins = UIEdgeInsetsZero
                return cell
            case 1:
                let cell = tableView.dequeueReusableCellWithIdentifier("Request", forIndexPath: indexPath) as! RequestCell
                cell.profilePicture.image = UIImage(named: "Siberian Husky.jpg")
                cell.header.text = request.to + " " + request.date + " to"
                cell.preservesSuperviewLayoutMargins = false
                cell.separatorInset = UIEdgeInsetsZero
                cell.layoutMargins = UIEdgeInsetsZero
                return cell
            default:
                let cell = UITableViewCell()
                return cell
        }


        
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //CODE TO BE RUN ON CELL TOUCH
        
        //let cell = tableView.dequeueReusableCellWithIdentifier("Contact", forIndexPath: indexPath) as! ContactCell
        
        //print(cell.name.text!)
        
        //tableView.deselectRowAtIndexPath(indexPath, animated: true)
        //selectedContactEmail = cell.email
        //performSegueWithIdentifier("ContactSegue", sender: self)
        
        //let cell = tableView.cellForRowAtIndexPath(indexPath) as! ContactCell
    }


}
