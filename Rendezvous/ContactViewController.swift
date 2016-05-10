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
import QuartzCore

class ContactViewController: UIViewController, JTCalendarDelegate, MDCalendarTimePickerDialogDelegate {

    // Get a reference to requests
    let ref = Firebase(url:"https://rendezvous-app.firebaseio.com/")
    let outgoingRef = Firebase(url:"https://rendezvous-app.firebaseio.com/outgoing/")
    let incomingRef = Firebase(url:"https://rendezvous-app.firebaseio.com/incoming/")
    
    
    
    let specialColor = UIColor(colorLiteralRed: 252/255, green: 60/255, blue: 52/255, alpha: 1)
    let blackColor = UIColor.blackColor()
    let whiteColor = UIColor.whiteColor()
    
    
    // Used for special handling of certain days
    var todayView: JTCalendarDayView!
    var pastViews = [JTCalendarDayView]()
    var selectedView: JTCalendarDayView!
    

    @IBOutlet var navigationBar: UINavigationBar!
    
    
    // JTCalendar Support
    var calendarMenuView: JTCalendarMenuView?
    var calendarContentView: JTHorizontalCalendarView?
    var calendarManager: JTCalendarManager!
    var JTDayView: JTCalendarDayView!
    
    var todayLoaded = 0
    var pastDaysLoaded = 0
    var pastDayLoaded = 0
    var selectionOffset = 0
    var todayOffset = 0
    var didSelect = false
    
    
    
    // MDTimePicker Support
    var timePicker: MDTimePickerDialog!
    var timePickerFrame: CGRect!
    
    
    // Display date and time
    var dateLabel: UILabel!
    var timeLabel: UILabel!
    
    
    
    @IBOutlet var contactName: UILabel!
    @IBOutlet var message: UITextField!
    
    
    // Contact setup
    var name: String!
    var email: String!
    

    // Month handling
    var monthLabel = UILabel()
    let months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    
    
    
    // Selected time preferences
    var selectedYear = 0
    var selectedMonth = 0
    var selectedDay = 0
    var selectedHour = 0
    var selectedMinute = 0

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.removeFromSuperview()
        contactName.removeFromSuperview()
        
        // Get height reference from navigationBar
        let navigationBarHeight = navigationBar.frame.height
        let navigationBarY = navigationBar.frame.origin.y
        let viewWidth = self.view.frame.width
        let viewHeight = self.view.frame.height
        var yOffset = navigationBarY
        var availableSpace = viewHeight
        
        
        // Set the name of contact at the top of screen
        contactName.text = name!
        
        
        
        /* Calendar setup */
        
        
        // Calendar Manager
        calendarManager = JTCalendarManager()
        calendarManager.delegate = self
        
        // Display month for calendar
        let monthFrame = CGRect(x: 0, y: yOffset, width: viewWidth, height: navigationBarHeight * 0.75)
        monthLabel = UILabel(frame: monthFrame)
        monthLabel.textAlignment = NSTextAlignment.Center
        self.view.addSubview(monthLabel)
        yOffset += navigationBarHeight * 0.5
        availableSpace -= navigationBarHeight * 0.5
        
        // Initialize month to current month
        let today = NSDate()
        let thisMonth = months[today.mdMonth - 1]
        monthLabel.text = thisMonth
        //monthLabel.backgroundColor = navigationBar.barTintColor
        
        
        //calendarMenuView = JTCalendarMenuView(frame: monthFrame)
 
        // Display calendar days
        let contentFrame = CGRect(x: 0, y: yOffset, width: viewWidth, height: navigationBarHeight * 1.5)
        yOffset += navigationBarHeight * 1.5
        availableSpace -= navigationBarHeight * 1.5
        calendarContentView = JTHorizontalCalendarView(frame: contentFrame)
        //calendarContentView?.backgroundColor = navigationBar.barTintColor
        
        // Show week day labels
        createWeekDayHeader()
        
        
        // Set up manager
        calendarManager.menuView = calendarMenuView
        calendarManager.contentView = calendarContentView
        
        // Initialize settings
        calendarManager.setDate(NSDate())
        calendarManager.settings.weekModeEnabled = true
        calendarManager.reload()
        
        self.view.addSubview(calendarContentView!)
        //self.view.addSubview(calendarMenuView!)
        
        /* End Calendar Setup */
        
        
        
        /* Show date and time */
        
        let dateFrame = CGRectMake(0, yOffset, viewWidth, navigationBarHeight * 1)
        yOffset += navigationBarHeight * 0.75
        availableSpace -= navigationBarHeight * 0.75
        dateLabel = UILabel(frame: dateFrame)
        dateLabel.font = UIFont.systemFontOfSize(20)
        updateDate(NSDate())
        dateLabel.textAlignment = NSTextAlignment.Center
        self.view.addSubview(dateLabel)
    
        
        /***********  ADD LATER: Jump to selected date when you press date and time label **************/
        /*
        dateAndTimeButton = UIButton(frame: dateAndTimeFrame)
        dateAndTimeButton.alpha = 1
        dateAndTimeButton.layer.borderColor = UIColor.redColor().CGColor
        dateAndTimeButton.layer.borderWidth = 0.5
        self.view.addSubview(dateAndTimeButton)
        dateAndTimeButton.addTarget(self, action: #selector(ContactViewController.returnToSelectedDate(_:)), forControlEvents: .TouchUpInside)
        */
        
        
        /* End show date and time */
        
        
        /* Time picker setup */
        timePickerFrame = CGRectMake(0, yOffset, viewWidth, 200)
        yOffset += 200
        availableSpace -= 200
        
