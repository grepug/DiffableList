//
//  UIView+Utils.swift
//  
//
//  Created by Kai on 2022/3/22.
//

import UIKit

public extension UIView {
    static func makeDoneButton(inputView: UIView) -> UIToolbar {
        let toolBar = UIToolbar()
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                        target: nil, action: nil)
        let doneButton = UIBarButtonItem(systemItem: .done, primaryAction: .init { [weak inputView]  _ in
            inputView?.endEditing(false)
        })
        
        toolBar.setItems([flexSpace, doneButton], animated: true)
        toolBar.sizeToFit()
        
        return toolBar
    }
}

public extension UITextView {
    func addDoneButton() {
        inputAccessoryView = .makeDoneButton(inputView: self)
    }
}

public extension UITextField {
    func addDoneButton() {
        inputAccessoryView = .makeDoneButton(inputView: self)
    }
}
