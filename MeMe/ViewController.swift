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
        
        presentViewController(activityVC, animated: true, completion: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
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
        
        self.subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    @IBAction func cancelAll(sender: AnyObject) {
        bottomText.text = "BOTTOM"
        topText.text = "TOP"
        image = nil
        imagePreview.image = nil
        shareButton.enabled = false
    }
    
    @IBAction func pickAnImage(sender: AnyObject) {
        let controller = UIImagePickerController()
        controller.sourceType = UIImagePickerControllerSourceType.PhotoLibrary;
        controller.delegate = self
        presentViewController(controller, animated: true, completion: nil)
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        if self.image != nil {
            self.imagePreview.frame = generatePreviewSize()
        }
        updateTextFields()
        self.topText.hidden = false
        self.bottomText.hidden = false
    }
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        self.topText.hidden = true
        self.bottomText.hidden = true
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.image = image
            shareButton.enabled = true
            self.imagePreview.image = image
            self.imagePreview.frame = generatePreviewSize()
            
            updateTextFields()
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func generatePreviewSize() -> CGRect {
        let point = self.container.frame.origin
        let size = self.container.frame.size
        return AVMakeRectWithAspectRatioInsideRect(self.image.size, CGRectMake(point.x, point.y, size.width, size.height))
    }
    
    func updateTextFields() {
        let imageFrame = self.imagePreview.frame
        
        self.topText.frame.size.width = imageFrame.width - 100
        self.topText.frame.origin.x = imageFrame.origin.x + 50
        self.topText.frame.origin.y = imageFrame.origin.y + 50
        
        self.bottomText.frame.size.width = imageFrame.width - 100
        self.bottomText.frame.origin.x = imageFrame.origin.x + 50
        self.bottomText.frame.origin.y = imageFrame.origin.y + imageFrame.size.height - 50 - self.bottomText.frame.size.height
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
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
            if offset > self.view.frame.height {
                self.offset = offset - self.view.frame.height
                imagePreview.frame.origin.y -= self.offset
                updateTextFields()
            } else {
                self.offset = 0
            }
            
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if bottomText.isFirstResponder() {
            imagePreview.frame.origin.y += self.offset
            updateTextFields()
        }
    }
    
    func save() {
        let memedImage = generateMemedImage()
        let meme = Meme(topText: topText.text!, memedImage: memedImage,
            bottomText: bottomText.text!, originalImage: imagePreview.image!)
        // todo: need to save somewhere !?
    }
    
    func generateMemedImage() -> UIImage {
        // make screenshot from container
        UIGraphicsBeginImageContext(self.container.bounds.size)
        self.container.drawViewHierarchyInRect(self.container.bounds, afterScreenUpdates: true)
        let memedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        // and crop image with texts from screenshot
        let imageRef = CGImageCreateWithImageInRect(memedImage.CGImage, self.imagePreview.frame)!
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
    
    struct Meme {
        var topText: String
        var memedImage: UIImage
        var bottomText: String
        var originalImage: UIImage
    }
}

