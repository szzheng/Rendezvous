//
//  ContactViewController.swift
//  Rendezvous
//
//  Created by Steven Zheng on 5/2/16.
//  Copyright © 2016 szzheng. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import JTCalendar
import MaterialControls
import QuartzCore



class ContactViewController: UIViewController, JTCalendarDelegate, MDCalendarTimePickerDialogDelegate, UITextFieldDelegate {

    
    @IBOutlet var checkIcon: UIBarButtonItem!
    @IBOutlet var cancelIcon: UIBarButtonItem!
    
    // Get a reference to requests
    let ref = FIRDatabase.database().reference()
    let requestsRef = FIRDatabase.database().referenceFromURL("https://rendezvous-app.firebaseio.com/requests/")
    
    
    
    let specialColor = UIColor(colorLiteralRed: 252/255, green: 60/255, blue: 52/255, alpha: 1)
    let blackColor = UIColor.blackColor()
    let whiteColor = UIColor.whiteColor()
    let calendarColor = UIColor(colorLiteralRed: 248/255, green: 248/255, blue: 248/255, alpha: 1)
    let borderColor = UIColor(colorLiteralRed: 220/255, green: 220/255, blue: 220/255, alpha: 1)
    
    let dimColor = UIColor(colorLiteralRed: 220/255, green: 220/255, blue: 220/255, alpha: 1)
    
    let greenColor = UIColor(colorLiteralRed: 76/255, green: 217/255, blue: 100/255, alpha: 1)
    let redColor = UIColor(colorLiteralRed: 255/255, green: 59/255, blue: 48/255, alpha: 1)

    
    
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
    
    var comment: UITextField!
    
    
    // Contact setup
    var name: String!
    var email: String!
    var photo: UIImage!
    

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
        
        //self.view.backgroundColor = UIColor.lightGrayColor()
        
        //navigationBar.removeFromSuperview()
        //contactName.removeFromSuperview()
        
        // Get height reference from navigationBar
        let navigationBarHeight = navigationBar.frame.height
        let navigationBarY = navigationBar.frame.origin.y
        let viewWidth = self.view.frame.width
        let viewHeight = self.view.frame.height
        var yOffset = navigationBarY + navigationBarHeight
        var availableSpace = viewHeight
        
        
        // Set the name of contact at the top of screen
        contactName.text = "Setup a Meeting"

        navigationBar.barTintColor = whiteColor
        /*
        cancelIcon.tintColor = redColor
        checkIcon.tintColor = greenColor
        */
        
        cancelIcon.tintColor = specialColor
        checkIcon.tintColor = specialColor
 
        
        let navigationBorderFrame = CGRectMake(0, yOffset, viewWidth, 0.5)
        yOffset += 0.5
        availableSpace -= 0.5
        let navigationBorder = UIView(frame: navigationBorderFrame)
        navigationBorder.backgroundColor = UIColor.lightGrayColor()
        self.view.addSubview(navigationBorder)
        
        /* Calendar setup */
        
        
        // Calendar Manager
        calendarManager = JTCalendarManager()
        calendarManager.delegate = self
        
        // Display month for calendar
        let monthFrame = CGRect(x: 0, y: yOffset, width: viewWidth, height: navigationBarHeight * 0.75)
        monthLabel = UILabel(frame: monthFrame)
        monthLabel.textAlignment = NSTextAlignment.Center
        monthLabel.backgroundColor = calendarColor
        //self.view.addSubview(monthLabel)
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
        calendarContentView?.backgroundColor = calendarColor
        //calendarContentView?.backgroundColor = navigationBar.barTintColor
        
        
        // Set up manager
        calendarManager.menuView = calendarMenuView
        calendarManager.contentView = calendarContentView
        
        // Initialize settings
        calendarManager.setDate(NSDate())
        calendarManager.settings.weekModeEnabled = true
        calendarManager.reload()
        
        self.view.addSubview(calendarContentView!)
        //self.view.addSubview(calendarMenuView!)
        
        self.view.addSubview(monthLabel)
        // Show week day labels
        createWeekDayHeader()

