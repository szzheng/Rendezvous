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
import MaterialControls

class ContactViewController: UIViewController, JTCalendarDelegate, MDCalendarTimePickerDialogDelegate {

    var notificationCenterCurrentlyDisplayed: Bool!
    
    // Get a reference to requests
    let ref = Firebase(url:"https://rendezvous-app.firebaseio.com/")
    let outgoingRef = Firebase(url:"https://rendezvous-app.firebaseio.com/outgoing/")
    let incomingRef = Firebase(url:"https://rendezvous-app.firebaseio.com/incoming/")

    @IBOutlet var navigationBar: UINavigationBar!
    
    var calendarMenuView: JTCalendarMenuView?
    var calendarContentView: JTHorizontalCalendarView?
    var calendarManager: JTCalendarManager!
    
    var timePicker: UIDatePicker!
    var alternateTimePicker: MDTimePickerDialog!
    var alternateTimePickerFrame: CGRect!
    
    var dateAndTimeLabel: UILabel!
    
    @IBOutlet var contactName: UILabel!
    @IBOutlet var message: UITextField!
    
    var highlight = UIView()
    
    var name: String!
    var email: String!
    
    var selectionOffset = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let navigationBarHeight = navigationBar.frame.height
        let navigationBarY = navigationBar.frame.origin.y
        let viewWidth = self.view.frame.width
        let viewHeight = self.view.frame.height
        var yOffset = navigationBarY + navigationBarHeight
        var availableSpace = viewHeight - navigationBarHeight
        
        /* Calendar setup */
        
        /* selected highlight */
        highlight.hidden = true
        //highlight.backgroundColor = UIColor.blueColor()
        //highlight.alpha = 0.25
        highlight.alpha = 0
        self.view.addSubview(highlight)
        
        contactName.text = name!
        
        calendarManager = JTCalendarManager()
        calendarManager.delegate = self
        
        
        let menuFrame = CGRect(x: 0, y: yOffset, width: viewWidth, height: navigationBarHeight)
        yOffset += navigationBarHeight
        availableSpace -= navigationBarHeight
        
        calendarMenuView = JTCalendarMenuView(frame: menuFrame)
 
        
        let contentFrame = CGRect(x: 0, y: yOffset, width: viewWidth, height: navigationBarHeight * 1.5)
        yOffset += navigationBarHeight * 1.5
        availableSpace -= navigationBarHeight * 1.5
        calendarContentView = JTHorizontalCalendarView(frame: contentFrame)
        
        calendarManager.menuView = calendarMenuView
        calendarManager.contentView = calendarContentView
        calendarManager.setDate(NSDate())
        
        calendarManager.settings.weekModeEnabled = true
        calendarManager.reload()
        
        self.view.addSubview(calendarContentView!)
        self.view.addSubview(calendarMenuView!)
        
        
        /* End Calendar Setup */
        
        /* Show date and time */
        /*
        let dateAndTimeFrame = CGRectMake(0, yOffset, viewWidth, navigationBarHeight * 0.75)
        yOffset += navigationBarHeight * 0.75
        availableSpace -= navigationBarHeight * 0.75
        dateAndTimeLabel = UILabel(frame: dateAndTimeFrame)
        dateAndTimeLabel.text = "Monday, October 7"
        dateAndTimeLabel.textAlignment = NSTextAlignment.Center
        //dateAndTimeLabel.font = UIFont(name: "System", size: 17.0)
        self.view.addSubview(dateAndTimeLabel)
        */
        /* End show date and time */
        
        /* Time picker setup */
        /*
        let timePickerFrame = CGRectMake(0, yOffset, viewWidth, navigationBarHeight * 3)
        yOffset += navigationBarHeight * 3
        availableSpace -= navigationBarHeight * 3
        
        timePicker = UIDatePicker(frame: timePickerFrame)
        timePicker.datePickerMode = UIDatePickerMode.Time
        self.view.addSubview(timePicker)
        /* End Time picker setup */
        */
        
        /* Alternate time picker setup */
        
        alternateTimePickerFrame = CGRectMake(0, yOffset, viewWidth, navigationBarHeight * 8)
        yOffset += navigationBarHeight * 8
        availableSpace -= navigationBarHeight * 8
        //alternateTimePicker = MDTimePickerDialog(frame: alternateTimePickerFrame)
        alternateTimePicker = MDTimePickerDialog(hour: 12, andWithMinute: 0, andWithFrame: alternateTimePickerFrame)
        alternateTimePicker.frame = alternateTimePickerFrame
        alternateTimePicker.updateFrame(CGRectMake(0, 0, alternateTimePickerFrame.width, alternateTimePickerFrame.height))
        alternateTimePicker.delegate = self
        alternateTimePicker.show()
        
