//
//  CropPhotoViewController.swift
//  sabr
//
//  Created by Steven Zheng on 11/15/15.
//  Copyright © 2015 sabr. All rights reserved.
//
//  Crop photo into a square for profile picture

import UIKit


/*
* Used to pass information back to SetProfileViewController
*/
protocol CropPhotoViewControllerDelegate {
    func sendPhoto(var image: UIImage)  // send the cropped image back to SetProfileViewContrller
    func cancelPhoto()
    func enableContinue()
}


/*
* View controller to crop a selected photo for a profile picture
*/
class CropPhotoViewController: UIViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate {
    
    
    var delegate:CropPhotoViewControllerDelegate!   // Used to pass information back to SetProfile
    
    var moveAndScale: UILabel!  // Denotes user should move and scale photo
    var cancel: UIButton!       // Cancel cropping photo
    var done: UIButton!         // Done cropping photo
    
    
    // Selected photo
    var photoView: UIImageView!
    var photo: UIImage!
    
    // Cropped version of photo
    var croppedPhoto: UIImage!
    
    // Ratios
    var photoAspectRatio: CGFloat!           // photo's width to height
    var photoViewAspectRatio: CGFloat!       // photoView's width to height
    var photoToPhotoViewRatio: CGFloat!           // photo's height to photoView's height
    var differenceRatio: CGFloat!            // photoView's height not covered by photo's height to photoView's entire height
    
    var photoAdjustedHeight: CGFloat!    // photo's height adjusted for view
    
    // Mask layer
    var maskLayer: UIView!
    let maskWidthtoScreenWidthRatio: CGFloat! = 0.9
    
    
    // photo dimensions
    var photoSize: CGSize!
    var photoWidth: CGFloat!
    var photoHeight: CGFloat!
    //var location = CGPoint(x: 0, y: 0)
    
    
    // Square containing cropping mask
    var maskSquare: CGRect!
    
    // scroll view used from scaling photo
    @IBOutlet var scrollView: UIScrollView!
    let minZoomScale: CGFloat = 0.9
    let maxZoomScale: CGFloat = 4.0
    
    
    /*
    var cropPhotoAndSquareView: UIView!
    
    var contentOffset: CGPoint!
    */
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        scrollView.bounces = false   // turn off bounce animation on scrollView
        
        // set up photo to be cropped
        let normalizedPhoto: UIImage = normalizedImage(photo)
        photoView = UIImageView(image: normalizedPhoto)
        let frame:CGRect = view.frame
        let bounds:CGRect = view.bounds
        photoView.frame = frame
        // scrollView.addSubview(photoView)
        photoView.contentMode = UIViewContentMode.ScaleAspectFit
        scrollView.addSubview(photoView)
        photoView.backgroundColor = UIColor.blackColor()
        
        
        // Calculate ratios
        photoSize = photoView.image!.size
        photoWidth = photoSize.width
        photoHeight = photoSize.height
        photoAspectRatio = photoWidth / photoHeight
        photoViewAspectRatio = UIScreen.mainScreen().bounds.width / UIScreen.mainScreen().bounds.height
        photoToPhotoViewRatio = photoViewAspectRatio / photoAspectRatio
        differenceRatio = 1.0 - photoToPhotoViewRatio
        
        photoAdjustedHeight = UIScreen.mainScreen().bounds.width / (photoAspectRatio)
        
        
        
        /*
        * Set up mask
        */
        
        // Create mask dimenensions
        maskLayer = UIView(frame: frame)
        let maskDiameter = bounds.width * maskWidthtoScreenWidthRatio
        let maskX = (bounds.width - maskDiameter) / 2
        let maskY = (bounds.height - maskDiameter) / 2
        let mask = CAShapeLayer()
        let rectPath = UIBezierPath(rect: bounds)
        let circPath = UIBezierPath(ovalInRect: CGRect(x: maskX, y: maskY, width: maskDiameter, height: maskDiameter))
        rectPath.appendPath(circPath)
        