        //timePicker = MDTimePickerDialog(frame: timePickerFrame)
        timePicker = MDTimePickerDialog(hour: 12, andWithMinute: 0, andWithFrame: timePickerFrame)
        //timePicker.backgroundColor = navigationBar.barTintColor
        timePicker.frame = timePickerFrame
        timePicker.updateFrame(CGRectMake(0, 0, timePickerFrame.width, timePickerFrame.height))
        timePicker.delegate = self
        timePicker.show()
        
        self.view.addSubview(timePicker)

        
        /* End time picker setup */
        
        
        
        
 
        
        
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
        sendButton.setTitle("Send Request", forState: UIControlState.Normal)
        sendButton.backgroundColor = UIColor.whiteColor()
        sendButton.setTitleColor(specialColor, forState: UIControlState.Normal)
        //self.view.addSubview(sendButton)
        /* End setup send button */
        
        /* Show comment box */
        message.hidden = true
        //sendButton.hidden = true
        /* End show comment box */
        
        
        
        
        
        
        
        // Do any additional setup after loading the view.
    }
    

    
    // ADD LATER: Jump to the selected date
    /*
    func returnToSelectedDate(sender: UIButton!) {
        print("returning")
        print(selectedView.date.description)
        selectedView.circleView.backgroundColor = UIColor.blackColor()
        selectedView.textLabel.textColor = UIColor.whiteColor()
        selectionOffset = 0
        
        calendarManager.setDate(selectedView.date)
    }*/
    
    
    /* Display weekday labels ---------- MOVE TO JTCalendar class */
    func createWeekDayHeader() {
        
        let labelWidth = self.view.frame.width / 7
        let weekDays = ["S", "M", "T", "W", "T", "F", "S"]
        
        var i = 0 
        while (i < 7) {
            let weekDayFrame = CGRectMake(labelWidth * CGFloat(i), calendarContentView!.frame.origin.y + 7, labelWidth, navigationBar.frame.height / 1.5)
            let weekDayLabel = UILabel(frame: weekDayFrame)
            weekDayLabel.text = weekDays[i]
            weekDayLabel.textAlignment = NSTextAlignment.Center
            weekDayLabel.textColor = UIColor.darkGrayColor()
            weekDayLabel.font = weekDayLabel.font.fontWithSize(10)
            self.view.addSubview(weekDayLabel)
            i += 1
        }
    }
    

    
    // Set the preferred hour and minute
    func timePickerDialog(timePickerDialog: MDTimePickerDialog!, didSelectHour hour: Int, andMinute minute: Int) {
        selectedHour = hour
        selectedMinute = minute
    }
    
    
    func isSameDay(dayOne: NSDate, dayTwo: NSDate) -> Bool {
        
        if ((dayOne.mdDay == dayTwo.mdDay) && (dayOne.mdMonth == dayTwo.mdMonth) && (dayOne.mdYear == dayTwo.mdYear)) {
            return true
        } else {
            return false
        }
    }
    
    // Set the preferred day, month, year
    func updateDate(date: NSDate) -> Void {
        
        let formatter = NSDateFormatter()
        
        let today = NSDate()
        let tomorrow = today.mdDateByAddingDays(1)
        
        if (isSameDay(date, dayTwo: today) || isSameDay(date, dayTwo: tomorrow)) {   // Special formatting for today and tomorrow days
            formatter.dateFormat = ", MMMM d"
        } else {
            formatter.dateFormat = "EEEE, MMMM d"
        }
        
        
        var description = formatter.stringFromDate(date)
        
        
        // Special formatting for today and tomorrow days
        if (isSameDay(date, dayTwo: today)) {
            description = "Today" + description
        }
        
        if (isSameDay(date, dayTwo: tomorrow)) {
            description = "Tomorrow" + description
        }
        
        dateLabel.text = description
        
        let monthFormatter = NSDateFormatter()
        monthFormatter.dateFormat = "MMMM"
        let monthDescription = monthFormatter.stringFromDate(date)
        updateMonthHeader(monthDescription)
        
        
        selectedDay = date.mdDay
        selectedMonth = date.mdMonth
        selectedYear = date.mdYear
    }
    
    
    // Update month header
    func updateMonthHeader(month: String) {
       monthLabel.text = month
    }
    
    func calendar(calendar: JTCalendarManager!, prepareDayView dayView: UIView!) {
        
        JTDayView = dayView as! JTCalendarDayView
        
        let updatedMonth = months[calendar.date().mdMonth - 1]
        updateMonthHeader(updatedMonth)
        
        
        // Make current day orange
        let today = NSDate()
        if (isSameDay(JTDayView.date, dayTwo: today)) {
            
            /*** Only load the second time ***/
            if (todayLoaded == 1) {
            
                todayView = JTDayView
                todayView.circleView.hidden = false
                todayView.textLabel.textColor = specialColor
                
                
                selectedView = todayView
                presentSelectedDayView(selectedView, backgroundColor: specialColor, textColor: whiteColor)

                
                
                selectionOffset == 0
                
            }
            todayLoaded += 1
        }
        
        
        // Make past days grey
        let tenDaysBefore = today.mdDateBySubtractingDays(10)
        let oneDayBefore = today.mdDateBySubtractingDays(1)
        if (calendar.dateHelper.date(JTDayView.date, isEqualOrAfter: tenDaysBefore, andEqualOrBefore: oneDayBefore)) {
            
            if (pastDaysLoaded >= 17) {
                let pastDay = JTDayView
                pastViews += [pastDay]
                pastDay.textLabel.textColor = UIColor.lightGrayColor()
            }
            
            pastDaysLoaded += 1
        }
    }
    
    
    /* Selection color handling */
    func presentSelectedDayView(dayView: JTCalendarDayView!, backgroundColor: UIColor, textColor: UIColor) {
        dayView.circleView.hidden = false
        dayView.circleView.backgroundColor = backgroundColor
        dayView.textLabel.textColor = textColor
    }
    
    func hideSelectedDayView(dayView: JTCalendarDayView!, textColor: UIColor) {
        dayView.circleView.hidden = true
        dayView.textLabel.textColor = textColor
    }
    
    func updateSelectedViews() {
        // Make sure month label matches the selected month if in the same view
        if (didSelect && (selectionOffset == 0)) {
            updateDate(selectedView.date)
        }
        
        
        // today is selected
        if (selectedView == todayView) {
            
            // close to the selected day
            if (selectionOffset > -2 && selectionOffset < 2) {
                
                presentSelectedDayView(selectedView, backgroundColor: specialColor, textColor: whiteColor)
                
            } else {
                hideSelectedDayView(selectedView, textColor: blackColor)
            }
            
        } else {
            
            // close to the selected day
            if (selectionOffset > -2 && selectionOffset < 2) {
                presentSelectedDayView(selectedView, backgroundColor: blackColor, textColor: whiteColor)
                
            } else {
                hideSelectedDayView(selectedView, textColor: blackColor)
            }
            
            
            if (todayOffset > -2 && todayOffset < 2) {
                todayView.textLabel.textColor = specialColor
            } else {
                todayView.textLabel.textColor = blackColor
            }
            
        }
        
        if (todayOffset < 2) {
            for pastView in pastViews {
                pastView.textLabel.textColor = UIColor.lightGrayColor()
            }
        } else {
            for pastView in pastViews {
                pastView.textLabel.textColor = UIColor.blackColor()
                if (pastView == selectedView && (selectionOffset > -2 && selectionOffset < 2)) {
                    pastView.textLabel.textColor = whiteColor
                }
            }
        }
        
    }
    /* End selection color handling */
    
    func calendarDidLoadNextPage(calendar: JTCalendarManager!) {
        selectionOffset += 1
        todayOffset += 1
        updateSelectedViews()
    }
    
    
    
    func calendarDidLoadPreviousPage(calendar: JTCalendarManager!) {
        selectionOffset -= 1
        todayOffset -= 1
        updateSelectedViews()
    }
    
    
    // Prevent scrolling before current date
    func calendar(calendar: JTCalendarManager!, canDisplayPageWithDate date: NSDate!) -> Bool {
        return calendar.dateHelper.date(date, isEqualOrAfter: NSDate())
    }
    
    
    // select day
    func calendar(calendar: JTCalendarManager!, didTouchDayView dayView: UIView!) {
        
    
        didSelect = true
        
        // Use to indicate the selected date
        JTDayView = dayView as! JTCalendarDayView
        
        
        if (JTDayView.textLabel.textColor != UIColor.lightGrayColor()) {
            
            // Update previous selection
            var color: UIColor!
            if (isSameDay(selectedView.date, dayTwo: NSDate())) {
                color = specialColor
            } else {
                color = blackColor
            }
    
            hideSelectedDayView(selectedView, textColor: color)
            
            
            // Get the new selection
            selectedView = JTDayView
            
            
            // Update new selection
            if (isSameDay(selectedView.date, dayTwo: NSDate())) {
                color = specialColor
            } else {
                color = blackColor
            }
            presentSelectedDayView(selectedView, backgroundColor: color, textColor: whiteColor)
            
            let dateSelected = selectedView.date
            updateDate(dateSelected)
            
            selectionOffset = 0
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func back(sender: AnyObject) {
        //dismissViewControllerAnimated(true, completion: nil)
        timePicker.hidden = true
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
