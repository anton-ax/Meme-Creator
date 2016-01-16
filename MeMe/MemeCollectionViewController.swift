//
//  MemeCollectionVC.swift
//  MeMe
//
//  Created by Anton Vasilyev on 1/15/16.
//  Copyright © 2016 Anton Vasilyev. All rights reserved.
//

import Foundation
import UIKit

class MemeCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let space: CGFloat = 3.0
    
    var memes: [Meme]!
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        memes = appDelegate.memes

        collectionView?.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        flowLayout.minimumInteritemSpacing = space
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memes.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("collectionCell", forIndexPath: indexPath) as! MemeCell
        let meme = memes[indexPath.row]
        cell.imageView?.image = meme.memedImage
        return cell
    }
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        flowLayout.invalidateLayout()
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath:NSIndexPath) {
        let detailController = storyboard!.instantiateViewControllerWithIdentifier("DetailViewController") as! DetailViewController
        detailController.meme = memes[indexPath.row]
        detailController.memeIndex = indexPath.row
        navigationController!.pushViewController(detailController, animated: true)
    }
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let screenRect:CGRect =  view.bounds
        let sWidth:CGFloat = screenRect.size.width
        
        var columnCount: CGFloat = 3;
        
        if(sWidth > 600) {
            columnCount = 4
        }
        
        let cellWidth:CGFloat = (sWidth - (3 * space)) / columnCount
        let size: CGSize = CGSizeMake(cellWidth, cellWidth*3/4)
        return size;
    }
}