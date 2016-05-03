//
//  ContactViewController.swift
//  Rendezvous
//
//  Created by Steven Zheng on 5/2/16.
//  Copyright © 2016 szzheng. All rights reserved.
//

import UIKit
import Firebase
import JTCalendar

class ContactViewController: UIViewController, JTCalendarDelegate {
    
    // Get a reference to requests
    let ref = Firebase(url:"https://rendezvous-app.firebaseio.com/")
    let outgoingRef = Firebase(url:"https://rendezvous-app.firebaseio.com/outgoing/")
    let incomingRef = Firebase(url:"https://rendezvous-app.firebaseio.com/incoming/")

    @IBOutlet var navigationBar: UINavigationBar!
    
    var calendarMenuView: JTCalendarMenuView?
    var calendarContentView: JTHorizontalCalendarView?
    var calendarManager: JTCalendarManager!
    
    @IBOutlet var contactName: UILabel!
    @IBOutlet var message: UITextField!
    
    var highlight = UIView()
    
    var name: String!
    var email: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* selected highlight */
        highlight.hidden = true
        //highlight.backgroundColor = UIColor.blueColor()
        //highlight.alpha = 0.25
        self.view.addSubview(highlight)
        
        contactName.text = name!
        
        calendarManager = JTCalendarManager()
        calendarManager.delegate = self
        let menuFrame = CGRect(x: 0, y: navigationBar.frame.origin.y + navigationBar.frame.height, width: self.view.frame.width, height: navigationBar.frame.height)
        
        calendarMenuView = JTCalendarMenuView(frame: menuFrame)
        
        
        
        let contentFrame = CGRect(x: 0, y: navigationBar.frame.origin.y + (navigationBar.frame.height * 2), width: self.view.frame.width, height: navigationBar.frame.height * 1.5)
        calendarContentView = JTHorizontalCalendarView(frame: contentFrame)
        
        calendarManager.menuView = calendarMenuView
        calendarManager.contentView = calendarContentView
        calendarManager.setDate(NSDate())
        
        calendarManager.settings.weekModeEnabled = true
        calendarManager.reload()
        
        self.view.addSubview(calendarContentView!)
        
        self.view.addSubview(calendarMenuView!)
        
        // Do any additional setup after loading the view.
    }
    
    
    func calendar(calendar: JTCalendarManager!, prepareDayView dayView: UIView!) {
        
        let JTDayView = dayView as! JTCalendarDayView
        JTDayView.hidden = false
        
        // Test if the dayView is from another month than the page
        // Use only in month mode for indicate the day of the previous or next month
        /*
        if([dayView isFromAnotherMonth]){
            dayView.hidden = YES;
        }
            // Today
        else if([_calendarManager.dateHelper date:[NSDate date] isTheSameDayThan:dayView.date]){
            dayView.circleView.hidden = NO;
            dayView.circleView.backgroundColor = [UIColor blueColor];
            dayView.dotView.backgroundColor = [UIColor whiteColor];
            dayView.textLabel.textColor = [UIColor whiteColor];
        }
            // Selected date
        else if(_dateSelected && [_calendarManager.dateHelper date:_dateSelected isTheSameDayThan:dayView.date]){
            dayView.circleView.hidden = NO;
            dayView.circleView.backgroundColor = [UIColor redColor];
            dayView.dotView.backgroundColor = [UIColor whiteColor];
            dayView.textLabel.textColor = [UIColor whiteColor];
        }
            // Another day of the current month
        else{
            dayView.circleView.hidden = YES;
            dayView.dotView.backgroundColor = [UIColor redColor];
            dayView.textLabel.textColor = [UIColor blackColor];
        }
        */
        /*
        // Your method to test if a date have an event for example
        if(haveEventForDay(dayView.date)) {
            dayView.dotView.hidden = false
        } else {
            //dayView.dotView.hidden = true
            dayView.
        }*/
        
        
        
    }
    
    
    func calendar(calendar: JTCalendarManager!, didTouchDayView dayView: UIView!) {
        
        highlight.removeFromSuperview()
        
        //print("touching day view")
        
        // Use to indicate the selected date
        let JTDayView = dayView as! JTCalendarDayView
        let dateSelected = JTDayView.date
        
        // Animation for the circleView
        JTDayView.circleView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.1, 0.1)
        UIView.transitionWithView(JTDayView, duration: 0.3, options: UIViewAnimationOptions.TransitionNone, animations: {
            JTDayView.circleView.transform = CGAffineTransformIdentity
            }, completion: nil)
        
        // Load the previous page or next page if touch a day from another month
        /*
        if (!(calendarManager.dateHelper.date(calendarContentView?.date, isTheSameMonthThan: JTDayView.date))) {
            if (calendarContentView?.date.compare(JTDayView.date) == NSComparisonResult.OrderedAscending) {
                calendarContentView?.loadNextPageWithAnimation()
            } else {
                calendarContentView?.loadPreviousPageWithAnimation()
            }
        }*/
        
        highlight = UIView(frame: CGRectMake(JTDayView.frame.width/2 - JTDayView.frame.height/2, 0, JTDayView.frame.height, JTDayView.frame.height))
        //JTDayView.backgroundColor = UIColor.blueColor()
        highlight.backgroundColor = UIColor.blueColor()
        highlight.alpha = 0.25
        highlight.layer.cornerRadius = highlight.frame.width / 2
        
        JTDayView.addSubview(highlight)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func back(sender: AnyObject) {
        //dismissViewControllerAnimated(true, completion: nil)
        self.navigationController?.popViewControllerAnimated(true)
    }

    @IBAction func send(sender: AnyObject) {
        
        let yourEmail = ref.authData.providerData["email"] as! String
        let yourAdjustedEmail = escapeEmailAddress(yourEmail)
        
        let contactAdjustedEmail = escapeEmailAddress(email)
        
        
        // outgoing request
        var request = ["message": message.text!, "to": contactAdjustedEmail]
        outgoingRef.childByAppendingPath(yourAdjustedEmail).childByAutoId().setValue(request)
        
        
        // incoming request
        request = ["message": message.text!, "from": yourAdjustedEmail]
        incomingRef.childByAppendingPath(contactAdjustedEmail).childByAutoId().setValue(request)
        
        //let newVal = ["message": message.text!, "from": yourAdjustedEmail, "to": contactName.text!]
        //newChildRef.setValue(newVal)
        
        /*
        let yourEmail = ref.authData.providerData["email"] as! String
        let yourAdjustedEmail = escapeEmailAddress(yourEmail)*/
        
        
        /*contactsRef.childByAppendingPath(yourAdjustedEmail).childByAppendingPath(adjustedEmail).updateChildValues(addedContact)*/

        
    }
    
    func escapeEmailAddress(email: String) -> String {
        
        // Replace '.' (not allowed in a Firebase key) with ',' (not allowed in an email address)
        var adjustedEmail = email.lowercaseString
        adjustedEmail = email.stringByReplacingOccurrencesOfString(".", withString: ",", options: NSStringCompareOptions.LiteralSearch, range: nil)
        return adjustedEmail
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
