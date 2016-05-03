//
//  ContactsViewController.swift
//  Rendezvous
//
//  Created by Steven Zheng on 4/30/16.
//  Copyright © 2016 szzheng. All rights reserved.
//

import UIKit
import Firebase

class ContactsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let ref = Firebase(url: "https://rendezvous-app.firebaseio.com/")
    let contactsRef = Firebase(url: "https://rendezvous-app.firebaseio.com/contacts")
    
    
    var email = ""
    
    @IBOutlet var contactsTable: UITableView!
    
    var contacts = [Contact]()
    var myContactsRef: Firebase!
    
    var selectedContactEmail = "DEFAULT"
    var selectedContactName = "Default Name"
    
    var activityIndicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Get current user's email
        /*
        email = ref.authData.providerData["email"] as! String
        print(email)
        myContactsRef = Firebase(url: "https://rendezvous-app.firebaseio.com/contacts/" + escapeEmailAddress(email))
        
        getContacts()
        */
        
        
        

        // Do any additional setup after loading the view.
    }
    
    
    func escapeEmailAddress(email: String) -> String {
        
        // Replace '.' (not allowed in a Firebase key) with ',' (not allowed in an email address)
        var adjustedEmail = email.lowercaseString
        adjustedEmail = email.stringByReplacingOccurrencesOfString(".", withString: ",", options: NSStringCompareOptions.LiteralSearch, range: nil)
        return adjustedEmail
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func displayActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        //UIApplication.sharedApplication().beginIgnoringInteractionEvents()
    }

    func getContacts() -> Void {
        
        let contactsQuery = myContactsRef.queryOrderedByKey()
        
        displayActivityIndicator()
        
        contactsQuery.observeEventType(.ChildAdded, withBlock: { snapshot in
            
            //self.activityIndicator.stopAnimating()
            //self.activityIndicator.hidden = true
            /*
            if let email = snapshot.value["email"] as String! {
                print("HI")
            }*/
            
            let contact = Contact(name: snapshot.value["name"] as! String!,
            profilePicture: snapshot.value["profile picture"] as! String!,
            email: snapshot.value["email"] as! String!)
             
            self.contacts += [contact]
            self.contactsTable.reloadData()
            
            self.activityIndicator.stopAnimating()
        })
        
        /*
        contactsQuery.observeEventType(.Value, withBlock: { snapshot in
            
            //let snapShotEmail = snapshot.value["name"] as String!
            print("HI")
            //if ((snapshot.key) == self.escapeEmailAddress(self.email)) {
            //    print("BYE")
            //}
            print(snapshot.key)
            /*
            let contact = Contact(name: snapshot.value["name"] as String!,
                profilePicture: snapshot.value["profilePicture"] as String!,
                email: snapshot.value["email"] as String!)
            
            self.contacts += [contact]
            
            self.contactsTable.reloadData()*/
            
        })*/
        

        
    }
    
    // MARK: UITableView Delegate and Datasource functions
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return 0
        return contacts.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Contact", forIndexPath: indexPath) as! ContactCell
        
        cell.name.text = contacts[indexPath.row].name
        if let base64String = contacts[indexPath.row].profilePicture {
            
            if (base64String == "") {
                cell.profilePicture.image = UIImage(named: "Siberian Husky.jpg")
            } else {
                let decodedData = NSData(base64EncodedString: base64String, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
                let image = UIImage(data: decodedData!)
                //self.filteredPhoto = image!
                cell.profilePicture.image = image!
            }
        } else {
            cell.profilePicture.image = UIImage(named: "Siberian Husky.jpg")
        }
        
        cell.email = contacts[indexPath.row].email
        print(contacts[indexPath.row].email)
        
        return cell
        
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //CODE TO BE RUN ON CELL TOUCH
        
        //let cell = tableView.dequeueReusableCellWithIdentifier("Contact", forIndexPath: indexPath) as! ContactCell
        
        //print(cell.name.text!)
        
        //tableView.deselectRowAtIndexPath(indexPath, animated: true)
        //selectedContactEmail = cell.email
        //performSegueWithIdentifier("ContactSegue", sender: self)
        
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! ContactCell
        selectedContactEmail = cell.email
        selectedContactName = cell.name.text!
        //print(selectedContactEmail)
        performSegueWithIdentifier("ContactSegue", sender: self)
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    
    
    
    
    
    
    
    
    
    
    
    func getDataFromUrl(url:NSURL, completion: ((data: NSData?, response: NSURLResponse?, error: NSError? ) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
            completion(data: data, response: response, error: error)
            }.resume()
    }
    
    func downloadImage(url: NSURL, cell: ContactCell){
        print("Download Started")
        print("lastPathComponent: " + (url.lastPathComponent ?? ""))
        getDataFromUrl(url) { (data, response, error)  in
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                guard let data = data where error == nil else { return }
                print(response?.suggestedFilename ?? "")
                print("Download Finished")
                cell.profilePicture.image = UIImage(data: data)
            }
        }
    }


    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        let contactVC = segue.destinationViewController as! ContactViewController
        
        print(selectedContactEmail)
        contactVC.email = selectedContactEmail
        contactVC.name = selectedContactName
    }
 

}
