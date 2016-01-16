//
//  DetailViewController.swift
//  MeMe
//
//  Created by Anton Vasilyev on 1/15/16.
//  Copyright © 2016 Anton Vasilyev. All rights reserved.
//

import Foundation
import UIKit

class DetailViewController : UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var meme: Meme!
    
    var memeIndex: Int!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.tabBar.hidden = true
        
        imageView!.image = meme.memedImage
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.hidden = false
    }
    
    @IBAction func editMeme(sender: UIBarButtonItem) {
        let memeController = storyboard!.instantiateViewControllerWithIdentifier("MemeCreateController") as! ViewController
        
        memeController.meme = meme
        memeController.modalInPopover = true
        
        presentViewController(memeController, animated: true, completion: nil)
    }
    
    @IBAction func deleteMeme(sender: UIBarButtonItem) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.memes.removeAtIndex(memeIndex)
        
        navigationController?.popToRootViewControllerAnimated(true)
    }
    
}