//
//  ViewController.swift
//  MeMe
//
//  Created by Anton Vasilyev on 12/26/15.
//  Copyright © 2015 Anton Vasilyev. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var imagePreview: UIImageView!
    
    // for editing
    var meme: Meme!
    
    var image: UIImage!
    var offset: CGFloat = 0
    
    var upperCaseDelegate: UpperCaseTextFieldDelegate = UpperCaseTextFieldDelegate()
    
    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var bottomText: UITextField!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    @IBOutlet weak var container: UIView!
    
    var memeTextAttributes = [
        NSStrokeColorAttributeName : UIColor.blackColor(),
        NSForegroundColorAttributeName  : UIColor.whiteColor(),
        NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName : -4.0
    ]
    
    @IBAction func share(sender: AnyObject) {
        let memedImage = generateMemedImage()
        let activityVC = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        
        activityVC.completionWithItemsHandler = {
            (activity: String?, completed: Bool, items: [AnyObject]?, error: NSError?) -> Void in
            if completed {
                self.save()
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }

        
        presentViewController(activityVC, animated: true, completion: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // if we edit existing meme
        if let meme = meme{
            image = meme.originalImage
            topText.text = meme.topText
            bottomText.text = meme.bottomText
            imagePreview.image = meme.originalImage
            updateWithImage()
        }
        updateTextFields()
        shareButton.enabled = image != nil
    }
    
    override func viewWillAppear(animated: Bool) {
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        
        topText.defaultTextAttributes = memeTextAttributes
        topText.textAlignment = NSTextAlignment.Center
        topText.delegate = upperCaseDelegate
        upperCaseDelegate.topText = topText
        
        bottomText.defaultTextAttributes = memeTextAttributes
        bottomText.textAlignment = NSTextAlignment.Center
        bottomText.delegate = upperCaseDelegate
        upperCaseDelegate.bottomText = bottomText
        
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    @IBAction func cancelAll(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func pickAnImage(sender: AnyObject) {
        let controller = UIImagePickerController()
        controller.sourceType = UIImagePickerControllerSourceType.PhotoLibrary;
        controller.delegate = self
        presentViewController(controller, animated: true, completion: nil)
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        super.didRotateFromInterfaceOrientation(fromInterfaceOrientation)
        if image != nil {
            imagePreview.frame = generatePreviewSize()
        }
        updateTextFields()
        topText.hidden = false
        bottomText.hidden = false
    }
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        super.willRotateToInterfaceOrientation(toInterfaceOrientation, duration: duration)
        topText.hidden = true
        bottomText.hidden = true
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.image = image
            updateWithImage()
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func updateWithImage() {
        shareButton.enabled = true
        imagePreview.image = image
        imagePreview.frame = generatePreviewSize()
        
        updateTextFields()
    }
    
    func generatePreviewSize() -> CGRect {
        let point = container.frame.origin
        let size = container.frame.size
        return AVMakeRectWithAspectRatioInsideRect(image.size, CGRectMake(point.x, point.y, size.width, size.height))
    }
    
    func updateTextFields() {
        let imageFrame = imagePreview.frame
        
        topText.frame.size.width = imageFrame.width - 100
        topText.frame.origin.x = imageFrame.origin.x + 50
        topText.frame.origin.y = imageFrame.origin.y + 50
        
        bottomText.frame.size.width = imageFrame.width - 100
        bottomText.frame.origin.x = imageFrame.origin.x + 50
        bottomText.frame.origin.y = imageFrame.origin.y + imageFrame.size.height - 50 - bottomText.frame.size.height
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    @IBAction func pickAnImageFromCamera(sender: AnyObject) {
        let controller = UIImagePickerController()
        controller.sourceType = UIImagePickerControllerSourceType.Camera;
        controller.delegate = self
        presentViewController(controller, animated: true, completion: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if bottomText.isFirstResponder() {
            let keyboardHeight = getKeyboardHeight(notification)
            let offset = keyboardHeight + imagePreview.frame.size.height + imagePreview.frame.origin.y
            if offset > view.frame.height {
                self.offset = offset - view.frame.height
                imagePreview.frame.origin.y -= self.offset
                updateTextFields()
            } else {
                self.offset = 0
            }
            
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if bottomText.isFirstResponder() {
            imagePreview.frame.origin.y += offset
            updateTextFields()
        }
    }
    
    func save() {
        let memedImage = generateMemedImage()
        let meme = Meme(topText: topText.text!, memedImage: memedImage,
            bottomText: bottomText.text!, originalImage: imagePreview.image!)
        // save meme
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.memes.append(meme)
    }
    
    func generateMemedImage() -> UIImage {
        // make screenshot from container
        UIGraphicsBeginImageContext(container.bounds.size)
        container.drawViewHierarchyInRect(container.bounds, afterScreenUpdates: true)
        let memedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        // and crop image with texts from screenshot
        let imageRef = CGImageCreateWithImageInRect(memedImage.CGImage, imagePreview.frame)!
        let croppedImage = UIImage(CGImage: imageRef)
        return croppedImage
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:",
            name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:",
            name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
}