        // Configue mask and add it on top of view
        mask.path = rectPath.CGPath
        mask.fillRule = kCAFillRuleEvenOdd  // fills inside rectangle, outside circle
        maskLayer.layer.mask = mask
        maskLayer.clipsToBounds = true
        maskLayer.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.60)
        view.addSubview(maskLayer)
        maskLayer.userInteractionEnabled = false
        maskSquare = CGRect(x: maskX, y: maskY, width: maskDiameter, height: maskDiameter)  // set the rectangle of mask
        
        
        let labelWidth: CGFloat! = 120
        let labelHeight: CGFloat! = 30
        let textSize: CGFloat! = 16
        
        // Move and Scale Label
        moveAndScale = UILabel(frame: CGRectMake(0, 0, labelWidth, labelHeight))
        moveAndScale.text = "Move and Scale"
        moveAndScale.textColor = UIColor.whiteColor()
        moveAndScale.font = UIFont(name: moveAndScale.font.fontName, size: textSize)
        
        view.addSubview(moveAndScale)
        
        moveAndScale.translatesAutoresizingMaskIntoConstraints = false
        
        let labelTopConstraint = NSLayoutConstraint(item: moveAndScale, attribute: .Top, relatedBy: .Equal, toItem: moveAndScale.superview, attribute: .Top, multiplier: 1, constant: 75)
        let labelCenterXConstraint = NSLayoutConstraint(item: moveAndScale, attribute: .CenterX, relatedBy: .Equal, toItem: moveAndScale.superview, attribute: .CenterX, multiplier: 1, constant: 0)
        
        labelTopConstraint.active = true
        labelCenterXConstraint.active = true
        
        moveAndScale.userInteractionEnabled = false
        
        
        let buttonWidth: CGFloat! = 50
        let buttonHeight: CGFloat! = 30
        
        // Cancel Button
        cancel = UIButton(frame: CGRectMake(0, 0, buttonWidth, buttonHeight))
        cancel.setTitle("Cancel", forState: .Normal)
        cancel.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        cancel.titleLabel!.font = UIFont(name: cancel.titleLabel!.font.fontName, size: textSize)
        
        view.addSubview(cancel)
        
        cancel.translatesAutoresizingMaskIntoConstraints = false
        let cancelButtonLeadingConstraint = NSLayoutConstraint(item: cancel, attribute: .Leading, relatedBy: .Equal, toItem: cancel.superview, attribute: .Leading, multiplier: 1, constant: 15)
        
        let cancelButtonBottomConstraint = NSLayoutConstraint(item: view, attribute: .Bottom, relatedBy: .Equal, toItem: cancel, attribute: .Bottom, multiplier: 1, constant: 35)
        
        cancelButtonLeadingConstraint.active = true
        cancelButtonBottomConstraint.active = true
        cancel.addTarget(self, action: "cancel:", forControlEvents: UIControlEvents.TouchUpInside)
        
        
        // Done Button
        done = UIButton(frame: CGRectMake(0, 0, buttonWidth, buttonHeight))
        done.setTitle("Done", forState: .Normal)
        done.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        done.titleLabel!.font = UIFont(name: done.titleLabel!.font.fontName, size: textSize)
        
        view.addSubview(done)
        
        done.translatesAutoresizingMaskIntoConstraints = false
        let doneButtonTrailingConstraint = NSLayoutConstraint(item: view, attribute: .Trailing, relatedBy: .Equal, toItem: done, attribute: .Trailing, multiplier: 1, constant: 15)
        
        let doneButtonBottomConstraint = NSLayoutConstraint(item: view, attribute: .Bottom, relatedBy: .Equal, toItem: done, attribute: .Bottom, multiplier: 1, constant: 35)
        
        doneButtonTrailingConstraint.active = true
        doneButtonBottomConstraint.active = true
        done.addTarget(self, action: "done:", forControlEvents: UIControlEvents.TouchUpInside)
        
        
        
        // set up zooming
        scrollView.delegate = self
        scrollView.minimumZoomScale = minZoomScale
        scrollView.maximumZoomScale = maxZoomScale
        scrollView.zoomScale = 1.0
        
        if ((photoAdjustedHeight * scrollView.zoomScale) >= (maskSquare.height)) {
            scrollView.minimumZoomScale = 1.0
        }
        
        
        // Do any additional setup after loading the view.
    }
    
    /*
    * Dismisses CropPhotoViewController without new profile picture
    */
    func cancel(sender: UIButton!) {
        delegate.cancelPhoto()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /*
    * Dismisses CropPhotoViewController with new profile picture
    */
    func done(sender: UIButton!) {
        croppedPhoto = cropPhoto()
        delegate.sendPhoto(croppedPhoto)
        delegate.enableContinue()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func cropPhoto() -> UIImage {
        
        var newImage: UIImage!
        var xOffsetPercentage: CGFloat!
        var yOffsetPercentage: CGFloat!
        var xPos: CGFloat!
        var yPos: CGFloat!
        var rect: CGRect!
        var imageRef: CGImageRef
        
        // Width of the photo to be cropped
        let cropWidth: CGFloat = photoSize.width * maskWidthtoScreenWidthRatio / scrollView.zoomScale
        
        // zoomed in
        if (scrollView.zoomScale >= 1) {
            // Offset percentages from the photoView offsets to be used to calcualte the photo offsets
            xOffsetPercentage = photoView.frame.origin.x / ((photoView.frame.width - maskSquare.width) / 2)
            yOffsetPercentage = photoView.frame.origin.y / ((photoView.frame.height * photoToPhotoViewRatio - maskSquare.height) / 2)
            
            // Caculate offsets
            xPos = ((photoSize.width - cropWidth) / 2) - (((photoSize.width - cropWidth) / 2) * xOffsetPercentage)
            yPos = ((photoSize.height - cropWidth) / 2) - (((photoSize.height - cropWidth) / 2) * yOffsetPercentage)
            rect = CGRectMake(xPos, yPos, cropWidth, cropWidth)
            
            // zoomed out
        } else {
            
            let maxXOffset = maskSquare.origin.x
            let maxYOffset = maskSquare.origin.y - (differenceRatio * photoView.frame.height / 2)
            let minXOffset = maxXOffset - (photoView.frame.width - maskSquare.width)
            let minYOffset = maxYOffset - (photoView.frame.height * photoToPhotoViewRatio - maskSquare.height)
            
            let xCenterPos = (minXOffset + maxXOffset) / 2
            let yCenterPos = (minYOffset + maxYOffset) / 2
            
            // Offset percentages from the photoView offsets to be used to calcualte the photo offsets
            xOffsetPercentage = (photoView.frame.origin.x - xCenterPos) / ((photoView.frame.width - maskSquare.width) / 2)
            yOffsetPercentage = (photoView.frame.origin.y - yCenterPos) / ((photoView.frame.height * photoToPhotoViewRatio - maskSquare.height) / 2)
            
            // Caculate offsets
            xPos = ((photoSize.width - cropWidth) / 2) - (((photoSize.width - cropWidth) / 2) * xOffsetPercentage)
            yPos = ((photoSize.height - cropWidth) / 2) - (((photoSize.height - cropWidth) / 2) * yOffsetPercentage)
            rect = CGRectMake(xPos, yPos, cropWidth, cropWidth)
        }
        
        // Create new image
        imageRef = CGImageCreateWithImageInRect(photoView.image!.CGImage, rect)!
        newImage = UIImage(CGImage: imageRef, scale: 1, orientation: UIImageOrientation.Up)
        
        return newImage
    }
    
    
    /*
    * Orients image properly
    */
    func normalizedImage (image: UIImage) -> UIImage {
        if (image.imageOrientation == UIImageOrientation.Up) {
            return image
        } else {
            UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
            image.drawInRect(CGRectMake(0, 0, image.size.width, image.size.height))
            let normalizedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return normalizedImage
        }
    }
    
    /*
    * Allow simultaneous gesture actions
    */
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    
    /*
    * Called when a pan gesture is detected, continued, and completed
    * Moves photo
    */
    @IBAction func handlePan(recognizer: UIPanGestureRecognizer) {
        
        let translation = recognizer.translationInView(self.view)
        
        
        // offset bounds
        var maxXOffset: CGFloat
        var maxYOffset: CGFloat
        var minXOffset: CGFloat
        var minYOffset: CGFloat
        
        if ((photoAdjustedHeight * scrollView.zoomScale) >= (maskSquare.height)) {
            // Panning for zoomed in view
            if (scrollView.zoomScale >= 1.0) {
                
                maxXOffset = (photoView.frame.width - maskSquare.width) / 2
                maxYOffset = (photoView.frame.height * photoToPhotoViewRatio - maskSquare.height) / 2
                minXOffset = maxXOffset * -1;
                minYOffset = maxYOffset * -1;
                
                
                // Move photo
                photoView.center = CGPoint(x: photoView.center.x + translation.x, y: photoView.center.y + translation.y)
                
                
                // Reset photo to bounds if it passes bounds
                resetToBounds(maxXOffset, minX: minXOffset, maxY: maxYOffset, minY: minYOffset)
                
                // Panning for zoomed out view
            } else if (scrollView.zoomScale >= minZoomScale) {
                
                maxXOffset = maskSquare.origin.x
                maxYOffset = maskSquare.origin.y - (differenceRatio * photoView.frame.height / 2.0)
                minXOffset = maxXOffset - (photoView.frame.width - maskSquare.width)
                minYOffset = maxYOffset - (photoView.frame.height * photoToPhotoViewRatio - maskSquare.height)
                
                
                // Move photo
                photoView.center = CGPoint(x: photoView.center.x + translation.x, y: photoView.center.y + translation.y)
                
                // Reset photo to bounds if it passes bounds
                resetToBounds(maxXOffset, minX: minXOffset, maxY: maxYOffset, minY: minYOffset)
            }
            
        }
        
        // Reset translation
        recognizer.setTranslation(CGPointZero, inView: self.view)
    }
    
    func resetToBounds(maxX: CGFloat, minX: CGFloat, maxY: CGFloat, minY: CGFloat) {
        if (photoView.frame.origin.x > maxX) {
            photoView.frame.origin.x = maxX
        }
        if (photoView.frame.origin.x < minX) {
            photoView.frame.origin.x = minX
        }
        if (photoView.frame.origin.y > maxY) {
            photoView.frame.origin.y = maxY
        }
        if (photoView.frame.origin.y < minY) {
            photoView.frame.origin.y = minY
        }
    }
    
    /*
    * Called when scroll view zooms
    * Prevents scrolling while zooming
    */
    func scrollViewDidZoom(scrollView: UIScrollView) {
        
        maintainScrollViewContentsPosition()
    }
    
    
    /*
    * Allows zooming photo
    */
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return photoView
    }
    
    /*
    * Prevent scrolling while zooming
    */
    func maintainScrollViewContentsPosition() {
        // Prevent scrolling while zooming when zoomed in
        if (scrollView.zoomScale >= 1.0) {
            scrollView.bounds.origin.x = (photoView.frame.width - scrollView.bounds.width) / 2.0
            scrollView.bounds.origin.y = (photoView.frame.height - scrollView.bounds.height) / 2.0
            
            // Prevent scrolling while zooming when zoomed out
        } else {
            
            let boundsSize = scrollView.bounds.size
            var contentsFrame = photoView.frame
            
            if contentsFrame.size.width < boundsSize.width {
                contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0
            } else {
                contentsFrame.origin.x = 0.0
            }
            
            if contentsFrame.size.height < boundsSize.height {
                contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0
            } else {
                contentsFrame.origin.y = 0.0
            }
            
            photoView.frame = contentsFrame
        }
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
    }
    
    
    
    
}