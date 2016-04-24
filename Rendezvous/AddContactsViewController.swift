//
//  AddContactsViewController.swift
//  Rendezvous
//
//  Created by Steven Zheng on 4/22/16.
//  Copyright © 2016 szzheng. All rights reserved.
//

import UIKit
import Firebase

class AddContactsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating, UISearchBarDelegate {

    var dataArray = [String]()
    
    var filteredArray = [String]()
    
    var shouldShowSearchResults = false
    
    let usersRef = Firebase(url:"https://resplendent-torch-7790.firebaseio.com/users")
    
    
    var searchController: UISearchController!
    

    @IBOutlet var searchResults: UITableView!
    
    override func viewDidLoad() {
        searchResults.delegate = self
        searchResults.dataSource = self
        
        //loadListOfUsers()
        configureSearchController()
        
        searchResults.tableFooterView = UIView()
        searchResults.layoutMargins = UIEdgeInsetsZero;
        
        searchController.searchBar.becomeFirstResponder()
        searchController.searchBar.autocapitalizationType = UITextAutocapitalizationType.None
        
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
        
        // Place the search bar view to the tableview headerview.
        searchResults.tableHeaderView = searchController.searchBar
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchString = searchController.searchBar.text
        
        // Filter the data array and get only those countries that match the search text.
        /*
        filteredArray = dataArray.filter({ (personName) -> Bool in
            let personNameText: NSString = personName
            
            return (personNameText.rangeOfString(searchString!, options: NSStringCompareOptions.CaseInsensitiveSearch).location) != NSNotFound
        })*/
        
        // Reload the tableview.
        var found = false
        usersRef.queryOrderedByKey().observeEventType(.ChildAdded, withBlock: { snapshot in
            if let email = snapshot.value["email"] as? String {
                if (email == searchString) {
                    print("equal")
                    print(self.shouldShowSearchResults)
                    self.filteredArray += [email]
                    print(self.filteredArray.count)
                    
                    self.searchResults.reloadData()
                    found = true
                }
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
        let cell = tableView.dequeueReusableCellWithIdentifier("idCell", forIndexPath: indexPath)
        
        if shouldShowSearchResults {
            cell.textLabel?.text = filteredArray[indexPath.row]
        }
        else {
            cell.textLabel?.text = dataArray[indexPath.row]
        }
        
        return cell
        
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
