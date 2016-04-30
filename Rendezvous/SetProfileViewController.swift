//
//  SetProfileViewController.swift
//  Rendezvous
//
//  Created by Steven Zheng on 4/22/16.
//  Copyright © 2016 szzheng. All rights reserved.
//

import UIKit
import Firebase

class SetProfileViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIScrollViewDelegate, CropPhotoViewControllerDelegate {

    // FIREBASE URL
    let ref = Firebase(url:"https://rendezvous-app.firebaseio.com/")
    
    
    var firstName: String!
    var lastName: String!
    
    var image: UIImage!     // image for profile picture

    @IBOutlet var continueButton: UIButton!
    
    @IBOutlet var profilePicture: UIImageView!
    
    @IBOutlet var initials: UILabel!
    
    
    
    
    /*
    * Action to select photo for profile picture
    */
    @IBAction func choosePhoto(sender: AnyObject) {
        
        let imageChoice = UIImagePickerController()
        imageChoice.delegate = self
        imageChoice.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        imageChoice.allowsEditing = false
        
        self.presentViewController(imageChoice, animated: true, completion: nil)
    }
    
    @IBAction func back(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    /*
    * Pick an image
    * Segues to photo crop scene
    */
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        self.image = image
        self.dismissViewControllerAnimated(false, completion:nil)
        performSegueWithIdentifier("CropPhotoSegue", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        continueButton.userInteractionEnabled = false
        continueButton.alpha = 0.25
        
        // placeholder text
        navigationController?.navigationBarHidden = true
        
        let index = firstName.startIndex
        initials.text = String(firstName[index]).capitalizedString + String(lastName[index]).capitalizedString
        
        
        
        
        // Make profile picture circular
        profilePicture.layer.cornerRadius = profilePicture.frame.size.width/2
        profilePicture.layer.borderColor = UIColor.darkGrayColor().CGColor
        profilePicture.layer.borderWidth = 0.25
        profilePicture.clipsToBounds = true
        
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    * Called in CropPhotoViewController to cancel updating profile picture in this view controller
    */
    func cancelPhoto() {
        //profilePicture.image = nil
    }
    
    /*
    * Called in CropPhotoViewController to update profile picture in this view controller
    */
    func sendPhoto(image: UIImage) {
        initials.hidden = true
        self.image = image
        profilePicture.image = self.image
        //newUser.setProfilePicture(self.image)
    }
    
    /*
    * Called in CropPhotoViewController to enable the continue button
    */
    func enableContinue() {
        continueButton.userInteractionEnabled = true
        continueButton.alpha = 1
    }
    

    @IBAction func setPhoto(sender: AnyObject) {
        
        let authData = ref.authData
        let data = UIImagePNGRepresentation(image)!
        let base64String = data.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
        
        let user = ["Profile Picture":base64String]
        let email = authData.providerData["email"] as! String
        let adjustedEmail = escapeEmailAddress(email)
        ref.childByAppendingPath("users").childByAppendingPath(adjustedEmail).updateChildValues(user)
        
        performSegueWithIdentifier("AddContactsSegue", sender: self)
        
    }
    
    func escapeEmailAddress(email: String) -> String {
        
        // Replace '.' (not allowed in a Firebase key) with ',' (not allowed in an email address)
        var adjustedEmail = email.lowercaseString
        adjustedEmail = email.stringByReplacingOccurrencesOfString(".", withString: ",", options: NSStringCompareOptions.LiteralSearch, range: nil)
        return adjustedEmail
    }
    
    
    @IBAction func skipSetPhoto(sender: AnyObject) {
        performSegueWithIdentifier("AddContactsSegue", sender: self)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        // Segue to crop photo
        if (segue.identifier == "CropPhotoSegue") {
            
            // Send selected photo to CropPhotoViewController
            let cropPhotoViewController = segue.destinationViewController as! CropPhotoViewController
            cropPhotoViewController.photo = image
            cropPhotoViewController.delegate = self
        }
        /*
        if (segue.identifier == "AddContactsSegue") {
            
            let addContactsVC = segue.destinationViewController as! AddContactsViewController
            
            addContactsVC.usersRef = ref
        }*/
        
    }


}
