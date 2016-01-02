//
//  UpperCaseDelegate.swift
//  MeMe
//
//  Created by Anton Vasilyev on 1/2/16.
//  Copyright © 2016 Anton Vasilyev. All rights reserved.
//

import Foundation
import UIKit

class UpperCaseTextFieldDelegate : NSObject, UITextFieldDelegate {
    
    var topText: UITextField!
    var bottomText: UITextField!
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        textField.text = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string.uppercaseString)
        return false
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        let isTopDefaultText = topText.isFirstResponder() && textField.text == "TOP"
        let isBottomDefaultText = bottomText.isFirstResponder() && textField.text == "BOTTOM"
        if  isTopDefaultText || isBottomDefaultText {
            textField.text = ""
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
