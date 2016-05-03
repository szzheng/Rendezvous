//
//  AddContactsViewController.swift
//  Rendezvous
//
//  Created by Steven Zheng on 4/22/16.
//  Copyright © 2016 szzheng. All rights reserved.
//

import UIKit
import Firebase

class AddContactsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating, UISearchBarDelegate, UISearchControllerDelegate {

    var dataArray = [String]()
    
    @IBOutlet var doneButton: UIButton!
    var filteredPhoto = UIImage()
    var filteredArray = [String]()
    var filteredEmail = ""
    var filteredPhotoString = ""
    
    var activityIndicator = UIActivityIndicatorView()
    
    var shouldShowSearchResults = false
    
    let usersRef = Firebase(url:"https://rendezvous-app.firebaseio.com/users")
    let contactsRef = Firebase(url:"https://rendezvous-app.firebaseio.com/contacts")
    
    var usersQuery: FQuery!
    
    @IBOutlet var doneButtonBottomConstraint: NSLayoutConstraint!
    
    //var usersRef: Firebase!
    
    var users = [FDataSnapshot]()
    
    var searchController: UISearchController!
    
    
    

    @IBOutlet var searchResults: UITableView!
    
    override func viewDidLoad() {
        searchResults.delegate = self
        searchResults.dataSource = self
        //searchController.delegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AddContactsViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        
        //loadListOfUsers()
        
        usersQuery = usersRef.queryOrderedByKey()
        
        configureSearchController()
        
        searchResults.tableFooterView = UIView()
        searchResults.layoutMargins = UIEdgeInsetsZero;
        
        
        searchController.searchBar.autocapitalizationType = UITextAutocapitalizationType.None
        
        
        searchController.active = true
        
        doneButton.hidden = true
        
        /*
        usersQuery.observeEventType(.ChildAdded, withBlock: { snapshot in
            
            self.users += [snapshot]
            print("HELLO")
        })*/
        /*
        displayActivityIndicator()
        usersQuery.observeEventType(.ChildAdded, withBlock: { snapshot in
            self.activityIndicator.stopAnimating()
        })*/
        

    }

    
    func didPresentSearchController(searchController: UISearchController) {
        searchController.searchBar.becomeFirstResponder()
        doneButton.hidden = false
    }
    
    

    
    func keyboardWillShow(notification:NSNotification) {
        let userInfo:NSDictionary = notification.userInfo!
        let keyboardFrame:NSValue = userInfo.valueForKey(UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.CGRectValue()
        let keyboardHeight = keyboardRectangle.height
        
        doneButtonBottomConstraint.constant = keyboardHeight
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        shouldShowSearchResults = true
        searchResults.reloadData()
    }
    
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        shouldShowSearchResults = false
        searchResults.reloadData()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if !shouldShowSearchResults {
            shouldShowSearchResults = true
            searchResults.reloadData()
        }
        
        searchController.searchBar.resignFirstResponder()
    }
    
    func configureSearchController() {
        
        // Initialize and perform a minimum configuration to the search controller.
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search here..."
        searchController.searchBar.delegate = self
        searchController.searchBar.sizeToFit()
        
        searchController.delegate = self
        
        // Place the search bar view to the tableview headerview.
        searchResults.tableHeaderView = searchController.searchBar
        
        

        
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
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {

        let searchString = searchController.searchBar.text
        
        print ("UPDATING")
        
        // Filter the data array and get only those countries that match the search text.
        /*
        filteredArray = dataArray.filter({ (personName) -> Bool in
            let personNameText: NSString = personName
            
            return (personNameText.rangeOfString(searchString!, options: NSStringCompareOptions.CaseInsensitiveSearch).location) != NSNotFound
        })*/
        
        
        
        // Reload the tableview.
        var found = false
        //displayActivityIndicator()
        
        usersQuery.observeEventType(.ChildAdded, withBlock: { snapshot in
            
            //self.activityIndicator.stopAnimating()
            //self.activityIndicator.hidden = true
            print(snapshot.key)
            if let email = snapshot.value["email"] as! String! {
                
                if (email == searchString) {
                    print("equal")
                    //print(self.shouldShowSearchResults)
                    
                    let name = snapshot.value["name"] as! String!
                    /*
                    if let profilePicture = snapshot.value["Profile Picture"] as? String {
                        let decodedData = NSData(base64EncodedString: profilePicture, options: NSDataBase64DecodingOptions(rawValue: 0))
                        let decodedimage = UIImage(data: decodedData!)
                        self.filteredPhoto = decodedimage! as UIImage
                    } else {
                        self.filteredPhoto = UIImage(named: "Siberian Husky.jpg")!
                    }
 */
                    let email = snapshot.value["email"] as! String!
                    self.filteredEmail = email
                    if let base64String = snapshot.value["Profile Picture"] as! String! {
                        if (base64String == "") {
                            self.filteredPhotoString = ""
                            self.filteredPhoto = UIImage(named: "Siberian Husky.jpg")!
                        } else {
                            let decodedData = NSData(base64EncodedString: base64String, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
                            let image = UIImage(data: decodedData!)
                            self.filteredPhoto = image!
                            self.filteredPhotoString = base64String
                        }
                    } else {
                        self.filteredPhotoString = ""
                        self.filteredPhoto = UIImage(named: "Siberian Husky.jpg")!
                    }
                    
                    self.filteredArray += [name]
                    //print(self.filteredArray.count)
                    
                    self.searchResults.reloadData()
                    found = true
                }
                print("not equal")
                if (found != true) {
                    print("none found")
                    self.filteredArray = []
                    self.searchResults.reloadData()
                }
            }
        })
        
        //searchResults.reloadData()
    }
    
    
    // MARK: UITableView Delegate and Datasource functions
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if shouldShowSearchResults {
            if (filteredArray.count > 1) {
                return 1
            }
            return filteredArray.count
        }
        else {
            return 0
        }
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("idCell", forIndexPath: indexPath) as! AddContactCell
        
        if shouldShowSearchResults {
            //cell.textLabel?.text = filteredArray[indexPath.row]
            cell.name.text = filteredArray[indexPath.row]
            cell.profilePicture.image = filteredPhoto
            cell.email = filteredEmail
            cell.profilePictureString = filteredPhotoString
        } else {
            cell.textLabel?.text = dataArray[indexPath.row]
        }
        
        return cell
        
    }
    
    

    @IBAction func done(sender: AnyObject) {
        searchController.active = false
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
