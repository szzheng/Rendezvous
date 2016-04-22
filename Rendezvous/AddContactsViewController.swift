//
//  AddContactsViewController.swift
//  Rendezvous
//
//  Created by Steven Zheng on 4/22/16.
//  Copyright © 2016 szzheng. All rights reserved.
//

import UIKit

class AddContactsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating {

    @IBOutlet var contactTableView: UITableView!
    
    var contactsArray = [String]()
    var filteredContacts = [String]()
    var resultSearchController = UISearchController()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.contactsArray += ["Roger Federer"]
        self.contactsArray += ["Rafael Nadal"]
        self.contactsArray += ["Novak Djokovic"]
        self.contactsArray += ["Andy Murray "]
        self.contactsArray += ["Kei Nishikori"]
        self.contactsArray += ["Juan Martin delPotro"]
        
        self.resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            controller.searchBar.placeholder = "Search by email"
            
            self.contactTableView.tableHeaderView = controller.searchBar
            
            return controller
        })()
        
        
        // Reload the table
        self.contactTableView.reloadData()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (self.resultSearchController.active) {
            return self.filteredContacts.count
        } else {
            return self.contactsArray.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        // 3
        if (self.resultSearchController.active) {
            cell.textLabel?.text = filteredContacts[indexPath.row]
            
            return cell
        }
        else {
            cell.textLabel?.text = contactsArray[indexPath.row]
            
            return cell
        }

    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filteredContacts.removeAll(keepCapacity: false)
        
        let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", searchController.searchBar.text!)
        let array = (contactsArray as NSArray).filteredArrayUsingPredicate(searchPredicate)
        filteredContacts = array as! [String]
        self.contactTableView.reloadData()
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