        // extra background padding
        let backgroundFrame = CGRect(x: 0, y: yOffset, width: viewWidth, height: 6)
        let backgroundPadding = UIView(frame: backgroundFrame)
        yOffset += 5
        availableSpace -= 5
        backgroundPadding.backgroundColor = calendarColor
        self.view.addSubview(backgroundPadding)
        /* End Calendar Setup */
        
        
        let borderFrame = CGRectMake(0, yOffset, viewWidth, 0.5)
        yOffset += 0.5
        availableSpace -= 0.5
        let border = UIView(frame: borderFrame)
        border.backgroundColor = UIColor.lightGrayColor()
        self.view.addSubview(border)
        
        
        /* Dim background color */
        let dimFrame = CGRectMake(0, yOffset, viewWidth, availableSpace)
        let dimView = UIView(frame: dimFrame)
        self.view.addSubview(dimView)
        dimView.backgroundColor = dimColor
        
        /* Show date and time */
        
        let dateFrame = CGRectMake(10, yOffset, viewWidth - 20, navigationBarHeight * 1)
        let dateAndTimeHolderFrame = CGRectMake(0, yOffset + 3, viewWidth, navigationBarHeight + 35)
        yOffset += navigationBarHeight * 0.75
        availableSpace -= navigationBarHeight * 0.75
        dateLabel = UILabel(frame: dateFrame)
        dateLabel.font = UIFont.systemFontOfSize(20)
        dateLabel.backgroundColor = UIColor.clearColor()
        updateDate(NSDate())
        dateLabel.textAlignment = NSTextAlignment.Center
        //self.view.addSubview(dateLabel)
        
        let dateAndTimeHolder = UIView(frame: dateAndTimeHolderFrame)
        dateAndTimeHolder.backgroundColor = UIColor.whiteColor()
        dateAndTimeHolder.layer.borderWidth = 0.5
        dateAndTimeHolder.layer.borderColor = borderColor.CGColor
        //dateAndTimeHolder.layer.cornerRadius = 4
        self.view.addSubview(dateAndTimeHolder)
        
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
        
        
        
        /* Clock border */
        let leftBorderFrame = CGRectMake(0, yOffset + 10, viewWidth / 5, 1)
        let leftBorder = UIView(frame: leftBorderFrame)
        leftBorder.backgroundColor = borderColor
        //self.view.addSubview(leftBorder)
        
        let rightBorderFrame = CGRectMake(4 * viewWidth / 5, yOffset + 10, viewWidth / 4, 1)
        let rightBorder = UIView(frame: rightBorderFrame)
        rightBorder.backgroundColor = borderColor
        //self.view.addSubview(rightBorder)
        
        yOffset += 1
        availableSpace -= 1
        /* Time picker setup */
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        let screenHeight = screenSize.height
        var timePickerHolder = UIView()
        if (screenHeight <= 568) {
        
            timePickerFrame = CGRectMake(0, yOffset, viewWidth, availableSpace + 130)
            let timePickerHolderFrame = CGRectMake(0, yOffset + 160, viewWidth, availableSpace)
            timePickerHolder = UIView(frame: timePickerHolderFrame)
        } else {
            timePickerFrame = CGRectMake(0, yOffset, viewWidth, availableSpace + 220)
            let timePickerHolderFrame = CGRectMake(0, yOffset + 250, viewWidth, availableSpace)
            timePickerHolder = UIView(frame: timePickerHolderFrame)
        }
        
        
        timePickerHolder.backgroundColor = UIColor.whiteColor()
        timePickerHolder.layer.borderColor = borderColor.CGColor
        //timePickerHolder.layer.cornerRadius = 4
        timePickerHolder.layer.borderWidth = 0.5
        
        dateAndTimeHolder.frame = CGRectMake(dateAndTimeHolder.frame.origin.x, dateAndTimeHolder.frame.origin.y, dateAndTimeHolder.frame.width, timePickerHolder.frame.origin.y - 3 - dateAndTimeHolder.frame.origin.y)
        //dateAndTimeHolder.layer.borderWidth = 1
        //dateAndTimeHolder.layer.borderColor = blackColor.CGColor
        
        
        yOffset += 350
        availableSpace -= 350
        
        //timePicker = MDTimePickerDialog(frame: timePickerFrame)
        timePicker = MDTimePickerDialog(hour: 12, andWithMinute: 0, andWithFrame: timePickerFrame)
        //timePicker.backgroundColor = navigationBar.barTintColor
        timePicker.frame = timePickerFrame
        timePicker.updateFrame(CGRectMake(0, 0, timePickerFrame.width, timePickerFrame.height))
        timePicker.delegate = self
        timePicker.show()
        
        self.view.addSubview(timePickerHolder)
        self.view.addSubview(timePicker)

        
        /* End time picker setup */
        
        
        /* Show people */
        let peopleFrame = CGRectMake(0, dateAndTimeHolder.frame.origin.y + 80, viewWidth, 35)
        let people = UIView(frame: peopleFrame)
        self.view.addSubview(people)
        