        self.view.addSubview(alternateTimePicker)
 
        
        
        /* Show duration options */
        /*
        let durationFrame = CGRectMake(0, yOffset, viewWidth, navigationBarHeight * 0.5)
        yOffset += navigationBarHeight * 0.5
        availableSpace -= navigationBarHeight * 0.5
        let durationLabel = UILabel(frame: durationFrame)
        durationLabel.text = ""
        self.view.addSubview(durationLabel)
        
        /
        let buttonFrame = CGRectMake(0, yOffset, navigationBarHeight * 0.9, navigationBarHeight * 0.9)
        yOffset += navigationBarHeight
        availableSpace -= navigationBarHeight
        let button15m = UIButton(frame: buttonFrame)
        button15m.layer.borderWidth = 0.25
        button15m.layer.borderColor = UIColor.grayColor().CGColor
        button15m.layer.cornerRadius = navigationBarHeight * 0.9 / 2
        button15m.frame.origin.x = (viewWidth / 8) - (navigationBarHeight * 0.9 / 2)
        button15m.setTitle("15m", forState: .Normal)
        button15m.titleLabel!.font = UIFont(name: "System", size: 13.0)
        button15m.setTitleColor(UIColor.blackColor(), forState: .Normal)
        button15m.setTitleColor(UIColor.redColor(), forState: .Selected)
        
        let button30m = UIButton(frame: buttonFrame)
        button30m.layer.borderWidth = 0.25
        button30m.layer.borderColor = UIColor.grayColor().CGColor
        button30m.layer.cornerRadius = navigationBarHeight * 0.9 / 2
        button30m.frame.origin.x = ((viewWidth / 8) * 3) - (navigationBarHeight * 0.9 / 2)
        button30m.setTitle("30m", forState: .Normal)
        button30m.titleLabel!.font = UIFont(name: "System", size: 13.0)
        button30m.setTitleColor(UIColor.blackColor(), forState: .Normal)
        button30m.setTitleColor(UIColor.redColor(), forState: .Selected)
        
        let button1h = UIButton(frame: buttonFrame)
        button1h.layer.borderWidth = 0.25
        button1h.layer.borderColor = UIColor.grayColor().CGColor
        button1h.layer.cornerRadius = navigationBarHeight * 0.9 / 2
        button1h.frame.origin.x = ((viewWidth / 8) * 5) - (navigationBarHeight * 0.9 / 2)
        button1h.setTitle("1h", forState: .Normal)
        button1h.titleLabel!.font = UIFont(name: "System", size: 13.0)
        button1h.setTitleColor(UIColor.blackColor(), forState: .Normal)
        button1h.setTitleColor(UIColor.redColor(), forState: .Selected)
        
        let buttonPlus = UIButton(frame: buttonFrame)
        buttonPlus.layer.borderWidth = 0.25
        buttonPlus.layer.borderColor = UIColor.grayColor().CGColor
        buttonPlus.layer.cornerRadius = navigationBarHeight * 0.9 / 2
        buttonPlus.frame.origin.x = ((viewWidth / 8) * 7) - (navigationBarHeight * 0.9 / 2)
        buttonPlus.setTitle("+", forState: .Normal)
        buttonPlus.titleLabel!.font = UIFont(name: "System", size: 13.0)
        buttonPlus.setTitleColor(UIColor.blackColor(), forState: .Normal)
        buttonPlus.setTitleColor(UIColor.redColor(), forState: .Selected)
        
        button15m.addTarget(self, action: #selector(ContactViewController.pressed(_:)), forControlEvents: .TouchUpInside)
        button30m.addTarget(self, action: #selector(ContactViewController.pressed(_:)), forControlEvents: .TouchUpInside)
        button1h.addTarget(self, action: #selector(ContactViewController.pressed(_:)), forControlEvents: .TouchUpInside)
        buttonPlus.addTarget(self, action: #selector(ContactViewController.pressed(_:)), forControlEvents: .TouchUpInside)
        
        self.view.addSubview(button15m)
        self.view.addSubview(button30m)
        self.view.addSubview(button1h)
        self.view.addSubview(buttonPlus)
 */
        
        /* End show duration options */
        
