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

public extension UIView {
    var parentViewController: UIViewController? {
        sequence(first: self) { $0.next }
            .first(where: { $0 is UIViewController })
            .flatMap { $0 as? UIViewController }
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

extension UIView {
    func subviews<T: UIView>(ofType WhatType: T.Type) -> [T] {
        var result = subviews.compactMap { $0 as? T }
        
        for sub in subviews {
            result.append(contentsOf: sub.subviews(ofType: WhatType))
        }
        
        return result
    }
    
    var firstTextField: UITextField? {
        subviews(ofType: UITextField.self).first
    }
    
    var isFirstResponderInSubviews: Bool {
        subviews(ofType: UITextField.self).contains { $0.isFirstResponder } ||
            subviews(ofType: UITextView.self).contains { $0.isFirstResponder }
    }
    
    var firstResponder: UIView? {
        subviews(ofType: UITextField.self).first { $0.isFirstResponder } ??
            subviews(ofType: UITextView.self).first { $0.isFirstResponder }
    }
}