        let personFrame = CGRectMake(viewWidth / 2 - 25/2,  2.5, 30, 30)
        let person = ProfilePicture(frame: personFrame)
        person.image = photo
        people.addSubview(person)
        
        /* Show comment box */
        let commentFrame = CGRectMake(0, dateAndTimeHolder.frame.origin.y + 110, viewWidth, dateAndTimeHolder.frame.height - 110)
        comment = UITextField(frame: commentFrame)
        //comment.textContainer.maximumNumberOfLines = 2
        //comment.layer.borderColor = redColor.CGColor
        //comment.layer.borderWidth = 1
        comment.placeholder = "Add any additional details, e.g. location"
        comment.font = UIFont(name: (comment.font?.fontName)!, size: 12)
        //comment.textColor = UIColor.lightGrayColor()
        comment.textAlignment = NSTextAlignment.Center
        
        
        self.view.addSubview(comment)
        
        //self.view.addSubview(leftBorder)
        //self.view.addSubview(rightBorder)
        
        
        
        
 
        
        
        /* Show communication options */
        /*
        let communicationFrame = CGRectMake(0, yOffset, viewWidth, navigationBarHeight * 1.5)
        yOffset += navigationBarHeight * 1.5
        availableSpace -= navigationBarHeight * 1.5
        let communicationView = UIView(frame: communicationFrame)
        communicationView.backgroundColor = UIColor.blueColor()
        self.view.addSubview(communicationView)
        */
        /* End show communication options */
        
        
        /* Setup send button */
        /*
        let buttonBorderFrame = CGRectMake(0, viewHeight - navigationBarHeight - 1, viewWidth, 1)
        let buttonBorder = UIView(frame: buttonBorderFrame)
        buttonBorder.backgroundColor = borderColor
        self.view.addSubview(buttonBorder)
        */
        
        /*
        let sendButtonFrame = CGRectMake(3 * viewWidth/4, navigationBarY, viewWidth/4, navigationBarHeight * 0.5)
        let sendButton = UIButton(frame: sendButtonFrame)
        sendButton.setTitle("Send", forState: UIControlState.Normal)
        sendButton.backgroundColor = UIColor.clearColor()
        sendButton.setTitleColor(specialColor, forState: UIControlState.Normal)
        
        let cancelButtonFrame = CGRectMake(viewWidth/4, navigationBarY, viewWidth/4, navigationBarHeight * 0.5)
        let cancelButton = UIButton(frame: cancelButtonFrame)
        cancelButton.setTitle("Cancel", forState: .Normal)
        cancelButton.backgroundColor = UIColor.clearColor()
        cancelButton.setTitleColor(specialColor, forState: .Normal)

        
        self.view.addSubview(sendButton)
        self.view.addSubview(cancelButton)
        */
        
        /* End setup send button */
        
        /* Show comment box */
        message.hidden = true
        //sendButton.hidden = true
        /* End show comment box */
        
        
        
        comment.delegate = self
        
        
        
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
            weekDayLabel.textColor = UIColor.blackColor()
            weekDayLabel.font = weekDayLabel.font.fontWithSize(12)
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
        selectedMonth = date.mdMonth - 1
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
    
    @IBAction func send(sender: AnyObject) {
        //dismissViewControllerAnimated(true, completion: nil)
        let yourEmail = FIRAuth.auth()?.currentUser?.email
        let yourAdjustedEmail = escapeEmailAddress(yourEmail!)
        
        let contactAdjustedEmail = escapeEmailAddress(email)
        
        let date = String(months[selectedMonth]) + " " + String(selectedDay) + ", " + String(selectedYear)
        let time = String(selectedHour) + ":" + String(selectedMinute)
        // outgoing request
        var request = ["comment": comment.text!, "from": yourAdjustedEmail, "to": contactAdjustedEmail, "date": date, "time": time, "type": 1]
        requestsRef.child(yourAdjustedEmail).childByAutoId().setValue(request)
        
        
        // incoming request
        request = ["comment": comment.text!, "from": yourAdjustedEmail, "to": contactAdjustedEmail, "date": date, "time": time, "type": 0]
        requestsRef.child(contactAdjustedEmail).childByAutoId().setValue(request)
        
        /*
        selectedYear = 0
        selectedMonth = 0
        selectedDay = 0
        selectedHour = 0
        selectedMinute = 0
        */
        
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
    
    
    // Allow keyboard to return if outside of keyboard is touched
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // Allow keyboard to return if return key is pressed
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