        /* Show communication options */
        let communicationFrame = CGRectMake(0, yOffset, viewWidth, navigationBarHeight * 1.5)
        yOffset += navigationBarHeight * 1.5
        availableSpace -= navigationBarHeight * 1.5
        let communicationView = UIView(frame: communicationFrame)
        communicationView.backgroundColor = UIColor.blueColor()
        self.view.addSubview(communicationView)
        /* End show communication options */
        
        /* Setup send button */
        let sendButtonFrame = CGRectMake(0, viewHeight - navigationBarHeight, viewWidth, navigationBarHeight)
        let sendButton = UIButton(frame: sendButtonFrame)
        sendButton.setTitle("Request Meeting", forState: UIControlState.Normal)
        sendButton.backgroundColor = UIColor.whiteColor()
        sendButton.setTitleColor(UIColor.redColor(), forState: UIControlState.Normal)
        self.view.addSubview(sendButton)
        /* End setup send button */
        
        /* Show comment box */
        message.hidden = true
        //sendButton.hidden = true
        /* End show comment box */
        
        
        
        /* Notification center handling */
        notificationCenterCurrentlyDisplayed = false
        let defaultCenter = NSNotificationCenter.defaultCenter()
        defaultCenter.addObserver(self, selector: #selector(ContactViewController.onNotificationCenterDismissed), name: UIApplicationDidBecomeActiveNotification, object: nil)
        defaultCenter.addObserver(self, selector: #selector(ContactViewController.onNotificationCenterDisplayed), name: UIApplicationWillResignActiveNotification, object: nil)
        
        
        
        
        // Do any additional setup after loading the view.
    }
    
    func onNotificationCenterDismissed() {
        if ((notificationCenterCurrentlyDisplayed) != nil)
        {
            notificationCenterCurrentlyDisplayed = false;
            //print(alternateTimePicker.frame)
            alternateTimePicker.frame = alternateTimePickerFrame
        }
    }
    
    func onNotificationCenterDisplayed() {
        notificationCenterCurrentlyDisplayed = true;
    }
    
    
    
    /*
    func pressed(sender: UIButton!) {
        
        print("pressed")
        print(sender.state)
        if (sender.selected == true) {
            print("set selected")
            sender.selected = false
        } else {
            print("deselect")
            sender.selected = true
        }
        print(sender.state)
        
    }
    */
    
    func timePickerDialog(timePickerDialog: MDTimePickerDialog!, didSelectHour hour: Int, andMinute minute: Int) {
        print("HOUR")
        print(hour)
        print("MINUTE")
        print(minute)
    }
    
    /*
    func updateDateAndTime(date: NSDate) -> Void {
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        let description = formatter.stringFromDate(date)
        dateAndTimeLabel.text = description
    }*/
    
    
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
    
    func calendarDidLoadNextPage(calendar: JTCalendarManager!) {
        selectionOffset += 1
        
        if (selectionOffset > -2 && selectionOffset < 2) {
            highlight.hidden = false
        } else {
            highlight.hidden = true
        }
    }
    
    func calendarDidLoadPreviousPage(calendar: JTCalendarManager!) {
        selectionOffset -= 1
        
        if (selectionOffset > -2 && selectionOffset < 2) {
            highlight.hidden = false
        } else {
            highlight.hidden = true
        }
    }
    
    
    func calendar(calendar: JTCalendarManager!, didTouchDayView dayView: UIView!) {
        
        highlight.removeFromSuperview()
        
        //print("touching day view")
        
        // Use to indicate the selected date
        let JTDayView = dayView as! JTCalendarDayView
        let dateSelected = JTDayView.date
        //print(dateSelected.description)
        //updateDateAndTime(dateSelected)
        
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
        
        
        
        //print(calendarMenuView?.description)
        highlight = UIView(frame: CGRectMake(JTDayView.frame.width/2 - JTDayView.frame.height/2, 0, JTDayView.frame.height, JTDayView.frame.height))
        //JTDayView.backgroundColor = UIColor.blueColor()
        highlight.backgroundColor = UIColor.blueColor()
        highlight.alpha = 0.25
        highlight.layer.cornerRadius = highlight.frame.width / 2
        
        JTDayView.addSubview(highlight)
        
        selectionOffset = 0
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func back(sender: AnyObject) {
        //dismissViewControllerAnimated(true, completion: nil)
        alternateTimePicker.hidden = true
        self.navigationController?.popViewControllerAnimated(true)
    }

    /*
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

        
    }*/
    
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
