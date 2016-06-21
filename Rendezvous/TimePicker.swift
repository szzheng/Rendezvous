//
//  TimePicker.swift
//  Rendezvous
//
//  Created by Steven Zheng on 5/30/16.
//  Copyright © 2016 szzheng. All rights reserved.
//
/*
import UIKit
import MaterialControls
import QuartzCore


protocol TimePickerDelegate {
    func timePicker (timePicker: TimePicker!, didSelectHour hour: Int, andMinute minute: Int) -> Void
}

class TimePicker: UIView, UIGestureRecognizerDelegate {
    
    var header: UIView
    var headerLabelHour: UILabel
    var headerLabelMinute: UILabel
    var headerLabelTimeMode: UILabel
    var buttonFont: UIFont
    
    
    func degreesToRadians(degrees: Double) -> Double {
        return (M_PI * degrees) / 180.0
    }
    
    let timeHeaderHeight = 50 as CGFloat
    let clockHeight = 150 as CGFloat
    let mainCircleRadius = 15 as CGFloat
    let smallCirculeRadius = 2 as CGFloat
    let hourItemSize = 30 as CGFloat
    
    
    var backgroundClock: CAShapeLayer!
    
    var labelTimeModeAM: UILabel!
    var labelTimeModePM: UILabel!
    var backgroundTimeMode: CAShapeLayer!
    
    
    
    var clockHour: UIView!
    var clockMinute: UIView!
    var clockHandView: UIView!
    var maskVisibleIndexLayer: CAShapeLayer!
    var maskInvisibleIndexLayer: CAShapeLayer!
    
    var headerTextColor: UIColor!
    var headerBackgroundColor: UIColor!
    var titleColor: UIColor!
    var titleSelectedColor: UIColor!
    var selectionColor: UIColor!
    var selectionCenterColor: UIColor!
    var backgroundPopupColor: UIColor!
    var backgroundClockColor: UIColor!
    
    
    
    /* Colors Theme */
    
    
    //var container: UIView!
    var currentHour: Int!
    var currentMinute: Int!
    var preHourTag: Int!
    var preMinuteTag: Int!
    var currentTimeModeStr: String!
    
    var selectorCircleLayer: CAShapeLayer!
    var selectorCirclePath: UIBezierPath!
    var selectorMinCirclePath: UIBezierPath!
    
    var autoShowMinute: Int!
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initDefaultTime()
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*
    init(hour: Int, minute: Int, frame: CGRect) {
        currentHour = hour % 24
        currentMinute = minute % 60
        self.frame = frame
        
        initialize()
    }*/
    

    
    func initialize() -> Void {
        initDefaultValues()
        initTheme()
        
        initComponents()
        initClockHandView()
        initClock()
        
        autoShowMinute = 0
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(rotateHand))
        panGesture.delegate = self
        panGesture.maximumNumberOfTouches = 1
        self.addGestureRecognizer(panGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureHandler))
        self.addGestureRecognizer(tapGesture)
        
        updateHeaderView()
        bringSubviewToFront(labelTimeModeAM)
        bringSubviewToFront(labelTimeModePM)
        
    }
    
    
    
    
    func initDefaultTime() -> Void {
        let currentDate = NSDate()
        currentHour = currentDate.mdHour
        currentMinute = currentDate.mdMinute
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale.currentLocale()
        dateFormatter.dateStyle = NSDateFormatterStyle.NoStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        let dateString = dateFormatter.stringFromDate(NSDate()) as NSString
        let amRange = dateString.rangeOfString(dateFormatter.AMSymbol)
        let pmRange = dateString.rangeOfString(dateFormatter.PMSymbol)
        
        if (amRange.length != NSNotFound) {
            currentTimeModeStr = "AM"
        } else if (pmRange.length != NSNotFound) {
            currentTimeModeStr = "PM"
        } else {
            currentTimeModeStr = nil
        }
    }
    
    func initDefaultValues() -> Void {
        
        if (currentTimeModeStr == nil) {
            if (currentHour < 12) {
                currentTimeModeStr = "AM";
            } else {
                currentTimeModeStr = "PM";
            }
        }
        
        currentHour = currentHour % 12;
        if (currentHour == 0) {
            currentHour = 12;
        }
        
        preHourTag = -1
        preMinuteTag = -1
    }
    
    
    func initTheme() -> Void {
        headerTextColor = UIColorHelper.colorWithRGBA("#000000")
        headerBackgroundColor = UIColor.clearColor()
        
        titleColor = UIColorHelper.colorWithRGBA("#2F2F2F")
        titleSelectedColor = UIColor.whiteColor()
        selectionColor = UIColorHelper.colorWithRGBA("#000000")
        selectionCenterColor = UIColorHelper.colorWithRGBA("#fc3c34")
        
        backgroundPopupColor = UIColor.clearColor()
        backgroundClockColor = UIColorHelper.colorWithRGBA("#fc3c34")
    }
    
    func initComponents() -> Void {
        
        self.backgroundColor = UIColor.clearColor()
        
        initHeaderView()
        
        let frameTimeModeAM = CGRectMake(20, 125, 40, 40)
        let frameTimeModePM = CGRectMake(self.frame.width - 60, 125, 40, 40)
        labelTimeModeAM = UILabel(frame: frameTimeModeAM)
        labelTimeModeAM.textColor = titleColor
        labelTimeModeAM.text = "AM"
        labelTimeModeAM.textAlignment = NSTextAlignment.Center
        labelTimeModePM = UILabel(frame: frameTimeModePM)
        labelTimeModePM.textColor = titleColor
        labelTimeModePM.text = "PM"
        labelTimeModePM.textAlignment = NSTextAlignment.Center
        
        backgroundTimeMode = CAShapeLayer()
        backgroundTimeMode.backgroundColor = UIColor.clearColor().CGColor
        backgroundTimeMode.frame = CGRectMake(20, 125, 40, 40)
        backgroundTimeMode.path = UIBezierPath(ovalInRect: backgroundTimeMode.bounds).CGPath
        backgroundTimeMode.fillColor = selectionColor.CGColor
        self.layer.insertSublayer(backgroundTimeMode, atIndex: 0)
        
        self.addSubview(labelTimeModeAM)
        self.addSubview(labelTimeModePM)
        
        
        let showTimeModeAMSelectorGesture = UITapGestureRecognizer(target: self, action: #selector(changeTimeModeAM))
        labelTimeModeAM.addGestureRecognizer(showTimeModeAMSelectorGesture)
        labelTimeModeAM.userInteractionEnabled = true
        
        let showTimeModePMSelectorGesture = UITapGestureRecognizer(target: self, action: #selector(changeTimeModePM))
        labelTimeModePM.addGestureRecognizer(showTimeModeAMSelectorGesture)
        labelTimeModePM.userInteractionEnabled = true
        
        self.backgroundColor = backgroundPopupColor
    }
    
    func initHeaderView() -> Void {
        header = UIView(frame: CGRectMake(0, 0, self.frame.width, timeHeaderHeight))
        headerLabelHour = UILabel(frame: CGRectMake(0, 0, header.frame.width / 2, header.frame.height))
        headerLabelHour.font = UIFont.monospacedDigitSystemFontOfSize(40, weight: UIFontWeightRegular)
        headerLabelHour.textAlignment = NSTextAlignment.Right
        
        headerLabelMinute = UILabel(frame: CGRectMake(header.frame.width / 2, 0, header.frame.width / 2, header.frame.height))
        headerLabelMinute.textAlignment = NSTextAlignment.Left
        headerLabelMinute.font = UIFont.monospacedDigitSystemFontOfSize(40, weight: UIFontWeightRegular)
        
        header.addSubview(headerLabelHour)
        header.addSubview(headerLabelMinute)
        self.addSubview(header)
        header.backgroundColor = headerBackgroundColor
        
        
        let showClockHourSelectorGesture = UITapGestureRecognizer(target: self, action: #selector(showClockHour))
        headerLabelHour.addGestureRecognizer(showClockHourSelectorGesture)
        headerLabelHour.userInteractionEnabled = true
        
        let showClockMinuteSelectorGesture = UITapGestureRecognizer(target: self, action: #selector(showClockMinute))
        headerLabelMinute.addGestureRecognizer(showClockMinuteSelectorGesture)
        headerLabelMinute.userInteractionEnabled = true

        
    }
    
    
    func initClock() -> Void {
        
        clockHour = UIView(frame: CGRectMake((self.frame.width - clockHeight) / 2, timeHeaderHeight + (self.frame.height - timeHeaderHeight - clockHeight) / 2, clockHeight, clockHeight))
        
        backgroundClock = CAShapeLayer()
        backgroundClock.backgroundColor = UIColor.clearColor().CGColor
        backgroundClock.frame = clockHour.frame
        backgroundClock.path = UIBezierPath(ovalInRect: backgroundClock.bounds).CGPath
        backgroundClock.fillColor = backgroundClockColor.CGColor
        self.layer.insertSublayer(backgroundClock, atIndex: 0)
        
        
        let stepAngle = (CGFloat)(2 * M_PI / 12)
        var xPoint = (CGFloat)(0)
        var yPoint = (CGFloat)(0)
        
        for i in 1...12 {
            let button = UIButton(type: UIButtonType.Custom)
            button.frame = CGRectMake(0, 0, hourItemSize, hourItemSize)
            button.tag = 110 + i
            button.backgroundColor = UIColor.clearColor()
            button.layer.cornerRadius = button.frame.size.width / 2
            button.titleLabel?.font = UIFont.monospacedDigitSystemFontOfSize(15, weight: UIFontWeightRegular)
            
            xPoint = clockHour.frame.width / 2
            xPoint = xPoint + sin(stepAngle * (CGFloat)(i))
            xPoint = xPoint * clockHeight / 2
            xPoint = xPoint - hourItemSize * 2.0 / 3.0
            yPoint = clockHour.frame.height / 2
            yPoint = xPoint + cos(stepAngle * (CGFloat)(i))
            yPoint = xPoint * clockHeight / 2
            yPoint = xPoint - hourItemSize * 2.0 / 3.0
            
            button.setTitle(NSString(format: "%d", i) as String, forState: .Normal)
            button.setTitleColor(titleColor, forState: .Normal)
            clockHour.addSubview(button)
            button.center = CGPointMake(xPoint, yPoint)
            button.addTarget(self, action: #selector(timeClicked), forControlEvents: .TouchUpInside)
            button.titleLabel?.textAlignment = NSTextAlignment.Center
            self.bringSubviewToFront(button)
        }
        
        clockMinute = UIView(frame: CGRectMake((self.frame.width - clockHeight) / 2, timeHeaderHeight + (self.frame.height - timeHeaderHeight - clockHeight) / 2, clockHeight, clockHeight))
        for i in 1...12 {
            let button = UIButton(type: UIButtonType.Custom)
            button.frame = CGRectMake(0, 0, hourItemSize, hourItemSize)
            button.tag = 110 + i + 24
            button.backgroundColor = UIColor.clearColor()
            button.layer.cornerRadius = button.frame.size.width / 2
            button.titleLabel?.font = UIFont.monospacedDigitSystemFontOfSize(15, weight: UIFontWeightRegular)
            
            xPoint = clockHour.frame.width / 2
            xPoint = xPoint + sin(stepAngle * (CGFloat)(i))
            xPoint = xPoint * clockHeight / 2
            xPoint = xPoint - hourItemSize * 2.0 / 3.0
            yPoint = clockHour.frame.height / 2
            yPoint = xPoint + cos(stepAngle * (CGFloat)(i))
            yPoint = xPoint * clockHeight / 2
            yPoint = xPoint - hourItemSize * 2.0 / 3.0
            
            if (i * 5 != 60) {
                button.setTitle(NSString(format: "%02d", 5 * i) as String, forState: .Normal)
            } else {
                button.setTitle("00", forState: .Normal)
            }
            button.setTitleColor(titleColor, forState: .Normal)
            clockHour.addSubview(button)
            button.center = CGPointMake(xPoint, yPoint)
            button.addTarget(self, action: #selector(timeClicked), forControlEvents: .TouchUpInside)
            button.titleLabel?.textAlignment = NSTextAlignment.Center
            self.bringSubviewToFront(button)
        }
        
        clockHour.backgroundColor = UIColor.clearColor()
        clockMinute.backgroundColor = UIColor.clearColor()
        self.addSubview(clockHour)
        self.addSubview(clockMinute)
        
        clockHour.hidden = false
        clockHour.hidden = true
    }

    
    
    func updateHeaderView() -> Void {
        
    }
    

    
    func initClockHandView() -> Void {
        
    }
    
    
    
    func rotateHand(view: UIView, rotationDegree: Float) -> Void {
        
    }
    
    func tapGestureHandler() -> Void {
        
    }
    
    
}
*/
